from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4, landscape
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import cm
from reportlab.platypus import (
    SimpleDocTemplate,
    Table,
    TableStyle,
    Paragraph,
    Spacer
)


# ============================================================
# EXPORTACIÓN A PDF
# ============================================================

def exportar_pdf(
    datos,
    encabezados,
    nombre_archivo,
    titulo="Reporte GameDev",
    carpeta="exports/pdf"
):
    """
    Genera un reporte PDF con los datos proporcionados.
    """

    # Crear carpeta de destino.
    ruta_carpeta = Path(carpeta)
    ruta_carpeta.mkdir(parents=True, exist_ok=True)

    ruta_archivo = ruta_carpeta / nombre_archivo

    # Crear documento.
    documento = SimpleDocTemplate(
        str(ruta_archivo),
        pagesize=landscape(A4),
        rightMargin=1 * cm,
        leftMargin=1 * cm,
        topMargin=1 * cm,
        bottomMargin=1 * cm
    )

    estilos = getSampleStyleSheet()

    elementos = []

    # --------------------------------------------------------
    # Título
    # --------------------------------------------------------

    elementos.append(
        Paragraph(
            titulo,
            estilos["Title"]
        )
    )

    elementos.append(Spacer(1, 0.5 * cm))

    # --------------------------------------------------------
    # Preparar información de la tabla
    # --------------------------------------------------------

    tabla_datos = [encabezados]

    for registro in datos:
        tabla_datos.append(
            [str(valor) if valor is not None else "" for valor in registro]
        )

    # --------------------------------------------------------
    # Crear tabla
    # --------------------------------------------------------

    tabla = Table(
        tabla_datos,
        repeatRows=1
    )

    tabla.setStyle(
        TableStyle([
            ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#2563EB")),
            ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
            ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
            ("ALIGN", (0, 0), (-1, -1), "CENTER"),
            ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
            ("GRID", (0, 0), (-1, -1), 0.5, colors.grey),
            ("FONTSIZE", (0, 0), (-1, -1), 8),
            ("ROWBACKGROUNDS", (0, 1), (-1, -1),
             [colors.white, colors.HexColor("#F3F4F6")])
        ])
    )

    elementos.append(tabla)

    # --------------------------------------------------------
    # Generar PDF
    # --------------------------------------------------------

    documento.build(elementos)

    return str(ruta_archivo)