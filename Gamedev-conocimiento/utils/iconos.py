from pathlib import Path
from PIL import Image, ImageTk


# ============================================================
# CARGA DE ICONOS
# ============================================================

def cargar_icono(nombre, ancho=24, alto=24):
    """
    Busca un icono dentro de assets/icons y lo prepara
    para utilizarlo en Tkinter.
    """

    ruta = Path("assets") / "icons" / nombre

    if not ruta.exists():
        return None

    imagen = Image.open(ruta)
    imagen = imagen.resize((ancho, alto))

    return ImageTk.PhotoImage(imagen)


# ============================================================
# CARGA DE FAVICON
# ============================================================

def cargar_favicon(ventana):
    """
    Configura el favicon de la ventana principal.
    """

    ruta = Path("assets") / "favicons" / "favicon.png"

    if not ruta.exists():
        return

    icono = Image.open(ruta)

    if icono.mode != "RGBA":
        icono = icono.convert("RGBA")

    icono_tk = ImageTk.PhotoImage(icono)

    ventana.iconphoto(True, icono_tk)

    # Evita que Python elimine la referencia del icono.
    ventana._favicon = icono_tk