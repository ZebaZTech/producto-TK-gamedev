import tkinter as tk
from tkinter import ttk, messagebox, filedialog
from tkcalendar import DateEntry
from datetime import datetime
import json

from PIL import Image, ImageTk

from utils.validaciones import validar_texto, validar_fecha, validar_imagen, validar_presupuesto
from utils.imagenes import cargar_imagen_tk
from utils.iconos import cargar_favicon
from utils.exportar_excel import exportar_excel
from utils.exportar_pdf import exportar_pdf


class VideojuegosView:

    def __init__(self, ventana, controller):

        self.ventana = ventana
        self.controller = controller

        # ====================================================
        # VARIABLES
        # ====================================================

        self.id_videogame = None
        self.ruta_imagen = None
        self.imagen_tk = None
        self.iconos = {
            "nuevo": ImageTk.PhotoImage(
                Image.open("assets/icons/plus.png").resize((18, 18))
            ),
            "guardar": ImageTk.PhotoImage(
                Image.open("assets/icons/save.png").resize((18, 18))
            ),
            "actualizar": ImageTk.PhotoImage(
                Image.open("assets/icons/auto-update.png").resize((18, 18))
            ),
            "eliminar": ImageTk.PhotoImage(
                Image.open("assets/icons/cross.png").resize((18, 18))
            ),
            "refrescar": ImageTk.PhotoImage(
                Image.open("assets/icons/refresh.png").resize((18, 18))
            ),
            "excel": ImageTk.PhotoImage(
                Image.open("assets/icons/file-excel.png").resize((18, 18))
            ),
            "pdf": ImageTk.PhotoImage(
                Image.open("assets/icons/file-pdf.png").resize((18, 18))
            )
        }

        self.generos = {}
        self.clasificaciones = {}
        self.motores = {}
        self.plataformas = {}

        # ====================================================
        # FAVICON
        # ====================================================

        cargar_favicon(self.ventana)

        # ====================================================
        # INTERFAZ
        # ====================================================

        self.crear_interfaz()

    def crear_interfaz(self):

        titulo = ttk.Label(
            self.ventana,
            text="GESTIÓN DE VIDEOJUEGOS",
            style="Titulo.TLabel"
        )

        titulo.pack(pady=(15, 10))

        contenedor = ttk.Frame(self.ventana)

        contenedor.pack(
            fill="both",
            expand=True,
            padx=15,
            pady=10
        )

        # ====================================================
        # FORMULARIO
        # ====================================================

        formulario = ttk.LabelFrame(
            contenedor,
            text="Información del videojuego",
            padding=15
        )

        formulario.pack(
            fill="x",
            pady=(0, 10)
        )

        # Código

        ttk.Label(
            formulario,
            text="Código:"
        ).grid(
            row=0,
            column=0,
            sticky="w",
            padx=5,
            pady=5
        )

        self.txt_codigo = ttk.Entry(
            formulario,
            width=25
        )

        self.txt_codigo.grid(
            row=0,
            column=1,
            sticky="ew",
            padx=5,
            pady=5
        )

        # Título

        ttk.Label(
            formulario,
            text="Título:"
        ).grid(
            row=0,
            column=2,
            sticky="w",
            padx=5,
            pady=5
        )

        self.txt_titulo = ttk.Entry(
            formulario,
            width=35
        )

        self.txt_titulo.grid(
            row=0,
            column=3,
            sticky="ew",
            padx=5,
            pady=5
        )

        # Género

        ttk.Label(
            formulario,
            text="Género:"
        ).grid(
            row=1,
            column=0,
            sticky="w",
            padx=5,
            pady=5
        )

        self.cbo_genero = ttk.Combobox(
            formulario,
            state="readonly",
            width=22
        )

        self.cbo_genero.grid(
            row=1,
            column=1,
            sticky="ew",
            padx=5,
            pady=5
        )

        # Clasificación

        ttk.Label(
            formulario,
            text="Clasificación:"
        ).grid(
            row=1,
            column=2,
            sticky="w",
            padx=5,
            pady=5
        )

        self.cbo_clasificacion = ttk.Combobox(
            formulario,
            state="readonly",
            width=30
        )

        self.cbo_clasificacion.grid(
            row=1,
            column=3,
            sticky="ew",
            padx=5,
            pady=5
        )

        # Motor

        ttk.Label(
            formulario,
            text="Motor gráfico:"
        ).grid(
            row=2,
            column=0,
            sticky="w",
            padx=5,
            pady=5
        )

        self.cbo_motor = ttk.Combobox(
            formulario,
            state="readonly",
            width=22
        )

        self.cbo_motor.grid(
            row=2,
            column=1,
            sticky="ew",
            padx=5,
            pady=5
        )

        # Estado

        ttk.Label(
            formulario,
            text="Estado:"
        ).grid(
            row=2,
            column=2,
            sticky="w",
            padx=5,
            pady=5
        )

        self.cbo_estado = ttk.Combobox(
            formulario,
            state="readonly",
            values=[
                "planificacion",
                "desarrollo",
                "pruebas",
                "lanzado",
                "pausado",
                "cancelado"
            ],
            width=30
        )

        self.cbo_estado.grid(
            row=2,
            column=3,
            sticky="ew",
            padx=5,
            pady=5
        )

        self.cbo_estado.set("planificacion")

        # Fecha inicio

        ttk.Label(
            formulario,
            text="Fecha de inicio:"
        ).grid(
            row=3,
            column=0,
            sticky="w",
            padx=5,
            pady=5
        )

        self.fecha_inicio = DateEntry(
            formulario,
            width=20,
            date_pattern="dd/mm/yyyy",
            locale="es_ES"
        )

        self.fecha_inicio.grid(
            row=3,
            column=1,
            sticky="w",
            padx=5,
            pady=5
        )

        # Fecha lanzamiento

        ttk.Label(
            formulario,
            text="Lanzamiento previsto:"
        ).grid(
            row=3,
            column=2,
            sticky="w",
            padx=5,
            pady=5
        )

        self.fecha_lanzamiento = DateEntry(
            formulario,
            width=20,
            date_pattern="dd/mm/yyyy",
            locale="es_ES"
        )

        self.fecha_lanzamiento.grid(
            row=3,
            column=3,
            sticky="w",
            padx=5,
            pady=5
        )

        # Presupuesto

        ttk.Label(
            formulario,
            text="Presupuesto:"
        ).grid(
            row=4,
            column=0,
            sticky="w",
            padx=5,
            pady=5
        )

        self.txt_presupuesto = ttk.Entry(
            formulario,
            width=25
        )

        self.txt_presupuesto.grid(
            row=4,
            column=1,
            sticky="ew",
            padx=5,
            pady=5
        )

        # Plataformas

        ttk.Label(
            formulario,
            text="Plataformas:"
        ).grid(
            row=4,
            column=2,
            sticky="nw",
            padx=5,
            pady=5
        )

        self.lista_plataformas = tk.Listbox(
            formulario,
            height=4,
            selectmode=tk.MULTIPLE,
            exportselection=False
        )

        self.lista_plataformas.grid(
            row=4,
            column=3,
            sticky="ew",
            padx=5,
            pady=5
        )

        # Imagen

        ttk.Label(
            formulario,
            text="Portada:"
        ).grid(
            row=5,
            column=0,
            sticky="nw",
            padx=5,
            pady=5
        )

        self.lbl_imagen = ttk.Label(
            formulario,
            text="Sin imagen seleccionada"
        )

        self.lbl_imagen.grid(
            row=5,
            column=1,
            columnspan=2,
            sticky="w",
            padx=5,
            pady=5
        )

        self.btn_imagen = ttk.Button(
            formulario,
            text="Seleccionar portada",
            command=self.seleccionar_imagen
        )

        self.btn_imagen.grid(
            row=5,
            column=3,
            sticky="w",
            padx=5,
            pady=5
        )

        formulario.columnconfigure(1, weight=1)
        formulario.columnconfigure(3, weight=2)

        # ====================================================
        # BOTONES
        # ====================================================

        botones = ttk.Frame(contenedor)
        botones.pack(
            fill="x",
            pady=2
        )

        tk.Button(
            botones,
            text="Nuevo",
            command=self.nuevo,
            image=self.iconos["nuevo"],
            compound="left",
            font=("Segoe UI", 10, "bold"),
            bg="#2563EB",
            fg="white",
            activebackground="#1D4ED8",
            activeforeground="white",
            relief="flat",
            padx=15,
            pady=6,
            cursor="hand2"
        ).pack(
            side="left",
            padx=5
        )

        tk.Button(
            botones,
            text="Guardar",
            command=self.guardar,
            image=self.iconos["guardar"],
            compound="left",
            font=("Segoe UI", 10, "bold"),
            bg="#16A34A",
            fg="white",
            activebackground="#15803D",
            activeforeground="white",
            relief="flat",
            padx=15,
            pady=6,
            cursor="hand2"
        ).pack(
            side="left",
            padx=5
        )

        tk.Button(
            botones,
            text="Actualizar",
            command=self.actualizar,
            image=self.iconos["actualizar"],
            compound="left",
            font=("Segoe UI", 10, "bold"),
            bg="#F59E0B",
            fg="white",
            activebackground="#D97706",
            activeforeground="white",
            relief="flat",
            padx=15,
            pady=6,
            cursor="hand2"
        ).pack(
            side="left",
            padx=5
        )

        tk.Button(
            botones,
            text="Eliminar",
            command=self.eliminar,
            image=self.iconos["eliminar"],
            compound="left",
            font=("Segoe UI", 10, "bold"),
            bg="#DC2626",
            fg="white",
            activebackground="#B91C1C",
            activeforeground="white",
            relief="flat",
            padx=15,
            pady=6,
            cursor="hand2"
        ).pack(
            side="left",
            padx=5
        )

        tk.Button(
            botones,
            text="Refrescar",
            command=self.listar_videojuegos,
            image=self.iconos["refrescar"],
            compound="left",
            font=("Segoe UI", 10, "bold"),
            bg="#6B7280",
            fg="white",
            activebackground="#4B5563",
            activeforeground="white",
            relief="flat",
            padx=15,
            pady=6,
            cursor="hand2"
        ).pack(
            side="left",
            padx=5
        )
        tk.Button(
            botones,
            text="Excel",
            command=self.exportar_excel_videojuegos,
            image=self.iconos["excel"],
            compound="left",
            font=("Segoe UI", 10, "bold"),
            bg="#15803D",
            fg="white",
            relief="flat",
            padx=15,
            pady=6,
            cursor="hand2"
        ).pack(
            side="left",
            padx=5
        )

        tk.Button(
            botones,
            text="PDF",
            command=self.exportar_pdf_videojuegos,
            image=self.iconos["pdf"],
            compound="left",
            font=("Segoe UI", 10, "bold"),
            bg="#B91C1C",
            fg="white",
            relief="flat",
            padx=15,
            pady=6,
            cursor="hand2"
        ).pack(
            side="left",
            padx=5
        )
        # ====================================================
        # FILTROS
        # ====================================================

        filtros = ttk.LabelFrame(
            contenedor,
            text="Filtros",
            padding=10
        )

        filtros.pack(
            fill="x",
            pady=10
        )

        ttk.Label(
            filtros,
            text="Buscar:"
        ).pack(
            side="left",
            padx=5
        )

        self.txt_busqueda = ttk.Entry(
            filtros,
            width=30
        )

        self.txt_busqueda.pack(
            side="left",
            padx=5
        )

        ttk.Label(
            filtros,
            text="Estado:"
        ).pack(
            side="left",
            padx=5
        )

        self.cbo_filtro_estado = ttk.Combobox(
            filtros,
            state="readonly",
            values=[
                "",
                "planificacion",
                "desarrollo",
                "pruebas",
                "lanzado",
                "pausado",
                "cancelado"
            ],
            width=18
        )

        self.cbo_filtro_estado.pack(
            side="left",
            padx=5
        )

        self.cbo_filtro_estado.set("")

        ttk.Label(
            filtros,
            text="Género:"
        ).pack(
            side="left",
            padx=5
        )

        self.cbo_filtro_genero = ttk.Combobox(
            filtros,
            state="readonly",
            width=20
        )

        self.cbo_filtro_genero.pack(
            side="left",
            padx=5
        )

        self.cbo_filtro_genero.set("Todos")

        ttk.Button(
            filtros,
            text="🔎 Filtrar",
            command=self.listar_videojuegos
        ).pack(
            side="left",
            padx=10
        )

        # ====================================================
        # TABLA
        # ====================================================

        tabla_frame = ttk.Frame(contenedor)

        tabla_frame.pack(
            fill="both",
            expand=True
        )

        columnas = (
            "id",
            "codigo",
            "titulo",
            "genero",
            "clasificacion",
            "motor",
            "plataformas",
            "inicio",
            "lanzamiento",
            "presupuesto",
            "estado",
            "equipo"
        )

        self.tabla = ttk.Treeview(
            tabla_frame,
            columns=columnas,
            show="headings",
            selectmode="browse"
        )

        encabezados = {
            "id": "ID",
            "codigo": "Código",
            "titulo": "Título",
            "genero": "Género",
            "clasificacion": "Clasificación",
            "motor": "Motor",
            "plataformas": "Plataformas",
            "inicio": "Inicio",
            "lanzamiento": "Lanzamiento",
            "presupuesto": "Presupuesto",
            "estado": "Estado",
            "equipo": "Equipo"
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
        self.tabla.column("titulo", width=180)
        self.tabla.column("plataformas", width=180)

        scrollbar_y = ttk.Scrollbar(
            tabla_frame,
            orient="vertical",
            command=self.tabla.yview
        )

        scrollbar_x = ttk.Scrollbar(
            tabla_frame,
            orient="horizontal",
            command=self.tabla.xview
        )

        self.tabla.configure(
            yscrollcommand=scrollbar_y.set,
            xscrollcommand=scrollbar_x.set
        )

        self.tabla.grid(
            row=0,
            column=0,
            sticky="nsew"
        )

        scrollbar_y.grid(
            row=0,
            column=1,
            sticky="ns"
        )

        scrollbar_x.grid(
            row=1,
            column=0,
            sticky="ew"
        )

        tabla_frame.rowconfigure(
            0,
            weight=1
        )

        tabla_frame.columnconfigure(
            0,
            weight=1
        )

        self.tabla.bind(
            "<Double-1>",
            self.seleccionar_registro
        )

    def seleccionar_imagen(self):

        ruta = filedialog.askopenfilename(
            title="Seleccionar portada",
            filetypes=[
                (
                    "Imágenes",
                    "*.jpg *.jpeg *.png *.gif"
                )
            ]
        )

        if not ruta:
            return

        valido, mensaje = validar_imagen(
            ruta,
            "La portada"
        )

        if not valido:

            messagebox.showerror(
                "Imagen inválida",
                mensaje
            )

            return

        self.ruta_imagen = ruta

        try:

            self.imagen_tk = cargar_imagen_tk(
                ruta,
                120,
                120
            )

            self.lbl_imagen.configure(
                image=self.imagen_tk,
                text=""
            )

        except Exception as error:

            messagebox.showerror(
                "Error",
                f"No se pudo cargar la imagen:\n{error}"
            )

    def nuevo(self):

        self.id_videogame = None
        self.ruta_imagen = None
        self.imagen_tk = None

        self.txt_codigo.delete(
            0,
            tk.END
        )

        self.txt_titulo.delete(
            0,
            tk.END
        )

        self.txt_presupuesto.delete(
            0,
            tk.END
        )

        self.cbo_genero.set("")
        self.cbo_clasificacion.set("")
        self.cbo_motor.set("")
        self.cbo_estado.set("planificacion")

        self.lista_plataformas.selection_clear(
            0,
            tk.END
        )

        self.lbl_imagen.configure(
            image="",
            text="Sin imagen seleccionada"
        )

        self.txt_codigo.focus()

    def cargar_catalogos(self):
        """Solicita al Controller los catálogos necesarios para la vista."""
        self.controller.cargar_catalogos()

    def listar_videojuegos(self):
        """Solicita al Controller los registros según los filtros actuales."""
        self.controller.listar_videojuegos()

    def guardar(self):
        """Valida el formulario y delega el registro al Controller."""
        datos = self.obtener_datos_formulario()
        if datos is not None:
            self.controller.guardar(datos)

    def actualizar(self):
        """Valida y delega la actualización al Controller."""
        if not self.id_videogame:
            messagebox.showwarning("Actualizar", "Seleccione primero un videojuego.")
            return
        if not messagebox.askyesno("Confirmar actualización", "¿Está seguro de actualizar este videojuego?"):
            return
        datos = self.obtener_datos_formulario()
        if datos is not None:
            self.controller.actualizar(self.id_videogame, datos)

    def eliminar(self):
        """Confirma y delega la eliminación al Controller."""
        if not self.id_videogame:
            messagebox.showwarning("Eliminar", "Seleccione primero un videojuego.")
            return
        if not messagebox.askyesno(
            "Confirmar eliminación",
            "¿Está seguro de eliminar este videojuego?\n\nEsta acción no se puede deshacer."
        ):
            return
        self.controller.eliminar(self.id_videogame)

    def mostrar_registros(self, filas):
        """Actualiza el Treeview con los registros entregados por el Controller."""
        for item in self.tabla.get_children():
            self.tabla.delete(item)
        for fila in filas:
            self.tabla.insert("", "end", values=fila)

    def establecer_catalogos(self, generos, clasificaciones, motores, plataformas):
        """Carga los catálogos entregados por el Controller."""
        self.generos = generos
        self.clasificaciones = clasificaciones
        self.motores = motores
        self.plataformas = plataformas
        self.cbo_genero["values"] = list(self.generos.keys())
        self.cbo_filtro_genero["values"] = ["Todos"] + list(self.generos.keys())
        self.cbo_clasificacion["values"] = list(self.clasificaciones.keys())
        self.cbo_motor["values"] = list(self.motores.keys())
        self.lista_plataformas.delete(0, tk.END)
        for nombre in self.plataformas.keys():
            self.lista_plataformas.insert(tk.END, nombre)

    def _cargar_imagen_actual(self, id_videogame):
        """Solicita al Controller la ruta de imagen del registro seleccionado."""
        ruta_actual = self.controller.obtener_imagen(id_videogame)
        self.mostrar_imagen_actual(ruta_actual)

    def mostrar_imagen_actual(self, ruta_actual):
        """Muestra la imagen almacenada para el videojuego seleccionado."""
        self.ruta_imagen = None
        if not ruta_actual:
            self.lbl_imagen.config(text="Imagen actual: no disponible", image="")
            self.imagen_tk = None
            return
        try:
            self.imagen_tk = cargar_imagen_tk(ruta_actual, 120, 120)
            if self.imagen_tk:
                self.lbl_imagen.config(image=self.imagen_tk, text="")
            else:
                self.lbl_imagen.config(text="Imagen actual cargada", image="")
        except Exception:
            self.lbl_imagen.config(text="Imagen actual no disponible", image="")

    @staticmethod
    def abrir_videogames(parent):
        ventana = tk.Toplevel(parent)
        ventana.title("GameDev - Videojuegos")
        ventana.geometry("1200x750")
        ventana.minsize(1100, 700)
        try:
            cargar_favicon(ventana)
        except Exception:
            pass
        from controllers.videojuego_controller import VideojuegoController
        VideojuegoController(ventana)
        return ventana


    def seleccionar_registro(self, event=None):
        seleccion = self.tabla.selection()

        if not seleccion:
            return

        item = seleccion[0]
        valores = self.tabla.item(item, "values")

        if not valores:
            return

        try:
            # Guardar ID seleccionado
            self.id_videogame = valores[0]

            # Código
            self.txt_codigo.delete(0, tk.END)
            self.txt_codigo.insert(0, valores[1])

            # Título
            self.txt_titulo.delete(0, tk.END)
            self.txt_titulo.insert(0, valores[2])

            # Género
            genero = str(valores[3])

            if genero in self.generos:
                self.cbo_genero.set(genero)
            else:
                self.cbo_genero.set("")

            # Clasificación
            clasificacion = str(valores[4])

            if clasificacion in self.clasificaciones:
                self.cbo_clasificacion.set(clasificacion)
            else:
                self.cbo_clasificacion.set("")

            # Motor gráfico
            motor = str(valores[5]) if valores[5] else ""

            if motor in self.motores:
                self.cbo_motor.set(motor)
            else:
                self.cbo_motor.set("")

            # Plataformas
            self._seleccionar_plataformas(valores[6])

            # Fecha de inicio
            self._establecer_fecha(self.fecha_inicio, valores[7])

            # Fecha de lanzamiento
            self._establecer_fecha(self.fecha_lanzamiento, valores[8])

            # Presupuesto
            self.txt_presupuesto.delete(0, tk.END)

            if valores[9] is not None:
                self.txt_presupuesto.insert(
                    0,
                    str(valores[9])
                )

            # Estado
            self.cbo_estado.set(
                str(valores[10]) if valores[10] else ""
            )

            # Cargar imagen actual
            self._cargar_imagen_actual(self.id_videogame)

        except Exception as e:
            messagebox.showerror(
                "Error",
                f"No fue posible cargar el registro.\n\n{e}"
            )

    def _seleccionar_plataformas(self, valor):
        try:
            self.lista_plataformas.selection_clear(0, tk.END)

            if valor is None:
                return

            texto = str(valor).strip()

            if not texto:
                return

            nombres = []

            # Intentar leer como JSON
            try:
                datos = json.loads(texto)

                if isinstance(datos, list):
                    for dato in datos:

                        for nombre, id_plataforma in self.plataformas.items():

                            if (
                                str(dato) == str(id_plataforma)
                                or str(dato).strip() == str(nombre).strip()
                            ):
                                nombres.append(nombre)

            except Exception:
                # Si no es JSON, asumir texto separado por comas
                nombres = [
                    elemento.strip()
                    for elemento in texto.split(",")
                    if elemento.strip()
                ]

            # Seleccionar coincidencias
            for indice in range(self.lista_plataformas.size()):

                nombre = self.lista_plataformas.get(indice)

                if nombre in nombres:
                    self.lista_plataformas.selection_set(indice)

        except Exception:
            pass

    def _establecer_fecha(self, widget, valor):

        if not valor:
            return

        try:
            # Si MySQL devuelve date/datetime
            if hasattr(valor, "year"):
                widget.set_date(valor)
                return

            texto = str(valor).strip()

            formatos = [
                "%Y-%m-%d",
                "%d/%m/%Y",
                "%Y-%m-%d %H:%M:%S"
            ]

            for formato in formatos:

                try:
                    fecha = datetime.strptime(
                        texto,
                        formato
                    )

                    widget.set_date(fecha)
                    return

                except ValueError:
                    continue

        except Exception:
            pass

    def obtener_datos_formulario(self):

        codigo = self.txt_codigo.get().strip()
        titulo = self.txt_titulo.get().strip()
        presupuesto = self.txt_presupuesto.get().strip()

        # Código

        valido, mensaje = validar_texto(
            codigo,
            "Código",
            3,
            20
        )

        if not valido:

            messagebox.showerror(
                "Validación",
                mensaje
            )

            return None

        # Título

        valido, mensaje = validar_texto(
            titulo,
            "Título",
            2,
            150
        )

        if not valido:

            messagebox.showerror(
                "Validación",
                mensaje
            )

            return None

        # Género

        if not self.cbo_genero.get():

            messagebox.showerror(
                "Validación",
                "Debe seleccionar un género."
            )

            return None

        # Clasificación

        if not self.cbo_clasificacion.get():

            messagebox.showerror(
                "Validación",
                "Debe seleccionar una clasificación."
            )

            return None

        # Fechas

        fecha_inicio = self.fecha_inicio.get()
        fecha_lanzamiento = self.fecha_lanzamiento.get()

        valido, mensaje = validar_fecha(
            fecha_inicio,
            "Fecha de inicio"
        )

        if not valido:

            messagebox.showerror(
                "Validación",
                mensaje
            )

            return None

        valido, mensaje = validar_fecha(
            fecha_lanzamiento,
            "Fecha de lanzamiento"
        )

        if not valido:

            messagebox.showerror(
                "Validación",
                mensaje
            )

            return None

        # Presupuesto

        valido, mensaje = validar_presupuesto(
            presupuesto
        )

        if not valido:

            messagebox.showerror(
                "Validación",
                mensaje
            )

            return None

        # Plataformas

        seleccionadas = self.lista_plataformas.curselection()

        if not seleccionadas:

            messagebox.showerror(
                "Validación",
                "Debe seleccionar al menos una plataforma."
            )

            return None

        plataformas_ids = []

        for indice in seleccionadas:

            nombre = self.lista_plataformas.get(indice)

            plataformas_ids.append(
                self.plataformas[nombre]
            )

        # Imagen

        imagen = None

        if self.ruta_imagen:

            valido, mensaje = validar_imagen(
                self.ruta_imagen,
                "La portada"
            )

            if not valido:

                messagebox.showerror(
                    "Validación",
                    mensaje
                )

                return None

            imagen = self.ruta_imagen

        # Fechas MySQL

        try:

            fecha_inicio_mysql = datetime.strptime(
                fecha_inicio,
                "%d/%m/%Y"
            ).strftime("%Y-%m-%d")

            fecha_lanzamiento_mysql = datetime.strptime(
                fecha_lanzamiento,
                "%d/%m/%Y"
            ).strftime("%Y-%m-%d")

        except ValueError:

            messagebox.showerror(
                "Validación",
                "Las fechas no tienen un formato válido."
            )

            return None

        return {
            "codigo": codigo,
            "titulo": titulo,
            "id_genero": self.generos[
                self.cbo_genero.get()
            ],
            "id_clasificacion": self.clasificaciones[
                self.cbo_clasificacion.get()
            ],
            "id_motor": (
                self.motores.get(
                    self.cbo_motor.get()
                )
                if self.cbo_motor.get()
                else None
            ),
            "fecha_inicio": fecha_inicio_mysql,
            "fecha_lanzamiento": fecha_lanzamiento_mysql,
            "presupuesto": float(
                presupuesto.replace(",", ".")
            ),
            "estado": self.cbo_estado.get(),
            "plataformas": plataformas_ids,
            "imagen": imagen
        }



    def exportar_excel_videojuegos(self):

        filas = []

        for item in self.tabla.get_children():
            filas.append(
                self.tabla.item(item, "values")
            )

        if not filas:
            messagebox.showwarning(
                "Exportar Excel",
                "No hay videojuegos para exportar."
            )
            return

        encabezados = [
            self.tabla.heading(columna)["text"]
            for columna in self.tabla["columns"]
        ]

        try:
            nombre = (
                f"videojuegos_"
                f"{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx"
            )

            ruta = exportar_excel(
                filas,
                encabezados,
                nombre
            )

            messagebox.showinfo(
                "Excel",
                f"Archivo Excel generado correctamente.\n\n{ruta}"
            )

        except Exception as e:
            messagebox.showerror(
                "Error",
                f"No fue posible generar el Excel.\n\n{e}"
            )

    def exportar_pdf_videojuegos(self):

        filas = []

        for item in self.tabla.get_children():
            filas.append(
                self.tabla.item(item, "values")
            )

        if not filas:
            messagebox.showwarning(
                "Exportar PDF",
                "No hay videojuegos para exportar."
            )
            return

        encabezados = [
            self.tabla.heading(columna)["text"]
            for columna in self.tabla["columns"]
        ]

        try:
            nombre = (
                f"videojuegos_"
                f"{datetime.now().strftime('%Y%m%d_%H%M%S')}.pdf"
            )

            ruta = exportar_pdf(
                filas,
                encabezados,
                nombre,
                titulo="Reporte de Videojuegos"
            )

            messagebox.showinfo(
                "PDF",
                f"Archivo PDF generado correctamente.\n\n{ruta}"
            )

        except Exception as e:
            messagebox.showerror(
                "Error",
                f"No fue posible generar el PDF.\n\n{e}"
            )
