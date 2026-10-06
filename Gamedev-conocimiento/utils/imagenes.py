from pathlib import Path
from PIL import Image, ImageTk
import shutil


# ============================================================
# CONFIGURACIÓN DE IMÁGENES
# ============================================================

FORMATOS_PERMITIDOS = {".jpg", ".jpeg", ".png", ".gif"}
TAMANO_MAXIMO_MB = 5


# ============================================================
# VALIDAR IMAGEN
# ============================================================

def validar_imagen(ruta):
    """
    Verifica que una imagen:
    - Exista.
    - Tenga un formato permitido.
    - No supere el tamaño máximo establecido.
    """

    archivo = Path(ruta)

    if not archivo.exists():
        return False, "La imagen seleccionada no existe."

    if archivo.suffix.lower() not in FORMATOS_PERMITIDOS:
        return False, "Solo se permiten imágenes JPG, JPEG, PNG o GIF."

    tamano_mb = archivo.stat().st_size / (1024 * 1024)

    if tamano_mb > TAMANO_MAXIMO_MB:
        return False, f"La imagen no puede superar los {TAMANO_MAXIMO_MB} MB."

    return True, ""


# ============================================================
# GUARDAR IMAGEN EN EL PROYECTO
# ============================================================

def guardar_imagen(ruta_origen, carpeta_destino, nombre):
    """
    Copia una imagen seleccionada por el usuario a la carpeta
    correspondiente del proyecto.
    """

    valido, mensaje = validar_imagen(ruta_origen)

    if not valido:
        raise ValueError(mensaje)

    carpeta = Path(carpeta_destino)
    carpeta.mkdir(parents=True, exist_ok=True)

    extension = Path(ruta_origen).suffix.lower()
    ruta_destino = carpeta / f"{nombre}{extension}"

    shutil.copy2(ruta_origen, ruta_destino)

    return str(ruta_destino)


# ============================================================
# REDIMENSIONAR IMAGEN
# ============================================================

def redimensionar_imagen(ruta, ancho=300, alto=300):
    """
    Abre una imagen y crea una versión redimensionada.
    """

    imagen = Image.open(ruta)
    imagen.thumbnail((ancho, alto))

    return imagen


# ============================================================
# PREPARAR IMAGEN PARA TKINTER
# ============================================================

def cargar_imagen_tk(ruta, ancho=200, alto=200):
    """
    Convierte una imagen en un objeto compatible con Tkinter.
    """

    imagen = Image.open(ruta)
    imagen.thumbnail((ancho, alto))

    return ImageTk.PhotoImage(imagen)