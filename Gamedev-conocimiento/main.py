# Importamos Tkinter para crear la ventana principal
import tkinter as tk

# Importamos ttk para utilizar componentes como Notebook y Frame
from tkinter import ttk
from utils.estilos import configurar_estilos, configurar_ventana


# Importamos las clases de cada uno de los módulos
from controllers.videojuego_controller import VideojuegoController
from controllers.empleado_controller import EmpleadoController
from controllers.usuario_controller import UsuarioController
from controllers.tarea_controller import TareaController

from utils.estilos import (
    configurar_estilos,
    configurar_ventana,
    cambiar_tema
)


# Clase principal de la aplicación
class GameDevApp:

    # Constructor de la clase
    def __init__(self, ventana):

        # Guardamos la ventana recibida para utilizarla dentro de la clase
        self.ventana = ventana

        # Configuramos el título de la aplicación
        self.ventana.title("GameDev - Sistema de Gestión")

        # Definimos el tamaño de la ventana
        self.ventana.geometry("1300x800")

        # Evitamos que el usuario cambie el tamaño de la ventana
        self.ventana.resizable(True, True)

        # Llamamos al método encargado de crear la interfaz
        self.crear_interfaz()




    # Método que crea la estructura principal de la aplicación
    def crear_interfaz(self):

        # Creamos el título principal
        titulo = tk.Label(
            self.ventana,
            text="GAMEDEV",
            font=("Arial", 24, "bold")
        )

        # Ubicamos el título en la ventana
        titulo.pack(pady=15)


        # Creamos un subtítulo para describir la aplicación
        subtitulo = tk.Label(
            self.ventana,
            text="Sistema de gestión para desarrollo de videojuegos",
            font=("Arial", 11)
        )

        # Ubicamos el subtítulo
        subtitulo.pack(pady=5)

        barra = tk.Frame(
            self.ventana,
            bg="#F3F4F6"
        )
        barra.pack(fill="x", padx=20, pady=(5, 0))

        boton_tema = tk.Button(
            barra,
            text="🌙 Tema oscuro",
            command=lambda: cambiar_tema(self.ventana),
            bg="#2563EB",
            fg="white",
            font=("Segoe UI", 10, "bold"),
            relief="flat",
            padx=15,
            pady=6,
            cursor="hand2"
        )
        boton_tema.pack(side="right")


        # Creamos el componente Notebook que permitirá trabajar con pestañas
        self.notebook = ttk.Notebook(self.ventana)

        # Hacemos que el Notebook ocupe el espacio disponible
        self.notebook.pack(
            fill="both",
            expand=True,
            padx=20,
            pady=20
        )


        # Creamos un Frame para cada módulo
        self.tab_videojuegos = ttk.Frame(self.notebook)
        self.tab_empleados = ttk.Frame(self.notebook)
        self.tab_usuarios = ttk.Frame(self.notebook)
        self.tab_tareas = ttk.Frame(self.notebook)


        # Agregamos cada Frame como una pestaña del Notebook
        self.notebook.add(
            self.tab_videojuegos,
            text="Videojuegos"
        )

        self.notebook.add(
            self.tab_empleados,
            text="Empleados"
        )

        self.notebook.add(
            self.tab_usuarios,
            text="Usuarios"
        )

        self.notebook.add(
            self.tab_tareas,
            text="Tareas"
        )


        # Instanciamos cada módulo dentro de su pestaña correspondiente
        VideojuegoController(self.tab_videojuegos)
        EmpleadoController(self.tab_empleados)
        UsuarioController(self.tab_usuarios)
        TareaController(self.tab_tareas)


# Punto de entrada de la aplicación
if __name__ == "__main__":

    # Creamos la ventana principal de Tkinter
    ventana = tk.Tk()

    # Icono principal de la aplicación
    ventana.iconbitmap("assets/favicons/icono pp.ico")

    # Configuramos ventana y estilos
    configurar_ventana(ventana)
    configurar_estilos()

    # Creamos una instancia de nuestra aplicación
    app = GameDevApp(ventana)

    # Iniciamos el ciclo principal de Tkinter
    ventana.mainloop()