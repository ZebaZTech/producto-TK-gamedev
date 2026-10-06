import tkinter as tk
from tkinter import ttk

# =========================
# TEMA CLARO
# =========================
TEMA_CLARO = {
    "fondo": "#F3F4F6",
    "panel": "#FFFFFF",
    "texto": "#1F2937",
    "principal": "#2563EB",
    "secundario": "#1D4ED8",
    "borde": "#D1D5DB",
    "entrada": "#FFFFFF",
}

# =========================
# TEMA OSCURO
# =========================
TEMA_OSCURO = {
    "fondo": "#111827",
    "panel": "#1F2937",
    "texto": "#F9FAFB",
    "principal": "#3B82F6",
    "secundario": "#2563EB",
    "borde": "#4B5563",
    "entrada": "#374151",
}

tema_actual = "claro"


def obtener_tema():
    if tema_actual == "oscuro":
        return TEMA_OSCURO
    return TEMA_CLARO


def configurar_estilos():
    estilo = ttk.Style()

    try:
        estilo.theme_use("clam")
    except tk.TclError:
        pass

    aplicar_tema_estilos(estilo)


def aplicar_tema_estilos(estilo=None):
    if estilo is None:
        estilo = ttk.Style()

    tema = obtener_tema()

    estilo.configure(
        "TFrame",
        background=tema["fondo"]
    )

    estilo.configure(
        "TLabel",
        background=tema["fondo"],
        foreground=tema["texto"],
        font=("Segoe UI", 10)
    )

    estilo.configure(
        "Titulo.TLabel",
        background=tema["fondo"],
        foreground=tema["principal"],
        font=("Segoe UI", 18, "bold")
    )

    estilo.configure(
        "TLabelframe",
        background=tema["fondo"],
        foreground=tema["texto"]
    )

    estilo.configure(
        "TLabelframe.Label",
        background=tema["fondo"],
        foreground=tema["texto"],
        font=("Segoe UI", 10, "bold")
    )

    estilo.configure(
        "TEntry",
        fieldbackground=tema["entrada"],
        foreground=tema["texto"],
        padding=6
    )

    estilo.configure(
        "TCombobox",
        fieldbackground=tema["entrada"],
        background=tema["entrada"],
        foreground=tema["texto"],
        padding=5
    )

    estilo.configure(
        "TButton",
        font=("Segoe UI", 10),
        padding=8
    )

    estilo.configure(
        "Principal.TButton",
        font=("Segoe UI", 10, "bold"),
        padding=8
    )

    estilo.configure(
        "Treeview",
        background=tema["panel"],
        fieldbackground=tema["panel"],
        foreground=tema["texto"],
        rowheight=30,
        font=("Segoe UI", 9)
    )

    estilo.configure(
        "Treeview.Heading",
        background=tema["principal"],
        foreground="white",
        font=("Segoe UI", 9, "bold")
    )

    estilo.map(
        "Treeview",
        background=[("selected", tema["principal"])],
        foreground=[("selected", "white")]
    )


def cambiar_tema(ventana):
    global tema_actual

    if tema_actual == "claro":
        tema_actual = "oscuro"
    else:
        tema_actual = "claro"

    tema = obtener_tema()

    ventana.configure(bg=tema["fondo"])

    aplicar_tema_estilos()

    actualizar_widgets(ventana)


def actualizar_widgets(widget):
    tema = obtener_tema()

    try:
        if isinstance(widget, (tk.Tk, tk.Frame, tk.LabelFrame)):
            widget.configure(bg=tema["fondo"])

        elif isinstance(widget, tk.Label):
            widget.configure(
                bg=tema["fondo"],
                fg=tema["texto"]
            )

        elif isinstance(widget, tk.Text):
            widget.configure(
                bg=tema["entrada"],
                fg=tema["texto"],
                insertbackground=tema["texto"]
            )

        elif isinstance(widget, tk.Listbox):
            widget.configure(
                bg=tema["entrada"],
                fg=tema["texto"],
                selectbackground=tema["principal"],
                selectforeground="white"
            )

    except tk.TclError:
        pass

    for hijo in widget.winfo_children():
        actualizar_widgets(hijo)


def configurar_ventana(ventana):
    tema = obtener_tema()

    ventana.title("GameDev - Sistema de Gestión")
    ventana.geometry("1100x700")
    ventana.minsize(900, 600)
    ventana.configure(background=tema["fondo"])