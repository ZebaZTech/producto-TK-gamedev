from database.conexion import conectar, cerrar_conexion


class EmpleadoModel:
    """Modelo MVC para el acceso a datos de empleados."""

    def cargar_catalogos(self):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()

            especialidades = {}
            habilidades = {}

            cursor.execute("""
                SELECT id_especialidad, nombre
                FROM especialidades
                ORDER BY nombre
            """)
            for id_especialidad, nombre in cursor.fetchall():
                especialidades[nombre] = id_especialidad

            cursor.execute("""
                SELECT id_habilidad, nombre
                FROM habilidades
                ORDER BY nombre
            """)
            for id_habilidad, nombre in cursor.fetchall():
                habilidades[nombre] = id_habilidad

            cursor.close()
            return especialidades, habilidades
        finally:
            cerrar_conexion(conexion)

    def listar(self, id_especialidad=None, solo_activos=0, busqueda=None):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()
            cursor.callproc(
                "sp_listar_empleados",
                [id_especialidad, solo_activos, busqueda]
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
                "sp_insertar_empleado",
                [
                    datos["codigo"],
                    datos["nombres"],
                    datos["apellidos"],
                    datos["id_especialidad"],
                    datos["experiencia"],
                    datos["experiencia_previa"],
                    datos["correo"],
                    datos["habilidades"],
                    datos["imagen"],
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

    def obtener_datos_extra(self, id_empleado):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()

            cursor.execute("""
                SELECT experiencia_previa, imagen_perfil
                FROM empleados
                WHERE id_empleado = %s
            """, (id_empleado,))
            fila = cursor.fetchone()

            experiencia_previa = fila[0] if fila else ""
            imagen = fila[1] if fila else None

            cursor.execute("""
                SELECT id_habilidad
                FROM empleado_habilidades
                WHERE id_empleado = %s
            """, (id_empleado,))
            habilidades = {fila[0] for fila in cursor.fetchall()}

            cursor.close()

            return experiencia_previa, imagen, habilidades
        finally:
            cerrar_conexion(conexion)

    def actualizar(self, id_empleado, datos):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()
            cursor.callproc(
                "sp_actualizar_empleado",
                [
                    id_empleado,
                    datos["codigo"],
                    datos["nombres"],
                    datos["apellidos"],
                    datos["id_especialidad"],
                    datos["experiencia"],
                    datos["experiencia_previa"],
                    datos["correo"],
                    datos["activo"],
                    datos["habilidades"],
                    datos["imagen"]
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

    def eliminar(self, id_empleado):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()
            cursor.callproc("sp_eliminar_empleado", [id_empleado])

            for resultado in cursor.stored_results():
                resultado.fetchall()

            conexion.commit()
            cursor.close()
        except Exception:
            conexion.rollback()
            raise
        finally:
            cerrar_conexion(conexion)
