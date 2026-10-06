from database.conexion import conectar, cerrar_conexion


class UsuarioModel:
    """Modelo MVC para el acceso a datos de usuarios."""

    def cargar_catalogos(self):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()
            plataformas = {}

            cursor.execute("""
                SELECT id_plataforma, nombre
                FROM plataformas
                ORDER BY nombre
            """)

            for id_plataforma, nombre in cursor.fetchall():
                plataformas[nombre] = id_plataforma

            cursor.close()
            return plataformas

        finally:
            cerrar_conexion(conexion)

    def listar(self, estado=None, busqueda=None):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()
            cursor.callproc(
                "sp_listar_usuarios",
                [estado, busqueda]
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
                "sp_insertar_usuario",
                [
                    datos["usuario"],
                    datos["correo"],
                    datos["password"],
                    datos["estado"],
                    datos["plataformas"],
                    datos["preferencias"],
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

    def obtener_datos_extra(self, id_usuario):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()

            cursor.execute("""
                SELECT id_plataforma
                FROM usuario_plataformas
                WHERE id_usuario = %s
            """, (id_usuario,))

            plataformas = {
                fila[0]
                for fila in cursor.fetchall()
            }

            cursor.execute("""
                SELECT clave, valor
                FROM usuario_preferencias
                WHERE id_usuario = %s
                LIMIT 1
            """, (id_usuario,))

            fila = cursor.fetchone()
            preferencia = fila if fila else ("", "")

            cursor.close()
            return plataformas, preferencia[0], preferencia[1]

        finally:
            cerrar_conexion(conexion)

    def actualizar(self, id_usuario, datos):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()

            cursor.callproc(
                "sp_actualizar_usuario",
                [
                    id_usuario,
                    datos["usuario"],
                    datos["correo"],
                    datos["password"],
                    datos["estado"],
                    datos["plataformas"],
                    datos["preferencias"]
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

    def eliminar(self, id_usuario):
        conexion = conectar()
        if conexion is None:
            raise ConnectionError("No fue posible conectar con la base de datos.")

        try:
            cursor = conexion.cursor()

            cursor.callproc(
                "sp_eliminar_usuario",
                [id_usuario]
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
