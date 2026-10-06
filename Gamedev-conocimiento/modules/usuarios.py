import tkinter as tk
from tkinter import ttk, messagebox
import json
import re
from datetime import datetime

from database.conexion import conectar, cerrar_conexion
from utils.exportar_excel import exportar_excel
from utils.exportar_pdf import exportar_pdf



class Usuarios:

    def __init__(self, parent):

        self.parent = parent
        self.id_usuario = None
        self.plataformas = {}

        self.crear_interfaz()
        self.cargar_catalogos()
        self.listar_usuarios()

    # =========================================================
    # INTERFAZ
    # =========================================================

    def crear_interfaz(self):

        contenedor = ttk.Frame(self.parent, padding=15)
        contenedor.pack(fill="both", expand=True)

        ttk.Label(
            contenedor,
            text="Gestión de Usuarios",
            style="Titulo.TLabel"
        ).pack(anchor="w", pady=(0, 10))

        formulario = ttk.LabelFrame(
            contenedor,
            text="Información del usuario",
            padding=10
        )
        formulario.pack(fill="x")

        # Usuario
        ttk.Label(
            formulario,
            text="Nombre de usuario:"
        ).grid(row=0, column=0, padx=5, pady=5, sticky="w")

        self.txt_usuario = ttk.Entry(
            formulario,
            width=28
        )
        self.txt_usuario.grid(row=0, column=1, padx=5)

        # Correo
        ttk.Label(
            formulario,
            text="Correo:"
        ).grid(row=0, column=2, padx=5, sticky="w")

        self.txt_correo = ttk.Entry(
            formulario,
            width=28
        )
        self.txt_correo.grid(row=0, column=3, padx=5)

        # Contraseña
        ttk.Label(
            formulario,
            text="Contraseña:"
        ).grid(row=0, column=4, padx=5, sticky="w")

        self.txt_password = ttk.Entry(
            formulario,
            width=25,
            show="*"
        )
        self.txt_password.grid(row=0, column=5, padx=5)

        # Estado
        ttk.Label(
            formulario,
            text="Estado:"
        ).grid(row=1, column=0, padx=5, pady=5, sticky="w")

        self.cbo_estado = ttk.Combobox(
            formulario,
            state="readonly",
            values=[
                "activo",
                "inactivo",
                "suspendido"
            ],
            width=25
        )
        self.cbo_estado.set("activo")
        self.cbo_estado.grid(row=1, column=1, padx=5)

        # Plataformas
        plataformas_frame = ttk.LabelFrame(
            formulario,
            text="Plataformas",
            padding=5
        )
        plataformas_frame.grid(
            row=1,
            column=2,
            columnspan=2,
            padx=5,
            pady=5,
            sticky="w"
        )

        self.lista_plataformas = tk.Listbox(
            plataformas_frame,
            selectmode="multiple",
            height=4,
            width=30
        )
        self.lista_plataformas.pack()

        # Preferencias
        preferencias_frame = ttk.LabelFrame(
            formulario,
            text="Preferencias",
            padding=5
        )
        preferencias_frame.grid(
            row=1,
            column=4,
            columnspan=2,
            padx=5,
            pady=5
        )

        ttk.Label(
            preferencias_frame,
            text="Clave:"
        ).grid(row=0, column=0, padx=3)

        self.txt_clave = ttk.Entry(
            preferencias_frame,
            width=15
        )
        self.txt_clave.grid(row=0, column=1)

        ttk.Label(
            preferencias_frame,
            text="Valor:"
        ).grid(row=1, column=0, padx=3)

        self.txt_valor = ttk.Entry(
            preferencias_frame,
            width=15
        )
        self.txt_valor.grid(row=1, column=1)

        # =====================================================
        # BOTONES
        # =====================================================

        botones = ttk.Frame(contenedor)
        botones.pack(fill="x", pady=8)

        self.crear_boton(
            botones,
            "Nuevo",
            self.nuevo,
            "#2563EB"
        )

        self.crear_boton(
            botones,
            "Guardar",
            self.guardar,
            "#16A34A"
        )

        self.crear_boton(
            botones,
            "Actualizar",
            self.actualizar,
            "#F59E0B"
        )

        self.crear_boton(
            botones,
            "Eliminar",
            self.eliminar,
            "#DC2626"
        )

        self.crear_boton(
            botones,
            "Refrescar",
            self.listar_usuarios,
            "#6B7280"
        )

        self.crear_boton(
            botones,
            "Excel",
            self.exportar_excel_usuarios,
            "#15803D"
        )

        self.crear_boton(
            botones,
            "PDF",
            self.exportar_pdf_usuarios,
            "#B91C1C"
        )

        # =====================================================
        # FILTROS
        # =====================================================

        filtros = ttk.LabelFrame(
            contenedor,
            text="Filtros",
            padding=8
        )
        filtros.pack(fill="x", pady=5)

        ttk.Label(
            filtros,
            text="Buscar:"
        ).pack(side="left", padx=5)

        self.txt_busqueda = ttk.Entry(
            filtros,
            width=30
        )
        self.txt_busqueda.pack(side="left", padx=5)

        ttk.Label(
            filtros,
            text="Estado:"
        ).pack(side="left", padx=5)

        self.cbo_filtro_estado = ttk.Combobox(
            filtros,
            state="readonly",
            values=[
                "Todos",
                "activo",
                "inactivo",
                "suspendido"
            ],
            width=15
        )
        self.cbo_filtro_estado.set("Todos")
        self.cbo_filtro_estado.pack(side="left", padx=5)

        tk.Button(
            filtros,
            text="Aplicar filtros",
            command=self.listar_usuarios,
            bg="#2563EB",
            fg="white",
            relief="flat",
            padx=12,
            pady=5,
            cursor="hand2"
        ).pack(side="left", padx=5)

        # =====================================================
        # TABLA
        # =====================================================

        tabla_frame = ttk.Frame(contenedor)
        tabla_frame.pack(
            fill="both",
            expand=True,
            pady=10
        )

        columnas = (
            "id",
            "usuario",
            "correo",
            "registro",
            "estado",
            "plataformas",
            "juegos",
            "horas",
            "logros",
            "compras",
            "preferencias"
        )

        self.tabla = ttk.Treeview(
            tabla_frame,
            columns=columnas,
            show="headings"
        )

        encabezados = {
            "id": "ID",
            "usuario": "Usuario",
            "correo": "Correo",
            "registro": "Registro",
            "estado": "Estado",
            "plataformas": "Plataformas",
            "juegos": "Juegos",
            "horas": "Horas",
            "logros": "Logros",
            "compras": "Compras",
            "preferencias": "Preferencias"
        }

        for columna in columnas:

            self.tabla.heading(
                columna,
                text=encabezados[columna]
            )

            self.tabla.column(
                columna,
                width=120,
                anchor="center"
            )

        self.tabla.column("id", width=50)
        self.tabla.column("usuario", width=130)
        self.tabla.column("correo", width=180)
        self.tabla.column("plataformas", width=180)
        self.tabla.column("preferencias", width=200)

        scroll = ttk.Scrollbar(
            tabla_frame,
            orient="vertical",
            command=self.tabla.yview
        )

        self.tabla.configure(
            yscrollcommand=scroll.set
        )

        self.tabla.pack(
            side="left",
            fill="both",
            expand=True
        )

        scroll.pack(
            side="right",
            fill="y"
        )

        self.tabla.bind(
            "<<TreeviewSelect>>",
            self.seleccionar_registro
        )

    # =========================================================
    # BOTONES
    # =========================================================

    def crear_boton(
        self,
        parent,
        texto,
        comando,
        color
    ):

        tk.Button(
            parent,
            text=texto,
            command=comando,
            font=("Segoe UI", 10, "bold"),
            bg=color,
            fg="white",
            relief="flat",
            padx=15,
            pady=6,
            cursor="hand2"
        ).pack(
            side="left",
            padx=5
        )

    # =========================================================
    # CATÁLOGOS
    # =========================================================

    def cargar_catalogos(self):

        conexion = None

        try:

            conexion = conectar()

            if conexion is None:
                return

            cursor = conexion.cursor()

            cursor.execute("""
                SELECT id_plataforma, nombre
                FROM plataformas
                ORDER BY nombre
            """)

            self.plataformas.clear()
            self.lista_plataformas.delete(
                0,
                tk.END
            )

            for fila in cursor.fetchall():

                self.plataformas[fila[1]] = fila[0]

                self.lista_plataformas.insert(
                    tk.END,
                    fila[1]
                )

            cursor.close()

        except Exception as e:

            messagebox.showerror(
                "Error",
                f"No se pudieron cargar las plataformas:\n{e}"
            )

        finally:

            if conexion:
                cerrar_conexion(conexion)

    # =========================================================
    # VALIDACIÓN
    # =========================================================

    def obtener_datos(self):

        usuario = self.txt_usuario.get().strip()
        correo = self.txt_correo.get().strip()
        password = self.txt_password.get()

        if not usuario:

            raise ValueError(
                "El nombre de usuario es obligatorio."
            )

        if len(usuario) < 3 or len(usuario) > 50:

            raise ValueError(
                "El usuario debe tener entre 3 y 50 caracteres."
            )

        if not correo:

            raise ValueError(
                "El correo es obligatorio."
            )

        patron = r"^[^@\s]+@[^@\s]+\.[^@\s]+$"

        if not re.match(patron, correo):

            raise ValueError(
                "El correo electrónico no es válido."
            )

        estado = self.cbo_estado.get()

        if estado not in (
            "activo",
            "inactivo",
            "suspendido"
        ):

            raise ValueError(
                "Seleccione un estado válido."
            )

        # Plataformas
        plataformas = []

        for indice in self.lista_plataformas.curselection():

            nombre = self.lista_plataformas.get(indice)

            plataformas.append(
                self.plataformas[nombre]
            )

        # Preferencia
        preferencias = []

        clave = self.txt_clave.get().strip()
        valor = self.txt_valor.get().strip()

        if clave and valor:

            preferencias.append({
                "clave": clave,
                "valor": valor
            })

        return {
            "usuario": usuario,
            "correo": correo,
            "password": password,
            "estado": estado,
            "plataformas": json.dumps(
                plataformas
            ),
            "preferencias": json.dumps(
                preferencias
            )
        }

    # =========================================================
    # GUARDAR
    # =========================================================

    def guardar(self):

        try:

            datos = self.obtener_datos()

            if not datos["password"]:

                raise ValueError(
                    "La contraseña es obligatoria al crear un usuario."
                )

            conexion = conectar()

            if conexion is None:
                return

            cursor = conexion.cursor()

            resultado = cursor.callproc(
                "sp_insertar_usuario",
                [
                    datos["usuario"],
                    datos["correo"],
                    datos["password"],
                    datos["estado"],
                    datos["plataformas"],
                    datos["preferencias"],
                    None
                ]
            )

            conexion.commit()

            nuevo_id = resultado[-1]

            cursor.close()

            messagebox.showinfo(
                "Éxito",
                f"Usuario registrado correctamente.\nID: {nuevo_id}"
            )

            self.nuevo()
            self.listar_usuarios()

        except Exception as e:

            messagebox.showerror(
                "Error",
                f"No se pudo guardar el usuario:\n{e}"
            )

        finally:

            if "conexion" in locals() and conexion:
                cerrar_conexion(conexion)

    # =========================================================
    # LISTAR
    # =========================================================

    def listar_usuarios(self):

        conexion = None

        try:

            for item in self.tabla.get_children():
                self.tabla.delete(item)

            estado = self.cbo_filtro_estado.get()

            if estado == "Todos":
                estado = None

            busqueda = self.txt_busqueda.get().strip()

            if not busqueda:
                busqueda = None

            conexion = conectar()

            if conexion is None:
                return

            cursor = conexion.cursor()

            cursor.callproc(
                "sp_listar_usuarios",
                [
                    estado,
                    busqueda
                ]
            )

            for resultado in cursor.stored_results():

                for fila in resultado.fetchall():

                    self.tabla.insert(
                        "",
                        "end",
                        values=fila
                    )

            cursor.close()

        except Exception as e:

            messagebox.showerror(
                "Error",
                f"No se pudieron listar los usuarios:\n{e}"
            )

        finally:

            if conexion:
                cerrar_conexion(conexion)

    # =========================================================
    # SELECCIONAR
    # =========================================================

    def seleccionar_registro(self, event=None):

        seleccion = self.tabla.selection()

        if not seleccion:
            return

        valores = self.tabla.item(
            seleccion[0],
            "values"
        )

        if not valores:
            return

        self.id_usuario = valores[0]

        self.txt_usuario.delete(
            0,
            tk.END
        )
        self.txt_usuario.insert(
            0,
            valores[1]
        )

        self.txt_correo.delete(
            0,
            tk.END
        )
        self.txt_correo.insert(
            0,
            valores[2]
        )

        self.cbo_estado.set(
            valores[4]
        )

        self.txt_password.delete(
            0,
            tk.END
        )

        self.cargar_datos_extra()

    # =========================================================
    # DATOS EXTRA
    # =========================================================

    def cargar_datos_extra(self):

        conexion = None

        try:

            conexion = conectar()

            cursor = conexion.cursor()

            # Plataformas
            cursor.execute("""
                SELECT id_plataforma
                FROM usuario_plataformas
                WHERE id_usuario = %s
            """, (self.id_usuario,))

            plataformas = {
                fila[0]
                for fila in cursor.fetchall()
            }

            self.lista_plataformas.selection_clear(
                0,
                tk.END
            )

            for indice in range(
                self.lista_plataformas.size()
            ):

                nombre = self.lista_plataformas.get(
                    indice
                )

                if self.plataformas.get(nombre) in plataformas:

                    self.lista_plataformas.selection_set(
                        indice
                    )

            # Preferencias
            cursor.execute("""
                SELECT clave, valor
                FROM usuario_preferencias
                WHERE id_usuario = %s
                LIMIT 1
            """, (self.id_usuario,))

            fila = cursor.fetchone()

            self.txt_clave.delete(
                0,
                tk.END
            )

            self.txt_valor.delete(
                0,
                tk.END
            )

            if fila:

                self.txt_clave.insert(
                    0,
                    fila[0]
                )

                self.txt_valor.insert(
                    0,
                    fila[1]
                )

            cursor.close()

        except Exception:
            pass

        finally:

            if conexion:
                cerrar_conexion(conexion)

    # =========================================================
    # ACTUALIZAR
    # =========================================================

    def actualizar(self):

        if not self.id_usuario:

            messagebox.showwarning(
                "Actualizar",
                "Seleccione un usuario."
            )
            return

        confirmar = messagebox.askyesno(
            "Confirmar actualización",
            "¿Desea actualizar este usuario?"
        )

        if not confirmar:
            return

        try:

            datos = self.obtener_datos()

            password = (
                datos["password"]
                if datos["password"]
                else None
            )

            conexion = conectar()

            if conexion is None:
                return

            cursor = conexion.cursor()

            cursor.callproc(
                "sp_actualizar_usuario",
                [
                    self.id_usuario,
                    datos["usuario"],
                    datos["correo"],
                    password,
                    datos["estado"],
                    datos["plataformas"],
                    datos["preferencias"]
                ]
            )

            conexion.commit()

            cursor.close()

            messagebox.showinfo(
                "Éxito",
                "Usuario actualizado correctamente."
            )

            self.nuevo()
            self.listar_usuarios()

        except Exception as e:

            messagebox.showerror(
                "Error",
                f"No se pudo actualizar:\n{e}"
            )

        finally:

            if "conexion" in locals() and conexion:
                cerrar_conexion(conexion)

    # =========================================================
    # ELIMINAR
    # =========================================================

    def eliminar(self):

        if not self.id_usuario:

            messagebox.showwarning(
                "Eliminar",
                "Seleccione un usuario."
            )
            return

        confirmar = messagebox.askyesno(
            "Confirmar eliminación",
            "¿Está seguro de eliminar este usuario?"
        )

        if not confirmar:
            return

        conexion = None

        try:

            conexion = conectar()

            cursor = conexion.cursor()

            cursor.callproc(
                "sp_eliminar_usuario",
                [self.id_usuario]
            )

            conexion.commit()

            cursor.close()

            messagebox.showinfo(
                "Éxito",
                "Operación realizada correctamente."
            )

            self.nuevo()
            self.listar_usuarios()

        except Exception as e:

            messagebox.showerror(
                "Error",
                f"No se pudo eliminar:\n{e}"
            )

        finally:

            if conexion:
                cerrar_conexion(conexion)

    # =========================================================
    # NUEVO
    # =========================================================

    def nuevo(self):

        self.id_usuario = None

        self.txt_usuario.delete(
            0,
            tk.END
        )

        self.txt_correo.delete(
            0,
            tk.END
        )

        self.txt_password.delete(
            0,
            tk.END
        )

        self.cbo_estado.set(
            "activo"
        )

        self.lista_plataformas.selection_clear(
            0,
            tk.END
        )

        self.txt_clave.delete(
            0,
            tk.END
        )

        self.txt_valor.delete(
            0,
            tk.END
        )

    # =========================================================
    # EXCEL
    # =========================================================

    def exportar_excel_usuarios(self):

        filas = [
            self.tabla.item(
                item,
                "values"
            )
            for item in self.tabla.get_children()
        ]

        if not filas:

            messagebox.showwarning(
                "Excel",
                "No hay usuarios para exportar."
            )
            return

        encabezados = [
            self.tabla.heading(columna)["text"]
            for columna in self.tabla["columns"]
        ]

        try:

            nombre = (
                f"usuarios_"
                f"{datetime.now().strftime('%Y%m%d_%H%M%S')}"
                f".xlsx"
            )

            ruta = exportar_excel(
                filas,
                encabezados,
                nombre
            )

            messagebox.showinfo(
                "Excel",
                f"Archivo generado correctamente.\n\n{ruta}"
            )

        except Exception as e:

            messagebox.showerror(
                "Excel",
                str(e)
            )

    # =========================================================
    # PDF
    # =========================================================

    def exportar_pdf_usuarios(self):

        filas = [
            self.tabla.item(
                item,
                "values"
            )
            for item in self.tabla.get_children()
        ]

        if not filas:

            messagebox.showwarning(
                "PDF",
                "No hay usuarios para exportar."
            )
            return

        encabezados = [
            self.tabla.heading(columna)["text"]
            for columna in self.tabla["columns"]
        ]

        try:

            nombre = (
                f"usuarios_"
                f"{datetime.now().strftime('%Y%m%d_%H%M%S')}"
                f".pdf"
            )

            ruta = exportar_pdf(
                filas,
                encabezados,
                nombre,
                titulo="Reporte de Usuarios"
            )

            messagebox.showinfo(
                "PDF",
                f"Archivo generado correctamente.\n\n{ruta}"
            )

        except Exception as e:

            messagebox.showerror(
                "PDF",
                str(e)
            )