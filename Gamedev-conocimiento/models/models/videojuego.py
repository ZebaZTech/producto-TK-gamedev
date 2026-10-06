import json

from database.conexion import conectar, cerrar_conexion


class VideojuegoModel:
    """Modelo de datos para el módulo de videojuegos.

    Centraliza el acceso a MySQL y las operaciones CRUD mediante
    procedimientos almacenados.
    """

    def cargar_catalogos(self):
        conexion = conectar()

        if conexion is None:
            raise ConnectionError(
                "No fue posible conectar con la base de datos."
            )

        try:
            cursor = conexion.cursor()

            generos = {}
            clasificaciones = {}
            motores = {}
            plataformas = {}

            cursor.execute(
                """
                SELECT id_genero, nombre
                FROM generos
                ORDER BY nombre
                """
            )

            for id_genero, nombre in cursor.fetchall():
                generos[nombre] = id_genero

            cursor.execute(
                """
                SELECT id_clasificacion, sistema, codigo
                FROM clasificaciones
                ORDER BY sistema, codigo
                """
            )

            for id_clasificacion, sistema, codigo in cursor.fetchall():
                clasificaciones[
                    f"{sistema} {codigo}"
                ] = id_clasificacion

            cursor.execute(
                """
                SELECT id_motor, nombre
                FROM motores_graficos
                ORDER BY nombre
                """
            )

            for id_motor, nombre in cursor.fetchall():
                motores[nombre] = id_motor

            cursor.execute(
                """
                SELECT id_plataforma, nombre
                FROM plataformas
                ORDER BY nombre
                """
            )

            for id_plataforma, nombre in cursor.fetchall():
                plataformas[nombre] = id_plataforma

            return (
                generos,
                clasificaciones,
                motores,
                plataformas
            )

        finally:
            cerrar_conexion(conexion)

    def listar(
        self,
        estado=None,
        busqueda=None,
        id_genero=None
    ):
        conexion = conectar()

        if conexion is None:
            raise ConnectionError(
                "No fue posible conectar con la base de datos."
            )

        try:
            cursor = conexion.cursor()

            cursor.callproc(
                "sp_listar_videogames",
                [
                    estado,
                    busqueda,
                    id_genero
                ]
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
            raise ConnectionError(
                "No fue posible conectar con la base de datos."
            )

        try:
            cursor = conexion.cursor()

            parametros = [
                datos["codigo"],
                datos["titulo"],
                datos["id_genero"],
                datos["id_clasificacion"],
                datos["id_motor"],
                datos["fecha_inicio"],
                datos["fecha_lanzamiento"],
                datos["presupuesto"],
                datos["estado"],
                json.dumps(datos["plataformas"]),
                datos["imagen"],
                None
            ]

            resultado = cursor.callproc(
                "sp_insertar_videogame",
                parametros
            )

            conexion.commit()

            cursor.close()

            return resultado[-1]

        except Exception:
            conexion.rollback()
            raise

        finally:
            cerrar_conexion(conexion)

    def actualizar(self, id_videogame, datos):
        conexion = conectar()

        if conexion is None:
            raise ConnectionError(
                "No fue posible conectar con la base de datos."
            )

        try:
            cursor = conexion.cursor()

            parametros = [
                id_videogame,
                datos["codigo"],
                datos["titulo"],
                datos["id_genero"],
                datos["id_clasificacion"],
                datos["id_motor"],
                datos["fecha_inicio"],
                datos["fecha_lanzamiento"],
                datos["presupuesto"],
                datos["estado"],
                json.dumps(datos["plataformas"]),
                datos["imagen"]
            ]

            cursor.callproc(
                "sp_actualizar_videogame",
                parametros
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

    def eliminar(self, id_videogame):
        conexion = conectar()

        if conexion is None:
            raise ConnectionError(
                "No fue posible conectar con la base de datos."
            )

        try:
            cursor = conexion.cursor()

            cursor.callproc(
                "sp_eliminar_videogame",
                [id_videogame]
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

    def obtener_imagen(self, id_videogame):
        conexion = conectar()

        if conexion is None:
            raise ConnectionError(
                "No fue posible conectar con la base de datos."
            )

        try:
            cursor = conexion.cursor()

            cursor.execute(
                """
                SELECT imagen_portada
                FROM videogames
                WHERE id_videogame = %s
                """,
                (id_videogame,)
            )

            fila = cursor.fetchone()

            cursor.close()

            return fila[0] if fila else None

        finally:
            cerrar_conexion(conexion)