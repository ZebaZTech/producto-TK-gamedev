import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import json
import re
from datetime import datetime

from utils.validaciones import validar_imagen
from utils.imagenes import cargar_imagen_tk
from utils.exportar_excel import exportar_excel
from utils.exportar_pdf import exportar_pdf
from PIL import Image, ImageTk


class EmpleadosView:
    """Vista Tkinter del módulo de empleados."""

    def __init__(self, parent, controller):
        self.parent = parent
        self.controller = controller

        self.id_empleado = None
        self.ruta_imagen = None
        self.imagen_tk = None

        self.especialidades = {}
        self.habilidades = {}

        self.iconos = {
            "nuevo": ImageTk.PhotoImage(Image.open("assets/icons/plus.png").resize((18, 18))),
            "guardar": ImageTk.PhotoImage(Image.open("assets/icons/save.png").resize((18, 18))),
            "actualizar": ImageTk.PhotoImage(Image.open("assets/icons/auto-update.png").resize((18, 18))),
            "eliminar": ImageTk.PhotoImage(Image.open("assets/icons/cross.png").resize((18, 18))),
            "refrescar": ImageTk.PhotoImage(Image.open("assets/icons/refresh.png").resize((18, 18))),
            "excel": ImageTk.PhotoImage(Image.open("assets/icons/file-excel.png").resize((18, 18))),
            "pdf": ImageTk.PhotoImage(Image.open("assets/icons/file-pdf.png").resize((18, 18)))
        }

        self.crear_interfaz()

    def crear_interfaz(self):
        canvas = tk.Canvas(self.parent, highlightthickness=0)
        scrollbar = ttk.Scrollbar(
            self.parent, orient="vertical", command=canvas.yview
        )
        contenedor = ttk.Frame(canvas, padding=15)

        contenedor.bind(
            "<Configure>",
            lambda e: canvas.configure(scrollregion=canvas.bbox("all"))
        )

        ventana_interna = canvas.create_window(
            (0, 0), window=contenedor, anchor="nw"
        )
        canvas.configure(yscrollcommand=scrollbar.set)

        canvas.bind(
            "<Configure>",
            lambda e: canvas.itemconfig(ventana_interna, width=e.width)
        )

        canvas.pack(side="left", fill="both", expand=True)
        scrollbar.pack(side="right", fill="y")

        def _on_mousewheel(event):
            canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")

        canvas.bind(
            "<Enter>", lambda e: canvas.bind_all("<MouseWheel>", _on_mousewheel)
        )
        canvas.bind(
            "<Leave>", lambda e: canvas.unbind_all("<MouseWheel>")
        )

        titulo = ttk.Label(
            contenedor,
            text="Gestión de Empleados",
            style="Titulo.TLabel"
        )
        titulo.pack(anchor="w", pady=(0, 10))

        formulario = ttk.LabelFrame(
            contenedor,
            text="Información del empleado",
            padding=10
        )
        formulario.pack(fill="x")

        ttk.Label(formulario, text="Código:").grid(
            row=0, column=0, sticky="w", padx=5, pady=5
        )
        self.txt_codigo = ttk.Entry(formulario, width=25)
        self.txt_codigo.grid(row=0, column=1, padx=5, pady=5)

        ttk.Label(formulario, text="Nombres:").grid(
            row=0, column=2, sticky="w", padx=5
        )
        self.txt_nombres = ttk.Entry(formulario, width=25)
        self.txt_nombres.grid(row=0, column=3, padx=5)

        ttk.Label(formulario, text="Apellidos:").grid(
            row=0, column=4, sticky="w", padx=5
        )
        self.txt_apellidos = ttk.Entry(formulario, width=25)
        self.txt_apellidos.grid(row=0, column=5, padx=5)

        ttk.Label(formulario, text="Especialidad:").grid(
            row=1, column=0, sticky="w", padx=5, pady=5
        )
        self.cbo_especialidad = ttk.Combobox(
            formulario, state="readonly", width=22
        )
        self.cbo_especialidad.grid(row=1, column=1, padx=5)

        ttk.Label(formulario, text="Experiencia (años):").grid(
            row=1, column=2, sticky="w", padx=5
        )
        self.txt_experiencia = ttk.Entry(formulario, width=10)
        self.txt_experiencia.grid(row=1, column=3, sticky="w", padx=5)

        ttk.Label(formulario, text="Correo:").grid(
            row=1, column=4, sticky="w", padx=5
        )
        self.txt_correo = ttk.Entry(formulario, width=25)
        self.txt_correo.grid(row=1, column=5, padx=5)

        ttk.Label(formulario, text="Experiencia previa:").grid(
            row=2, column=0, sticky="nw", padx=5, pady=5
        )
        self.txt_experiencia_previa = tk.Text(
            formulario, width=55, height=4, font=("Segoe UI", 9)
        )
        self.txt_experiencia_previa.grid(
            row=2, column=1, columnspan=3, padx=5, pady=5
        )

        habilidades_frame = ttk.LabelFrame(
            formulario, text="Habilidades", padding=5
        )
        habilidades_frame.grid(
            row=2, column=4, columnspan=2,
            padx=5, pady=5, sticky="nsew"
        )

        self.lista_habilidades = tk.Listbox(
            habilidades_frame,
            selectmode="multiple",
            height=5,
            width=30
        )
        self.lista_habilidades.pack(fill="both", expand=True)

        imagen_frame = ttk.LabelFrame(
            formulario, text="Imagen de perfil", padding=5
        )
        imagen_frame.grid(
            row=3, column=0, columnspan=2,
            padx=5, pady=5, sticky="w"
        )

        self.lbl_imagen = tk.Label(
            imagen_frame,
            text="Sin imagen",
            width=18,
            height=7,
            relief="solid",
            bg="white"
        )
        self.lbl_imagen.pack(pady=5)

        tk.Button(
            imagen_frame,
            text="Seleccionar imagen",
            command=self.seleccionar_imagen,
            bg="#2563EB",
            fg="white",
            relief="flat",
            padx=10,
            pady=5,
            cursor="hand2"
        ).pack()

        self.var_activo = tk.BooleanVar(value=True)
        ttk.Checkbutton(
            formulario,
            text="Empleado activo",
            variable=self.var_activo
        ).grid(row=3, column=2, padx=5, pady=10, sticky="w")

        botones = ttk.Frame(contenedor)
        botones.pack(fill="x", pady=8)

        self.crear_boton(botones, "Nuevo", self.nuevo, "#2563EB", self.iconos["nuevo"])
        self.crear_boton(botones, "Guardar", self.guardar, "#16A34A", self.iconos["guardar"])
        self.crear_boton(botones, "Actualizar", self.actualizar, "#F59E0B", self.iconos["actualizar"])
        self.crear_boton(botones, "Eliminar", self.eliminar, "#DC2626", self.iconos["eliminar"])
        self.crear_boton(botones, "Refrescar", self.listar_empleados, "#6B7280", self.iconos["refrescar"])
        self.crear_boton(botones, "Excel", self.exportar_excel_empleados, "#15803D", self.iconos["excel"])
        self.crear_boton(botones, "PDF", self.exportar_pdf_empleados, "#B91C1C", self.iconos["pdf"])

        filtros = ttk.LabelFrame(
            contenedor, text="Filtros", padding=8
        )
        filtros.pack(fill="x", pady=5)

        ttk.Label(filtros, text="Buscar:").pack(side="left", padx=5)
        self.txt_busqueda = ttk.Entry(filtros, width=30)
        self.txt_busqueda.pack(side="left", padx=5)

        ttk.Label(filtros, text="Especialidad:").pack(side="left", padx=5)
        self.cbo_filtro_especialidad = ttk.Combobox(
            filtros, state="readonly", width=20
        )
        self.cbo_filtro_especialidad.pack(side="left", padx=5)

        self.var_solo_activos = tk.BooleanVar(value=False)
        ttk.Checkbutton(
            filtros,
            text="Solo activos",
            variable=self.var_solo_activos
        ).pack(side="left", padx=10)

        tk.Button(
            filtros,
            text="Aplicar filtros",
            command=self.listar_empleados,
            bg="#2563EB",
            fg="white",
            relief="flat",
            padx=12,
            pady=5,
            cursor="hand2"
        ).pack(side="left", padx=5)

        tabla_frame = ttk.Frame(contenedor)
        tabla_frame.pack(fill="both", expand=True, pady=10)

        columnas = (
            "id", "codigo", "nombres", "apellidos", "especialidad",
            "experiencia", "correo", "activo", "habilidades",
            "proyectos", "dedicacion"
        )

        self.tabla = ttk.Treeview(
            tabla_frame, columns=columnas, show="headings"
        )

        encabezados = {
            "id": "ID",
            "codigo": "Código",
            "nombres": "Nombres",
            "apellidos": "Apellidos",
            "especialidad": "Especialidad",
            "experiencia": "Experiencia",
            "correo": "Correo",
            "activo": "Activo",
            "habilidades": "Habilidades",
            "proyectos": "Proyectos",
            "dedicacion": "Dedicación"
        }

        for columna in columnas:
            self.tabla.heading(columna, text=encabezados[columna])
            self.tabla.column(
                columna, width=120, anchor="center"
            )

        self.tabla.column("id", width=50)
        self.tabla.column("nombres", width=130)
        self.tabla.column("apellidos", width=130)
        self.tabla.column("habilidades", width=220)
        self.tabla.column("proyectos", width=250)

        scroll = ttk.Scrollbar(
            tabla_frame, orient="vertical", command=self.tabla.yview
        )
        self.tabla.configure(yscrollcommand=scroll.set)

        self.tabla.pack(side="left", fill="both", expand=True)
        scroll.pack(side="right", fill="y")

        self.tabla.bind(
            "<<TreeviewSelect>>",
            self.seleccionar_registro
        )

    def crear_boton(self, parent, texto, comando, color, icono):
        boton = tk.Button(
            parent,
            text=texto,
            image=icono,
            compound="left",
            command=comando,
            font=("Segoe UI", 10, "bold"),
            bg=color,
            fg="white",
            relief="flat",
            padx=15,
            pady=6,
            cursor="hand2"
        )
        boton.image = icono
        boton.pack(side="left", padx=5)

    def establecer_catalogos(self, especialidades, habilidades):
        self.especialidades = especialidades
        self.habilidades = habilidades

        nombres_especialidades = list(especialidades.keys())
        self.cbo_especialidad["values"] = nombres_especialidades
        self.cbo_filtro_especialidad["values"] = ["Todas"] + nombres_especialidades
        self.cbo_filtro_especialidad.set("Todas")

        self.lista_habilidades.delete(0, tk.END)
        for nombre in habilidades.keys():
            self.lista_habilidades.insert(tk.END, nombre)

    def seleccionar_imagen(self):
        ruta = filedialog.askopenfilename(
            title="Seleccionar imagen",
            filetypes=[("Imágenes", "*.jpg *.jpeg *.png *.gif")]
        )

        if not ruta:
            return

        try:
            validar_imagen(ruta)
            self.ruta_imagen = ruta
            self.imagen_tk = cargar_imagen_tk(ruta, 120, 120)
            self.lbl_imagen.configure(
                image=self.imagen_tk,
                text=""
            )
        except Exception as error:
            messagebox.showerror(
                "Imagen inválida",
                str(error)
            )

    def obtener_datos(self):
        codigo = self.txt_codigo.get().strip()
        nombres = self.txt_nombres.get().strip()
        apellidos = self.txt_apellidos.get().strip()
        correo = self.txt_correo.get().strip()
        experiencia = self.txt_experiencia.get().strip()

        if not codigo:
            raise ValueError("El código es obligatorio.")

        if not nombres:
            raise ValueError("Los nombres son obligatorios.")

        if not apellidos:
            raise ValueError("Los apellidos son obligatorios.")

        if not self.cbo_especialidad.get():
            raise ValueError("Debe seleccionar una especialidad.")

        if not experiencia:
            experiencia = "0"

        if not experiencia.isdigit():
            raise ValueError("La experiencia debe ser un número entero.")

        experiencia = int(experiencia)

        if experiencia < 0 or experiencia > 255:
            raise ValueError(
                "La experiencia debe estar entre 0 y 255 años."
            )

        if correo:
            patron = r"^[^@\s]+@[^@\s]+\.[^@\s]+$"
            if not re.match(patron, correo):
                raise ValueError(
                    "El correo electrónico no es válido."
                )

        texto_previo = self.txt_experiencia_previa.get(
            "1.0", tk.END
        ).strip()

        habilidades = []
        for indice in self.lista_habilidades.curselection():
            nombre = self.lista_habilidades.get(indice)
            habilidades.append({
                "id": self.habilidades[nombre],
                "nivel": "intermedio"
            })

        return {
            "codigo": codigo,
            "nombres": nombres,
            "apellidos": apellidos,
            "id_especialidad": self.especialidades[
                self.cbo_especialidad.get()
            ],
            "experiencia": experiencia,
            "experiencia_previa": texto_previo,
            "correo": correo,
            "activo": 1 if self.var_activo.get() else 0,
            "habilidades": json.dumps(habilidades),
            "imagen": self.ruta_imagen
        }

    def guardar(self):
        try:
            datos = self.obtener_datos()
            self.controller.guardar(datos)
        except Exception as error:
            messagebox.showerror(
                "Error de validación",
                str(error)
            )

    def listar_empleados(self):
        self.controller.listar()

    def mostrar_registros(self, filas):
        for item in self.tabla.get_children():
            self.tabla.delete(item)

        for fila in filas:
            self.tabla.insert("", "end", values=fila)

    def seleccionar_registro(self, event=None):
        seleccion = self.tabla.selection()

        if not seleccion:
            return

        valores = self.tabla.item(
            seleccion[0], "values"
        )

        if not valores:
            return

        self.id_empleado = valores[0]

        self.txt_codigo.delete(0, tk.END)
        self.txt_codigo.insert(0, valores[1])

        self.txt_nombres.delete(0, tk.END)
        self.txt_nombres.insert(0, valores[2])

        self.txt_apellidos.delete(0, tk.END)
        self.txt_apellidos.insert(0, valores[3])

        self.cbo_especialidad.set(valores[4])

        self.txt_experiencia.delete(0, tk.END)
        self.txt_experiencia.insert(0, valores[5])

        self.txt_correo.delete(0, tk.END)
        self.txt_correo.insert(0, valores[6] or "")

        self.var_activo.set(
            str(valores[7]) in ("1", "True", "activo")
        )

        self.cargar_datos_extra()

    def cargar_datos_extra(self):
        experiencia_previa, imagen, habilidades = (
            self.controller.obtener_datos_extra(self.id_empleado)
        )

        self.txt_experiencia_previa.delete("1.0", tk.END)
        self.txt_experiencia_previa.insert(
            "1.0", experiencia_previa or ""
        )

        if imagen:
            try:
                self.ruta_imagen = imagen
                self.imagen_tk = cargar_imagen_tk(
                    imagen, 120, 120
                )
                self.lbl_imagen.configure(
                    image=self.imagen_tk,
                    text=""
                )
            except Exception:
                self.lbl_imagen.configure(
                    image="",
                    text="Sin imagen"
                )
        else:
            self.ruta_imagen = None
            self.lbl_imagen.configure(
                image="",
                text="Sin imagen"
            )

        self.lista_habilidades.selection_clear(0, tk.END)

        for indice in range(self.lista_habilidades.size()):
            nombre = self.lista_habilidades.get(indice)
            if self.habilidades.get(nombre) in habilidades:
                self.lista_habilidades.selection_set(indice)

    def actualizar(self):
        if not self.id_empleado:
            messagebox.showwarning(
                "Actualizar",
                "Seleccione un empleado."
            )
            return

        if not messagebox.askyesno(
            "Confirmar actualización",
            "¿Desea actualizar este empleado?"
        ):
            return

        try:
            datos = self.obtener_datos()
            self.controller.actualizar(
                self.id_empleado,
                datos
            )
        except Exception as error:
            messagebox.showerror(
                "Error de validación",
                str(error)
            )

    def eliminar(self):
        if not self.id_empleado:
            messagebox.showwarning(
                "Eliminar",
                "Seleccione un empleado."
            )
            return

        if not messagebox.askyesno(
            "Confirmar eliminación",
            "¿Está seguro de eliminar este empleado?"
        ):
            return

        self.controller.eliminar(self.id_empleado)

    def nuevo(self):
        self.id_empleado = None
        self.ruta_imagen = None

        self.txt_codigo.delete(0, tk.END)
        self.txt_nombres.delete(0, tk.END)
        self.txt_apellidos.delete(0, tk.END)
        self.txt_experiencia.delete(0, tk.END)
        self.txt_correo.delete(0, tk.END)

        self.txt_experiencia_previa.delete(
            "1.0", tk.END
        )

        self.cbo_especialidad.set("")
        self.lista_habilidades.selection_clear(0, tk.END)
        self.var_activo.set(True)

        self.lbl_imagen.configure(
            image="",
            text="Sin imagen"
        )
        self.imagen_tk = None

    def exportar_excel_empleados(self):
        filas = [
            self.tabla.item(item, "values")
            for item in self.tabla.get_children()
        ]

        if not filas:
            messagebox.showwarning(
                "Excel",
                "No hay empleados para exportar."
            )
            return

        encabezados = [
            self.tabla.heading(columna)["text"]
            for columna in self.tabla["columns"]
        ]

        try:
            nombre = (
                f"empleados_{datetime.now().strftime('%Y%m%d_%H%M%S')}.xlsx"
            )
            ruta = exportar_excel(
                filas, encabezados, nombre
            )
            messagebox.showinfo(
                "Excel",
                f"Archivo generado correctamente.\n\n{ruta}"
            )
        except Exception as error:
            messagebox.showerror("Excel", str(error))

    def exportar_pdf_empleados(self):
        filas = [
            self.tabla.item(item, "values")
            for item in self.tabla.get_children()
        ]

        if not filas:
            messagebox.showwarning(
                "PDF",
                "No hay empleados para exportar."
            )
            return

        encabezados = [
            self.tabla.heading(columna)["text"]
            for columna in self.tabla["columns"]
        ]

        try:
            nombre = (
                f"empleados_{datetime.now().strftime('%Y%m%d_%H%M%S')}.pdf"
            )
            ruta = exportar_pdf(
                filas,
                encabezados,
                nombre,
                titulo="Reporte de Empleados"
            )
            messagebox.showinfo(
                "PDF",
                f"Archivo generado correctamente.\n\n{ruta}"
            )
        except Exception as error:
            messagebox.showerror("PDF", str(error))
