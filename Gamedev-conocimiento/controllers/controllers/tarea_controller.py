from tkinter import messagebox

from models.tarea import TareaModel
from views.tareas_view import TareasView


class TareaController:
    """Controlador MVC del módulo de tareas."""

    def __init__(self, ventana):
        self.model = TareaModel()
        self.view = TareasView(ventana, self)
        self.inicializar()

    def inicializar(self):
        self.cargar_catalogos()
        self.cargar_dependencias()
        self.listar()

    def cargar_catalogos(self):
        try:
            videojuegos, modulos, empleados = self.model.cargar_catalogos()
            self.view.establecer_catalogos(
                videojuegos,
                modulos,
                empleados
            )
        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudieron cargar los catálogos:\n{error}"
            )

    def cargar_responsables(self, id_videogame):
        try:
            empleados = self.model.cargar_responsables(id_videogame)
            self.view.establecer_responsables(empleados)
        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudieron cargar los responsables:\n{error}"
            )

    def cargar_dependencias(self, id_tarea_actual=None):
        try:
            tareas = self.model.cargar_dependencias(id_tarea_actual)
            self.view.establecer_dependencias(tareas)
        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudieron cargar las dependencias:\n{error}"
            )

    def listar(self):
        try:
            videojuego = self.view.cbo_filtro_videojuego.get().strip()
            estado = self.view.cbo_filtro_estado.get().strip()
            responsable = self.view.cbo_filtro_responsable.get().strip()

            id_videojuego = None
            id_responsable = None

            if videojuego and videojuego != "Todos":
                id_videojuego = self.view.videojuegos.get(videojuego)

            if not estado or estado == "Todos":
                estado = None

            if responsable and responsable != "Todos":
                id_responsable = self.view.empleados.get(responsable)

            filas = self.model.listar(
                id_videojuego,
                estado,
                id_responsable
            )

            self.view.mostrar_registros(filas)

        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudieron listar las tareas:\n{error}"
            )

    def guardar(self, datos):
        try:
            nuevo_id = self.model.insertar(datos)

            messagebox.showinfo(
                "Éxito",
                f"Tarea registrada correctamente.\n\nID: {nuevo_id}"
            )

            self.view.nuevo()
            self.listar()

        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudo guardar la tarea:\n{error}"
            )

    def actualizar(self, id_tarea, datos):
        try:
            self.model.actualizar(id_tarea, datos)

            messagebox.showinfo(
                "Éxito",
                "Tarea actualizada correctamente."
            )

            self.view.nuevo()
            self.listar()

        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudo actualizar la tarea:\n{error}"
            )

    def eliminar(self, id_tarea):
        try:
            self.model.eliminar(id_tarea)

            messagebox.showinfo(
                "Éxito",
                "Tarea eliminada correctamente."
            )

            self.view.nuevo()
            self.listar()

        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudo eliminar la tarea:\n{error}"
            )
