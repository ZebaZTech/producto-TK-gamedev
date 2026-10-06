import mysql.connector
from mysql.connector import Error


# Configuración de la base de datos
DB_CONFIG = {
    "host": "localhost",
    "port": 3306,
    "user": "root",
    "password": "", # CONTRASEÑA
    "database": "gamedev"
}


def conectar():
    """
    Crea y retorna una conexión con la base de datos GameDev.
    """
    try:
        conexion = mysql.connector.connect(**DB_CONFIG)

        if conexion.is_connected():
            return conexion

    except Error as error:
        print(f"Error al conectar con MySQL: {error}")

    return None


def cerrar_conexion(conexion):
    """
    Cierra la conexión con la base de datos.
    """
    if conexion is not None and conexion.is_connected():
        conexion.close()


def probar_conexion():
    """
    Prueba si la conexión con MySQL funciona correctamente.
    """
    conexion = conectar()

    if conexion:
        print("Conexión con MySQL establecida correctamente.")
        cerrar_conexion(conexion)
        return True

    print("No fue posible conectar con MySQL.")
    return False


if __name__ == "__main__":
    probar_conexion()