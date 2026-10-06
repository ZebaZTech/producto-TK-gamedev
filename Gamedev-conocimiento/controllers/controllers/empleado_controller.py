from tkinter import messagebox

from models.empleado import EmpleadoModel
from views.empleados_view import EmpleadosView


class EmpleadoController:
    """Controlador MVC del módulo de empleados."""

    def __init__(self, ventana):
        self.model = EmpleadoModel()
        self.view = EmpleadosView(ventana, self)
        self.inicializar()

    def inicializar(self):
        self.cargar_catalogos()
        self.listar()

    def cargar_catalogos(self):
        try:
            especialidades, habilidades = self.model.cargar_catalogos()
            self.view.establecer_catalogos(especialidades, habilidades)
        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudieron cargar los catálogos:\n{error}"
            )

    def listar(self):
        try:
            especialidad = self.view.cbo_filtro_especialidad.get().strip()

            if especialidad == "Todas" or not especialidad:
                id_especialidad = None
            else:
                id_especialidad = self.view.especialidades.get(especialidad)

            busqueda = self.view.txt_busqueda.get().strip() or None
            solo_activos = 1 if self.view.var_solo_activos.get() else 0

            filas = self.model.listar(
                id_especialidad,
                solo_activos,
                busqueda
            )
            self.view.mostrar_registros(filas)
        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudieron listar los empleados:\n{error}"
            )

    def guardar(self, datos):
        try:
            nuevo_id = self.model.insertar(datos)
            messagebox.showinfo(
                "Éxito",
                f"Empleado registrado correctamente.\nID: {nuevo_id}"
            )
            self.view.nuevo()
            self.listar()
        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudo guardar el empleado:\n{error}"
            )

    def actualizar(self, id_empleado, datos):
        try:
            self.model.actualizar(id_empleado, datos)
            messagebox.showinfo(
                "Éxito",
                "Empleado actualizado correctamente."
            )
            self.view.nuevo()
            self.listar()
        except Exception as error:
            messagebox.showerror(
                "Error",
                f"No se pudo actualizar:\n{error}"
            )

    def eliminar(self, id_empleado):
        try:
            self.model.eliminar(id_empleado)
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

    def obtener_datos_extra(self, id_empleado):
        try:
            return self.model.obtener_datos_extra(id_empleado)
        except Exception:
            return "", None, set()
