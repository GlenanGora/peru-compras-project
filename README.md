## Identificando valores atípicos en la compra de bienes usando la data de la plataforma Perú Compras
---
#### Tabla de Contenidos

* Descripción del proyecto
* Objetivo del Proyecto
* Fuentes de información
* Arquitectura de datos
* Herramientas y Tecnología usada
* Ejecución del proyecto

---
#### Descripción del Proyecto
La elaboración del presente proyecto de ingeniería de datos y analítica será completamente local utilizando herramientas instalables en la PC y algunas de la nube, todas gratuitas, lo que permite ahorrar costos en el alquiler de plataformas cloud, o herramientas que requieren algún tipo de pago.
[www.datosabiertos.gob.pe](https://www.datosabiertos.gob.pe) es la plataforma del estado Peruano en donde las instituciones públicas comparten sus datos, de ahí obtendremos los archivos de las órdenes de compra y el padrón de la sunat, donde se encuentran los registros de las empresas proveedoras y entidades del estado.
La base de datos a usar será **PostgreSQL**, para la limpieza y carga de datos **Pentaho**, para la descarga automatizada de las órdenes de compra (*en formato pdf*), reconocimiento y almacenamiento del contenido en una base de datos estructurada se usará **Python** mediante **Google Collab**, para el almacenamiento de los archivos pdf se utilizará **Google Drive** y finalmente para la visualización se usará **Power BI Desktop**.
La técnica estadística utlizada para determinar los valores atípicos de los datos cuán alejado se encuentran los precios de la media y analizar si existen sobrecostos es la **desviación estándar** y algunos gráficos.

---
#### Objetivo del Proyecto
Este proyecto de ingenieria de datos tiene dos objetivos: analizar valores atípicos en las compras de bienes realizadas mediante la plataforma Perú Compras del estado Peruano, realizada por las distintas entidades gubernamentales y utilizar herramientas gratuitas para realizar todo el proceso de ingeniería de datos como: ingesta, limpieza, modelado y visualización de datos.

---
#### Fuentes de datos

1. [Órdenes de compra](https://www.datosabiertos.gob.pe/dataset/%C3%B3rdenes-de-compra-realizadas-trav%C3%A9s-de-los-cat%C3%A1logos-electr%C3%B3nicos-central-de-compras): del portal de datos abiertos de las compras realizadas por Perú Compras.
2. [Padrón RUC de Sunat](https://www.datosabiertos.gob.pe/dataset/padr%C3%B3n-ruc-superintendencia-nacional-de-aduanas-y-de-administraci%C3%B3n-tributaria-sunat-0): Registro de las empresas formalmente constituidas

---

#### Arquitectura de datos

<image src="/images/arquitectura.png" alt="Descarga de archivos pdf">

#### Herramientas y Tecnologia usada
---
1. **Google Collab** : Infraestructura de código
2. **Python** : Web Scraping / PDF Scraping / Limpieza
3. **Pentaho**: Carga de datos masivos a la base de datos local / Limpieza
4. **PostgreSQL** : Motor de Base de datos
5. **Power BI**: Visualización 

### Ejecutando el Proyecto
---
Las órdenes de compra se descargaron todos del periodo 2022 hasta agosto del 2023 y el padrón sunat se descargó del último mes disponible.
* Crear la estructura de las tablas iniciales `sql/1.-Tablas_iniciales.sql`, se encuentra las tablas para el padron de la sunat, ordenes de compra y servicios.
* Ejecutar la carga de las ordenes de compra, ordenes de servicio, padron Sunat desde pentaho ubicado en la carpeta `/pentaho/load_oc_os.ktr` y `/pentaho/load_padronsunatDA.ktr`
* Ejecutar el script ubicado en `/sql/2.-Tablas_secundarias.sql` para la carga del resto de tablas y datos.
* El procedimiento para la descarga de las órdenes de compra (archivos pdf) y almacenarlos en gdrive, realización del scraping de los códigos de productos, precio unitario, cantidad, igv y total se encuentra en: `/carga/instrucciones.md`.
* Se puede conectar directamente a la base de datos para visualizar los datos y armar el modelo desde power bi.


## Observaciones
---
El total de registros con el que se cuenta es más de 200k de órdenes de compra, lo que significa la misma cantidad de archivos PDF a descargar y extraer información, para efectos de este proyecto y por el tiempo que implica descargar toda esa información, se procesaron alrededor de 25k órdenes de compra. Debido al tiempo que demora en descargar cada archivo PDF y realizar scrapping al mismo.
En esta primera etapa se observó que **se tiene que afinar/mejorar el patrón de extracción del código del articulo**, ya que se observaron diferentes casuísticas y formas en las que se presenta, pero para efectos de este proyecto, que puede seguir mejorando, se usará lo que se obtuvo en esta primera etapa.

## Resultados
---
Como se mencionó, la técnica para detectar datos atípicos fue la desviación estándar por cada grupo de articulos, y para una rápida identificación se usó el gráfico de la distribución normal.
Se dió formato condicional a los valores que superen 3 veces el valor de sigma, para identificar visualmente aquellos datos que son atípicos.

<image src="/images/Tablero.png" alt="Descarga de archivos pdf">

Se puede observar en la distribución, para el registro seleccionado, que existe un valor atípico, muy alejado de la media que puede indicarnos posibles sobre costos en la compra de un producto.
Se pudo observar también que para las regiones de la selva los costos de los productos son muy superiores a sus pares de la sierra o costa, por lo que una sugerencia es agrupar por regiones de la selva, sierra, costa o regiones del norte, centro, sur para realizar el análisis.
El archivo **pbix** lo puedes encontrar en la carpeta **powerbi/readme.md**

#### Contacto
Cualquier duda acerca del proyecto pueden escribir al siguiente correo: glenan.gora@gmail.com
