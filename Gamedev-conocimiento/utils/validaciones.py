import re
from datetime import datetime
from pathlib import Path


# ============================================================
# VALIDACIÓN DE CAMPOS DE TEXTO
# ============================================================

def validar_texto(valor, nombre_campo, minimo=2, maximo=100):
    """
    Valida que un campo de texto:
    - No esté vacío.
    - Cumpla una longitud mínima.
    - No supere una longitud máxima.
    """

    valor = valor.strip()

    if not valor:
        return False, f"El campo {nombre_campo} es obligatorio."

    if len(valor) < minimo:
        return False, f"{nombre_campo} debe tener mínimo {minimo} caracteres."

    if len(valor) > maximo:
        return False, f"{nombre_campo} no puede superar los {maximo} caracteres."

    return True, ""


# ============================================================
# VALIDACIÓN DE NÚMEROS ENTEROS
# ============================================================

def validar_entero(valor, nombre_campo):
    """
    Comprueba que el valor ingresado sea un número entero.
    """

    valor = valor.strip()

    if not valor:
        return False, f"El campo {nombre_campo} es obligatorio."

    try:
        int(valor)
        return True, ""

    except ValueError:
        return False, f"{nombre_campo} debe contener solamente números."


# ============================================================
# VALIDACIÓN DE NÚMEROS DECIMALES
# ============================================================

def validar_decimal(valor, nombre_campo):
    """
    Comprueba que el valor ingresado sea un número decimal.
    """

    valor = valor.strip().replace(",", ".")

    if not valor:
        return False, f"El campo {nombre_campo} es obligatorio."

    try:
        numero = float(valor)

        if numero < 0:
            return False, f"{nombre_campo} no puede ser negativo."

        return True, ""

    except ValueError:
        return False, f"{nombre_campo} debe contener un número válido."


# ============================================================
# VALIDACIÓN DE CORREO ELECTRÓNICO
# ============================================================

def validar_email(email):
    """
    Valida que un correo tenga una estructura básica válida.
    """

    patron = r"^[\w\.-]+@[\w\.-]+\.\w+$"

    if re.match(patron, email.strip()):
        return True, ""

    return False, "Ingrese un correo electrónico válido."


# ============================================================
# VALIDACIÓN DE FECHAS
# ============================================================

def validar_fecha(fecha, nombre_campo):
    """
    Valida una fecha en formato DD/MM/YYYY.
    """

    if not fecha:
        return False, f"El campo {nombre_campo} es obligatorio."

    try:
        datetime.strptime(fecha, "%d/%m/%Y")
        return True, ""

    except ValueError:
        return False, f"{nombre_campo} debe tener formato DD/MM/YYYY."


# ============================================================
# VALIDACIÓN DE IMÁGENES
# ============================================================

def validar_imagen(ruta, nombre_campo="Imagen"):
    """
    Comprueba que el archivo exista y tenga un formato permitido.

    Formatos permitidos:
    JPG, JPEG, PNG y GIF.
    """

    if not ruta:
        return False, f"No se ha seleccionado {nombre_campo}."

    archivo = Path(ruta)

    if not archivo.exists():
        return False, f"El archivo seleccionado no existe."

    extensiones_permitidas = {".jpg", ".jpeg", ".png", ".gif"}

    if archivo.suffix.lower() not in extensiones_permitidas:
        return False, (
            f"{nombre_campo} debe estar en formato "
            "JPG, JPEG, PNG o GIF."
        )

    return True, ""


# ============================================================
# VALIDACIÓN DE PRESUPUESTO
# ============================================================

def validar_presupuesto(valor):
    """
    Valida específicamente el presupuesto de un videojuego.
    """

    valido, mensaje = validar_decimal(valor, "Presupuesto")

    if not valido:
        return False, mensaje

    if float(valor.replace(",", ".")) == 0:
        return False, "El presupuesto debe ser mayor que 0."

    return True, ""


# ============================================================
# PRUEBA DEL MÓDULO
# ============================================================

if __name__ == "__main__":
    print(validar_texto("GameDev", "Título"))
    print(validar_entero("25", "Código"))
    print(validar_decimal("150000", "Presupuesto"))
    print(validar_email("usuario@gmail.com"))