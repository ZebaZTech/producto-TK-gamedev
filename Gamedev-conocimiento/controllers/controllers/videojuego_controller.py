from tkinter import messagebox

from models.videojuego import VideojuegoModel
from views.videojuegos_view import VideojuegosView


class VideojuegoController:
    """Controlador MVC del módulo de videojuegos."""

    def __init__(self, ventana):
        self.model = VideojuegoModel()
        self.view = VideojuegosView(
            ventana,
            self
        )

        # Cargar información inicial
        self.cargar_catalogos()
        self.listar_videojuegos()

    # =========================================================
    # CATÁLOGOS
    # =========================================================

    def cargar_catalogos(self):
        try:
            (
                generos,
                clasificaciones,
                motores,
                plataformas
            ) = self.model.cargar_catalogos()

            self.view.establecer_catalogos(
                generos,
                clasificaciones,
                motores,
                plataformas
            )

        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudieron cargar los catálogos.\n\n{error}"
            )

    # =========================================================
    # LISTAR
    # =========================================================

    def listar_videojuegos(self):
        try:
            estado = self.view.cbo_filtro_estado.get().strip()
            busqueda = self.view.txt_busqueda.get().strip()
            genero = self.view.cbo_filtro_genero.get().strip()

            if estado == "Todos" or not estado:
                estado = None

            if not busqueda:
                busqueda = None

            if genero == "Todos" or not genero:
                id_genero = None
            else:
                id_genero = self.view.generos.get(genero)

            filas = self.model.listar(
                estado=estado,
                busqueda=busqueda,
                id_genero=id_genero
            )

            self.view.mostrar_registros(filas)

        except Exception as error:
            messagebox.showerror(
                "Error al listar",
                f"No fue posible cargar los videojuegos.\n\n{error}"
            )

    # =========================================================
    # GUARDAR
    # =========================================================

    def guardar(self, datos):
        try:
            nuevo_id = self.model.insertar(datos)

            messagebox.showinfo(
                "Éxito",
                f"Videojuego registrado correctamente.\n"
                f"ID: {nuevo_id}"
            )

            self.view.nuevo()
            self.listar_videojuegos()

        except Exception as error:
            messagebox.showerror(
                "Error al guardar",
                str(error)
            )

    # =========================================================
    # ACTUALIZAR
    # =========================================================

    def actualizar(self, id_videogame, datos):
        try:
            self.model.actualizar(
                id_videogame,
                datos
            )

            messagebox.showinfo(
                "Actualización",
                "Videojuego actualizado correctamente."
            )

            self.view.nuevo()
            self.listar_videojuegos()

        except Exception as error:
            messagebox.showerror(
                "Error al actualizar",
                f"No fue posible actualizar el videojuego.\n\n{error}"
            )

    # =========================================================
    # ELIMINAR
    # =========================================================

    def eliminar(self, id_videogame):
        try:
            self.model.eliminar(
                id_videogame
            )

            messagebox.showinfo(
                "Eliminación",
                "Videojuego eliminado correctamente."
            )

            self.view.nuevo()
            self.listar_videojuegos()

        except Exception as error:
            messagebox.showerror(
                "Error al eliminar",
                f"No fue posible eliminar el videojuego.\n\n{error}"
            )

    # =========================================================
    # IMAGEN ACTUAL
    # =========================================================

    def obtener_imagen(self, id_videogame):
        try:
            return self.model.obtener_imagen(
                id_videogame
            )
        except Exception:
            return None