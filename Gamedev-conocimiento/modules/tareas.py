import tkinter as tk
from tkinter import ttk, messagebox
from datetime import datetime

from tkcalendar import DateEntry

from database.conexion import conectar, cerrar_conexion
from utils.exportar_excel import exportar_excel
from utils.exportar_pdf import exportar_pdf


class Tareas:
    def __init__(self, parent):
        self.parent = parent
        self.id_tarea = None

        self.videojuegos = {}
        self.modulos = {}
        self.empleados = {}
        self.tareas_ids = {}

        self.crear_interfaz()
        self.cargar_catalogos()
        self.listar_tareas()

    # =========================================================
    # INTERFAZ
    # =========================================================

    def crear_interfaz(self):
        contenedor = ttk.Frame(self.parent, padding=15)
        contenedor.pack(fill="both", expand=True)

        ttk.Label(
            contenedor,
            text="Gestión de Tareas",
            style="Titulo.TLabel"
        ).pack(anchor="w", pady=(0, 10))

        formulario = ttk.LabelFrame(
            contenedor,
            text="Información de la tarea",
            padding=10
        )
        formulario.pack(fill="x")

        # Código
        ttk.Label(formulario, text="Código:").grid(
            row=0, column=0, padx=5, pady=5, sticky="w"
        )

        self.txt_codigo = ttk.Entry(formulario, width=20)
        self.txt_codigo.grid(row=0, column=1, padx=5, pady=5)

        # Videojuego
        ttk.Label(formulario, text="Videojuego:").grid(
            row=0, column=2, padx=5, pady=5, sticky="w"
        )

        self.cbo_videojuego = ttk.Combobox(
            formulario,
            state="readonly",
            width=28
        )
        self.cbo_videojuego.grid(row=0, column=3, padx=5, pady=5)
        self.cbo_videojuego.bind(
            "<<ComboboxSelected>>",
            self.cargar_responsables
        )

        # Módulo
        ttk.Label(formulario, text="Módulo:").grid(
            row=0, column=4, padx=5, pady=5, sticky="w"
        )

        self.cbo_modulo = ttk.Combobox(
            formulario,
            state="readonly",
            width=20
        )
        self.cbo_modulo.grid(row=0, column=5, padx=5, pady=5)

        # Descripción
        ttk.Label(formulario, text="Descripción:").grid(
            row=1, column=0, padx=5, pady=5, sticky="nw"
        )

        self.txt_descripcion = tk.Text(
            formulario,
            width=70,
            height=4,
            font=("Segoe UI", 10)
        )
        self.txt_descripcion.grid(
            row=1,
            column=1,
            columnspan=5,
            padx=5,
            pady=5,
            sticky="w"
        )

        # Prioridad
        ttk.Label(formulario, text="Prioridad:").grid(
            row=2, column=0, padx=5, pady=5, sticky="w"
        )

        self.cbo_prioridad = ttk.Combobox(
            formulario,
            state="readonly",
            values=["baja", "media", "alta", "critica"],
            width=18
        )
        self.cbo_prioridad.set("media")
        self.cbo_prioridad.grid(row=2, column=1, padx=5, pady=5)

        # Estado
        ttk.Label(formulario, text="Estado:").grid(
            row=2, column=2, padx=5, pady=5, sticky="w"
        )

        self.cbo_estado = ttk.Combobox(
            formulario,
            state="readonly",
            values=[
                "pendiente",
                "en_proceso",
                "revision",
                "completada"
            ],
            width=20
        )
        self.cbo_estado.set("pendiente")
        self.cbo_estado.grid(row=2, column=3, padx=5, pady=5)

        # Responsable
        ttk.Label(formulario, text="Responsable:").grid(
            row=2, column=4, padx=5, pady=5, sticky="w"
        )

        self.cbo_responsable = ttk.Combobox(
            formulario,
            state="readonly",
            width=25
        )
        self.cbo_responsable.grid(row=2, column=5, padx=5, pady=5)

        # Fecha asignación
        ttk.Label(formulario, text="Fecha asignación:").grid(
            row=3, column=0, padx=5, pady=5, sticky="w"
        )

        self.fecha_asignacion = DateEntry(
            formulario,
            width=17,
            date_pattern="dd/mm/yyyy"
        )
        self.fecha_asignacion.grid(row=3, column=1, padx=5, pady=5)

        # Fecha límite
        ttk.Label(formulario, text="Fecha límite:").grid(
            row=3, column=2, padx=5, pady=5, sticky="w"
        )

        self.fecha_limite = DateEntry(
            formulario,
            width=17,
            date_pattern="dd/mm/yyyy"
        )
        self.fecha_limite.grid(row=3, column=3, padx=5, pady=5)

        # Avance
        ttk.Label(formulario, text="Avance (%):").grid(
            row=3, column=4, padx=5, pady=5, sticky="w"
        )

        self.txt_avance = ttk.Entry(formulario, width=10)
        self.txt_avance.insert(0, "0")
        self.txt_avance.grid(row=3, column=5, padx=5, pady=5, sticky="w")

        # Dependencias
        ttk.Label(formulario, text="Dependencias:").grid(
            row=4, column=0, padx=5, pady=5, sticky="nw"
        )

        dependencias_frame = ttk.Frame(formulario)
        dependencias_frame.grid(
            row=4,
            column=1,
            columnspan=5,
            padx=5,
            pady=5,
            sticky="w"
        )

        self.lista_dependencias = tk.Listbox(
            dependencias_frame,
            selectmode="multiple",
            height=4,
            width=55
        )
        self.lista_dependencias.pack(side="left")

        ttk.Label(
            dependencias_frame,
            text="Opcional: seleccione tareas predecesoras"
        ).pack(side="left", padx=10)

        # Botones
        botones = ttk.Frame(contenedor)
        botones.pack(fill="x", pady=8)

        self.crear_boton(
            botones, "Nuevo", self.nuevo, "#2563EB"
        )

        self.crear_boton(
            botones, "Guardar", self.guardar, "#16A34A"
        )

        self.crear_boton(
            botones, "Actualizar", self.actualizar, "#F59E0B"
        )

        self.crear_boton(
            botones, "Eliminar", self.eliminar, "#DC2626"
        )

        self.crear_boton(
            botones, "Refrescar", self.listar_tareas, "#6B7280"
        )

        self.crear_boton(
            botones, "Excel", self.exportar_excel_tareas, "#15803D"
        )

        self.crear_boton(
            botones, "PDF", self.exportar_pdf_tareas, "#B91C1C"
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
            text="Videojuego:"
        ).pack(side="left", padx=5)

        self.cbo_filtro_videojuego = ttk.Combobox(
            filtros,
            state="readonly",
            width=22
        )
        self.cbo_filtro_videojuego.pack(side="left", padx=5)

        ttk.Label(
            filtros,
            text="Estado:"
        ).pack(side="left", padx=5)

        self.cbo_filtro_estado = ttk.Combobox(
            filtros,
            state="readonly",
            values=[
                "Todos",
                "pendiente",
                "en_proceso",
                "revision",
                "completada"
            ],
            width=15
        )
        self.cbo_filtro_estado.set("Todos")
        self.cbo_filtro_estado.pack(side="left", padx=5)

        ttk.Label(
            filtros,
            text="Responsable:"
        ).pack(side="left", padx=5)

        self.cbo_filtro_responsable = ttk.Combobox(
            filtros,
            state="readonly",
            width=22
        )
        self.cbo_filtro_responsable.pack(side="left", padx=5)

        tk.Button(
            filtros,
            text="Aplicar filtros",
            command=self.listar_tareas,
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
        tabla_frame.pack(fill="both", expand=True, pady=10)

        columnas = (
            "id",
            "codigo",
            "videojuego",
            "modulo",
            "descripcion",
            "prioridad",
            "estado",
            "responsable",
            "fecha_asignacion",
            "fecha_limite",
            "avance",
            "dependencias",
            "vencida"
        )

        self.tabla = ttk.Treeview(
            tabla_frame,
            columns=columnas,
            show="headings"
        )

        encabezados = {
            "id": "ID",
            "codigo": "Código",
            "videojuego": "Videojuego",
            "modulo": "Módulo",
            "descripcion": "Descripción",
            "prioridad": "Prioridad",
            "estado": "Estado",
            "responsable": "Responsable",
            "fecha_asignacion": "Asignación",
            "fecha_limite": "Límite",
            "avance": "Avance %",
            "dependencias": "Dependencias",
            "vencida": "Vencida"
        }

        for columna in columnas:
            self.tabla.heading(
                columna,
                text=encabezados[columna]
            )
            self.tabla.column(
                columna,
                width=110,
                anchor="center"
            )

        self.tabla.column("id", width=50)
        self.tabla.column("codigo", width=100)
        self.tabla.column("videojuego", width=150)
        self.tabla.column("modulo", width=100)
        self.tabla.column("descripcion", width=250)
        self.tabla.column("responsable", width=170)
        self.tabla.column("dependencias", width=180)

        scroll_y = ttk.Scrollbar(
            tabla_frame,
            orient="vertical",
            command=self.tabla.yview
        )

        scroll_x = ttk.Scrollbar(
            tabla_frame,
            orient="horizontal",
            command=self.tabla.xview
        )

        self.tabla.configure(
            yscrollcommand=scroll_y.set,
            xscrollcommand=scroll_x.set
        )

        self.tabla.pack(
            side="top",
            fill="both",
            expand=True
        )

        scroll_y.pack(
            side="right",
            fill="y"
        )

        scroll_x.pack(
            side="bottom",
            fill="x"
        )

        self.tabla.bind(
            "<<TreeviewSelect>>",
            self.seleccionar_registro
        )

    def crear_boton(self, parent, texto, comando, color):
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
        ).pack(side="left", padx=5)

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

            # Videojuegos
            cursor.execute("""
                SELECT id_videogame, codigo, titulo
                FROM videogames
                ORDER BY titulo
            """)

            self.videojuegos.clear()

            valores_videojuegos = []

            for fila in cursor.fetchall():
                id_videojuego = fila[0]
                codigo = fila[1]
                titulo = fila[2]

                texto = f"{codigo} - {titulo}"

                self.videojuegos[texto] = id_videojuego
                valores_videojuegos.append(texto)

            self.cbo_videojuego["values"] = valores_videojuegos
            self.cbo_filtro_videojuego["values"] = [
                "Todos"
            ] + valores_videojuegos

            self.cbo_filtro_videojuego.set("Todos")

            # Módulos
            cursor.execute("""
                SELECT id_modulo, nombre
                FROM modulos_desarrollo
                ORDER BY nombre
            """)

            self.modulos.clear()

            valores_modulos = []

            for fila in cursor.fetchall():
                self.modulos[fila[1]] = fila[0]
                valores_modulos.append(fila[1])

            self.cbo_modulo["values"] = valores_modulos

            # Empleados
            cursor.execute("""
                SELECT id_empleado, nombres, apellidos
                FROM empleados
                WHERE activo = 1
                ORDER BY apellidos, nombres
            """)

            self.empleados.clear()

            valores_empleados = []

            for fila in cursor.fetchall():
                texto = f"{fila[0]} - {fila[1]} {fila[2]}"

                self.empleados[texto] = fila[0]
                valores_empleados.append(texto)

            self.cbo_filtro_responsable["values"] = [
                "Todos"
            ] + valores_empleados

            self.cbo_filtro_responsable.set("Todos")

            cursor.close()

        except Exception as e:
            messagebox.showerror(
                "Error",
                f"No se pudieron cargar los catálogos:\n{e}"
            )

        finally:
            if conexion:
                cerrar_conexion(conexion)

    # =========================================================
    # RESPONSABLES DEL VIDEOJUEGO
    # =========================================================

    def cargar_responsables(self, event=None):
        texto_videojuego = self.cbo_videojuego.get()

        if not texto_videojuego:
            return

        id_videojuego = self.videojuegos.get(texto_videojuego)

        if not id_videojuego:
            return

        conexion = None

        try:
            conexion = conectar()

            if conexion is None:
                return

            cursor = conexion.cursor()

            cursor.execute("""
                SELECT e.id_empleado, e.nombres, e.apellidos
                FROM empleados e
                INNER JOIN asignaciones_proyecto a
                    ON a.id_empleado = e.id_empleado
                WHERE a.id_videogame = %s
                  AND e.activo = 1
                ORDER BY e.apellidos, e.nombres
            """, (id_videojuego,))

            self.empleados.clear()

            valores = []

            for fila in cursor.fetchall():
                texto = f"{fila[0]} - {fila[1]} {fila[2]}"
                self.empleados[texto] = fila[0]
                valores.append(texto)

            self.cbo_responsable["values"] = valores

            if valores:
                self.cbo_responsable.set("")

            cursor.close()

        except Exception as e:
            messagebox.showerror(
                "Error",
                f"No se pudieron cargar los responsables:\n{e}"
            )

        finally:
            if conexion:
                cerrar_conexion(conexion)

    # =========================================================
    # DEPENDENCIAS
    # =========================================================

    def cargar_dependencias(self, id_tarea_actual=None):
        conexion = None

        try:
            conexion = conectar()

            if conexion is None:
                return

            cursor = conexion.cursor()

            if id_tarea_actual:
                cursor.execute("""
                    SELECT id_tarea, codigo
                    FROM tareas
                    WHERE id_tarea <> %s
                    ORDER BY codigo
                """, (id_tarea_actual,))
            else:
                cursor.execute("""
                    SELECT id_tarea, codigo
                    FROM tareas
                    ORDER BY codigo
                """)

            self.tareas_ids.clear()
            self.lista_dependencias.delete(0, tk.END)

            for fila in cursor.fetchall():
                id_tarea = fila[0]
                codigo = fila[1]

                self.tareas_ids[codigo] = id_tarea
                self.lista_dependencias.insert(
                    tk.END,
                    codigo
                )

            cursor.close()

        except Exception as e:
            messagebox.showerror(
                "Error",
                f"No se pudieron cargar las dependencias:\n{e}"
            )

        finally:
            if conexion:
                cerrar_conexion(conexion)

    # =========================================================
    # VALIDACIONES
    # =========================================================

    def obtener_datos(self):
        codigo = self.txt_codigo.get().strip()

        if not codigo:
            raise ValueError("El código es obligatorio.")

        if len(codigo) < 3 or len(codigo) > 20:
            raise ValueError(
                "El código debe tener entre 3 y 20 caracteres."
            )

        videojuego_texto = self.cbo_videojuego.get()

        if not videojuego_texto:
            raise ValueError("Seleccione un videojuego.")

        id_videojuego = self.videojuegos.get(
            videojuego_texto
        )

        if not id_videojuego:
            raise ValueError("El videojuego seleccionado no es válido.")

        modulo_texto = self.cbo_modulo.get()

        if not modulo_texto:
            raise ValueError("Seleccione un módulo.")

        id_modulo = self.modulos.get(modulo_texto)

        if not id_modulo:
            raise ValueError("El módulo seleccionado no es válido.")

        descripcion = self.txt_descripcion.get(
            "1.0",
            tk.END
        ).strip()

        if not descripcion:
            raise ValueError("La descripción es obligatoria.")

        if len(descripcion) < 5:
            raise ValueError(
                "La descripción debe tener al menos 5 caracteres."
            )

        if len(descripcion) > 2000:
            raise ValueError(
                "La descripción no puede superar 2000 caracteres."
            )

        prioridad = self.cbo_prioridad.get()

        if prioridad not in (
            "baja",
            "media",
            "alta",
            "critica"
        ):
            raise ValueError("Seleccione una prioridad válida.")

        estado = self.cbo_estado.get()

        if estado not in (
            "pendiente",
            "en_proceso",
            "revision",
            "completada"
        ):
            raise ValueError("Seleccione un estado válido.")

        responsable_texto = self.cbo_responsable.get()

        if responsable_texto:
            id_responsable = self.empleados.get(
                responsable_texto
            )
        else:
            id_responsable = None

        # Fechas
        fecha_asignacion = self.fecha_asignacion.get_date()
        fecha_limite = self.fecha_limite.get_date()

        if fecha_limite < fecha_asignacion:
            raise ValueError(
                "La fecha límite no puede ser anterior "
                "a la fecha de asignación."
            )

        # Avance
        avance_texto = self.txt_avance.get().strip()

        if not avance_texto:
            raise ValueError("El porcentaje de avance es obligatorio.")

        try:
            avance = float(avance_texto)
        except ValueError:
            raise ValueError(
                "El porcentaje de avance debe ser numérico."
            )

        if avance < 0 or avance > 100:
            raise ValueError(
                "El porcentaje de avance debe estar entre 0 y 100."
            )

        # Si está completada, el procedimiento también lo fuerza a 100.
        if estado == "completada":
            avance = 100

        # Dependencias
        dependencias = []

        for indice in self.lista_dependencias.curselection():
            codigo_dependencia = self.lista_dependencias.get(indice)

            if codigo_dependencia in self.tareas_ids:
                dependencias.append(codigo_dependencia)

        dependencias_texto = ",".join(dependencias)

        return {
            "codigo": codigo,
            "id_videojuego": id_videojuego,
            "id_modulo": id_modulo,
            "descripcion": descripcion,
            "prioridad": prioridad,
            "estado": estado,
            "id_responsable": id_responsable,
            "fecha_asignacion": fecha_asignacion.strftime("%Y-%m-%d"),
            "fecha_limite": fecha_limite.strftime("%Y-%m-%d"),
            "avance": avance,
            "dependencias": dependencias_texto
        }

    # =========================================================
    # GUARDAR
    # =========================================================

    def guardar(self):
        conexion = None

        try:
            datos = self.obtener_datos()

            conexion = conectar()

            if conexion is None:
                return

            cursor = conexion.cursor()

            resultado = cursor.callproc(
                "sp_insertar_tarea",
                [
                    datos["codigo"],
                    datos["id_videojuego"],
                    datos["id_modulo"],
                    datos["descripcion"],
                    datos["prioridad"],
                    datos["estado"],
                    datos["id_responsable"],
                    datos["fecha_asignacion"],
                    datos["fecha_limite"],
                    datos["avance"],
                    datos["dependencias"],
                    None
                ]
            )

            conexion.commit()

            nuevo_id = resultado[-1]

            cursor.close()

            messagebox.showinfo(
                "Éxito",
                f"Tarea registrada correctamente.\n\nID: {nuevo_id}"
            )

            self.nuevo()
            self.listar_tareas()

        except Exception as e:
            if conexion:
                try:
                    conexion.rollback()
                except Exception:
                    pass

            messagebox.showerror(
                "Error",
                f"No se pudo guardar la tarea:\n{e}"
            )

        finally:
            if conexion:
                cerrar_conexion(conexion)

    # =========================================================
    # LISTAR
    # =========================================================

    def listar_tareas(self):
        conexion = None

        try:
            for item in self.tabla.get_children():
                self.tabla.delete(item)

            # Filtro videojuego
            videojuego_filtro = self.cbo_filtro_videojuego.get()

            if videojuego_filtro == "Todos" or not videojuego_filtro:
                id_videojuego = None
            else:
                id_videojuego = self.videojuegos.get(
                    videojuego_filtro
                )

            # Filtro estado
            estado = self.cbo_filtro_estado.get()

            if estado == "Todos" or not estado:
                estado = None

            # Filtro responsable
            responsable_filtro = (
                self.cbo_filtro_responsable.get()
            )

            if (
                responsable_filtro == "Todos"
                or not responsable_filtro
            ):
                id_responsable = None
            else:
                id_responsable = self.empleados.get(
                    responsable_filtro
                )

            conexion = conectar()

            if conexion is None:
                return

            cursor = conexion.cursor()

            cursor.callproc(
                "sp_listar_tareas",
                [
                    id_videojuego,
                    estado,
                    id_responsable
                ]
            )

            for resultado in cursor.stored_results():

                for fila in resultado.fetchall():

                    # El procedimiento devuelve 17 campos.
                    #
                    # 0 id
                    # 1 codigo
                    # 2 videojuego
                    # 3 modulo
                    # 4 descripcion
                    # 5 prioridad
                    # 6 estado
                    # 7 responsable
                    # 8 fecha_asignacion
                    # 9 fecha_limite
                    # 10 avance
                    # 11 dependencias
                    # 12 vencida
                    # 13 id_videogame
                    # 14 id_modulo
                    # 15 id_responsable

                    vencida = "SÍ" if fila[12] else "NO"

                    self.tabla.insert(
                        "",
                        "end",
                        values=(
                            fila[0],
                            fila[1],
                            fila[2],
                            fila[3],
                            fila[4],
                            fila[5],
                            fila[6],
                            fila[7] or "Sin asignar",
                            fila[8],
                            fila[9],
                            fila[10],
                            fila[11] or "Ninguna",
                            vencida
                        )
                    )

            cursor.close()

            self.cargar_dependencias(
                self.id_tarea
            )

        except Exception as e:
            messagebox.showerror(
                "Error",
                f"No se pudieron listar las tareas:\n{e}"
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

        try:
            self.id_tarea = int(valores[0])

            self.txt_codigo.delete(0, tk.END)
            self.txt_codigo.insert(0, valores[1])

            # Buscar videojuego
            for texto, id_videojuego in self.videojuegos.items():
                if texto.endswith(
                    f" - {valores[2]}"
                ):
                    self.cbo_videojuego.set(texto)
                    break

            self.cargar_responsables()

            # Buscar responsable
            responsable = valores[7]

            if responsable != "Sin asignar":
                for texto in self.empleados:
                    if texto.split(" - ", 1)[-1] == responsable:
                        self.cbo_responsable.set(texto)
                        break
            else:
                self.cbo_responsable.set("")

            # Módulo
            self.cbo_modulo.set(valores[3])

            # Descripción
            self.txt_descripcion.delete(
                "1.0",
                tk.END
            )
            self.txt_descripcion.insert(
                "1.0",
                valores[4]
            )

            self.cbo_prioridad.set(valores[5])
            self.cbo_estado.set(valores[6])

            # Fechas
            self.fecha_asignacion.set_date(
                datetime.strptime(
                    str(valores[8]),
                    "%Y-%m-%d"
                ).date()
            )

            self.fecha_limite.set_date(
                datetime.strptime(
                    str(valores[9]),
                    "%Y-%m-%d"
                ).date()
            )

            self.txt_avance.delete(0, tk.END)
            self.txt_avance.insert(
                0,
                valores[10]
            )

            # Dependencias
            self.cargar_dependencias(
                self.id_tarea
            )

            dependencias = valores[11]

            if dependencias and dependencias != "Ninguna":
                lista = [
                    x.strip()
                    for x in str(dependencias).split(",")
                ]

                for indice in range(
                    self.lista_dependencias.size()
                ):
                    if self.lista_dependencias.get(indice) in lista:
                        self.lista_dependencias.selection_set(
                            indice
                        )

        except Exception as e:
            messagebox.showerror(
                "Error",
                f"No se pudo cargar la tarea:\n{e}"
            )

    # =========================================================
    # ACTUALIZAR
    # =========================================================

    def actualizar(self):
        if not self.id_tarea:
            messagebox.showwarning(
                "Actualizar",
                "Seleccione una tarea."
            )
            return

        confirmar = messagebox.askyesno(
            "Confirmar actualización",
            "¿Desea actualizar esta tarea?"
        )

        if not confirmar:
            return

        conexion = None

        try:
            datos = self.obtener_datos()

            conexion = conectar()

            if conexion is None:
                return

            cursor = conexion.cursor()

            cursor.callproc(
                "sp_actualizar_tarea",
                [
                    self.id_tarea,
                    datos["codigo"],
                    datos["id_videojuego"],
                    datos["id_modulo"],
                    datos["descripcion"],
                    datos["prioridad"],
                    datos["estado"],
                    datos["id_responsable"],
                    datos["fecha_asignacion"],
                    datos["fecha_limite"],
                    datos["avance"],
                    datos["dependencias"]
                ]
            )

            conexion.commit()

            cursor.close()

            messagebox.showinfo(
                "Éxito",
                "Tarea actualizada correctamente."
            )

            self.nuevo()
            self.listar_tareas()

        except Exception as e:
            if conexion:
                try:
                    conexion.rollback()
                except Exception:
                    pass

            messagebox.showerror(
                "Error",
                f"No se pudo actualizar la tarea:\n{e}"
            )

        finally:
            if conexion:
                cerrar_conexion(conexion)

    # =========================================================
    # ELIMINAR
    # =========================================================

    def eliminar(self):
        if not self.id_tarea:
            messagebox.showwarning(
                "Eliminar",
                "Seleccione una tarea."
            )
            return

        confirmar = messagebox.askyesno(
            "Confirmar eliminación",
            "¿Está seguro de eliminar esta tarea?"
        )

        if not confirmar:
            return

        conexion = None

        try:
            conexion = conectar()

            if conexion is None:
                return

            cursor = conexion.cursor()

            cursor.callproc(
                "sp_eliminar_tarea",
                [self.id_tarea]
            )

            conexion.commit()

            cursor.close()

            messagebox.showinfo(
                "Éxito",
                "Tarea eliminada correctamente."
            )

            self.nuevo()
            self.listar_tareas()

        except Exception as e:
            if conexion:
                try:
                    conexion.rollback()
                except Exception:
                    pass

            messagebox.showerror(
                "Error",
                f"No se pudo eliminar la tarea:\n{e}"
            )

        finally:
            if conexion:
                cerrar_conexion(conexion)

    # =========================================================
    # NUEVO
    # =========================================================

    def nuevo(self):
        self.id_tarea = None

        self.txt_codigo.delete(0, tk.END)

        self.cbo_videojuego.set("")
        self.cbo_modulo.set("")
        self.cbo_responsable.set("")

        self.txt_descripcion.delete(
            "1.0",
            tk.END
        )

        self.cbo_prioridad.set("media")
        self.cbo_estado.set("pendiente")

        self.txt_avance.delete(0, tk.END)
        self.txt_avance.insert(0, "0")

        self.lista_dependencias.selection_clear(
            0,
            tk.END
        )

        self.cargar_dependencias()

    # =========================================================
    # EXPORTAR EXCEL
    # =========================================================

    def exportar_excel_tareas(self):
        filas = []

        for item in self.tabla.get_children():
            filas.append(
                self.tabla.item(
                    item,
                    "values"
                )
            )

        if not filas:
            messagebox.showwarning(
                "Excel",
                "No hay tareas para exportar."
            )
            return

        encabezados = [
            self.tabla.heading(columna)["text"]
            for columna in self.tabla["columns"]
        ]

        try:
            nombre = (
                f"tareas_"
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
                f"No se pudo generar el Excel:\n{e}"
            )

    # =========================================================
    # EXPORTAR PDF
    # =========================================================

    def exportar_pdf_tareas(self):
        filas = []

        for item in self.tabla.get_children():
            filas.append(
                self.tabla.item(
                    item,
                    "values"
                )
            )

        if not filas:
            messagebox.showwarning(
                "PDF",
                "No hay tareas para exportar."
            )
            return

        encabezados = [
            self.tabla.heading(columna)["text"]
            for columna in self.tabla["columns"]
        ]

        try:
            nombre = (
                f"tareas_"
                f"{datetime.now().strftime('%Y%m%d_%H%M%S')}"
                f".pdf"
            )

            ruta = exportar_pdf(
                filas,
                encabezados,
                nombre,
                titulo="Reporte de Tareas"
            )

            messagebox.showinfo(
                "PDF",
                f"Archivo generado correctamente.\n\n{ruta}"
            )

        except Exception as e:
            messagebox.showerror(
                "PDF",
                f"No se pudo generar el PDF:\n{e}"
            )