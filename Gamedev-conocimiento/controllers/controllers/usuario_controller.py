from tkinter import messagebox

from models.usuario import UsuarioModel
from views.usuarios_view import UsuariosView


class UsuarioController:
    """Controlador MVC del módulo de usuarios."""

    def __init__(self, ventana):
        self.model = UsuarioModel()
        self.view = UsuariosView(ventana, self)
        self.inicializar()

    def inicializar(self):
        self.cargar_catalogos()
        self.listar()

    def cargar_catalogos(self):
        try:
            plataformas = self.model.cargar_catalogos()
            self.view.establecer_catalogos(plataformas)
        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudieron cargar las plataformas:\n{error}"
            )

    def listar(self):
        try:
            estado = self.view.cbo_filtro_estado.get().strip()

            if estado == "Todos" or not estado:
                estado = None

            busqueda = self.view.txt_busqueda.get().strip() or None

            filas = self.model.listar(estado, busqueda)
            self.view.mostrar_registros(filas)

        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudieron listar los usuarios:\n{error}"
            )

    def guardar(self, datos):
        try:
            nuevo_id = self.model.insertar(datos)

            messagebox.showinfo(
                "Éxito",
                f"Usuario registrado correctamente.\nID: {nuevo_id}"
            )

            self.view.nuevo()
            self.listar()

        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudo guardar el usuario:\n{error}"
            )

    def actualizar(self, id_usuario, datos):
        try:
            self.model.actualizar(id_usuario, datos)

            messagebox.showinfo(
                "Éxito",
                "Usuario actualizado correctamente."
            )

            self.view.nuevo()
            self.listar()

        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudo actualizar:\n{error}"
            )

    def eliminar(self, id_usuario):
        try:
            self.model.eliminar(id_usuario)

            messagebox.showinfo(
                "Éxito",
                "Operación realizada correctamente."
            )

            self.view.nuevo()
            self.listar()

        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudo eliminar:\n{error}"
            )

    def obtener_datos_extra(self, id_usuario):
        try:
            return self.model.obtener_datos_extra(id_usuario)
        except Exception:
            return set(), "", ""
