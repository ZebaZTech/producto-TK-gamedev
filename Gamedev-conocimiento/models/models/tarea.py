from database.conexion import conectar, cerrar_conexion


class TareaModel:
    """Modelo MVC para el acceso a datos de tareas."""

    def cargar_catalogos(self):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()

            videojuegos = {}
            modulos = {}
            empleados = {}

            cursor.execute("""
                SELECT id_videogame, codigo, titulo
                FROM videogames
                ORDER BY titulo
            """)
            for id_videogame, codigo, titulo in cursor.fetchall():
                videojuegos[f"{codigo} - {titulo}"] = id_videogame

            cursor.execute("""
                SELECT id_modulo, nombre
                FROM modulos_desarrollo
                ORDER BY nombre
            """)
            for id_modulo, nombre in cursor.fetchall():
                modulos[nombre] = id_modulo

            cursor.execute("""
                SELECT id_empleado, nombres, apellidos
                FROM empleados
                WHERE activo = 1
                ORDER BY apellidos, nombres
            """)
            for id_empleado, nombres, apellidos in cursor.fetchall():
                empleados[f"{id_empleado} - {nombres} {apellidos}"] = id_empleado

            cursor.close()
            return videojuegos, modulos, empleados

        finally:
            cerrar_conexion(conexion)

    def cargar_responsables(self, id_videogame):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()

            cursor.execute("""
                SELECT e.id_empleado, e.nombres, e.apellidos
                FROM empleados e
                INNER JOIN asignaciones_proyecto a
                    ON a.id_empleado = e.id_empleado
                WHERE a.id_videogame = %s
                  AND e.activo = 1
                ORDER BY e.apellidos, e.nombres
            """, (id_videogame,))

            empleados = {}
            for id_empleado, nombres, apellidos in cursor.fetchall():
                empleados[f"{id_empleado} - {nombres} {apellidos}"] = id_empleado

            cursor.close()
            return empleados

        finally:
            cerrar_conexion(conexion)

    def cargar_dependencias(self, id_tarea_actual=None):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()

            if id_tarea_actual:
                cursor.execute("""
                    SELECT id_tarea, codigo
                    FROM tareas
                    WHERE id_tarea <> %s
                    ORDER BY codigo
                """, (id_tarea_actual,))
            else:
                cursor.execute("""
                    SELECT id_tarea, codigo
                    FROM tareas
                    ORDER BY codigo
                """)

            tareas = {}
            for id_tarea, codigo in cursor.fetchall():
                tareas[codigo] = id_tarea

            cursor.close()
            return tareas

        finally:
            cerrar_conexion(conexion)

    def listar(self, id_videogame=None, estado=None, id_responsable=None):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()
            cursor.callproc(
                "sp_listar_tareas",
                [id_videogame, estado, id_responsable]
            )

            filas = []
            for resultado in cursor.stored_results():
                filas.extend(resultado.fetchall())

            cursor.close()
            return filas

        finally:
            cerrar_conexion(conexion)

    def insertar(self, datos):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()

            resultado = cursor.callproc(
                "sp_insertar_tarea",
                [
                    datos["codigo"],
                    datos["id_videojuego"],
                    datos["id_modulo"],
                    datos["descripcion"],
                    datos["prioridad"],
                    datos["estado"],
                    datos["id_responsable"],
                    datos["fecha_asignacion"],
                    datos["fecha_limite"],
                    datos["avance"],
                    datos["dependencias"],
                    None
                ]
            )

            conexion.commit()
            cursor.close()
            return resultado[-1]

        except Exception:
            conexion.rollback()
            raise

        finally:
            cerrar_conexion(conexion)

    def actualizar(self, id_tarea, datos):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()

            cursor.callproc(
                "sp_actualizar_tarea",
                [
                    id_tarea,
                    datos["codigo"],
                    datos["id_videojuego"],
                    datos["id_modulo"],
                    datos["descripcion"],
                    datos["prioridad"],
                    datos["estado"],
                    datos["id_responsable"],
                    datos["fecha_asignacion"],
                    datos["fecha_limite"],
                    datos["avance"],
                    datos["dependencias"]
                ]
            )

            for resultado in cursor.stored_results():
                resultado.fetchall()

            conexion.commit()
            cursor.close()

        except Exception:
            conexion.rollback()
            raise

        finally:
            cerrar_conexion(conexion)

    def eliminar(self, id_tarea):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()

            cursor.callproc("sp_eliminar_tarea", [id_tarea])

            for resultado in cursor.stored_results():
                resultado.fetchall()

            conexion.commit()
            cursor.close()

        except Exception:
            conexion.rollback()
            raise

        finally:
            cerrar_conexion(conexion)
