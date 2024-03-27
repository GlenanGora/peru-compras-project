### Procedimiento para la descarga de archivos pdf, scraping y almacenamiento de datos
--

Con tu cuenta de gmail accede a la dirección: [https://colab.research.google.com/](https://colab.research.google.com/) y crea un nuevo cuaderno. subir el archivo que se encuentra en esta carpeta **descarga_oc_os.py** 

Exportar de la tabla **fact_ocompras** los campos *"id_orden","orden_electronica_generada"* en un archivo txt, estos campos permitirán identificar cada registro con el archivo pdf para descargarlo y luego mediante scraping, de cada archivo, obtener los detalles de la compra tales como el código del producto, precio unitario y la cantidad, lo que permitirá evaluar si los precios de compra son similares en las distintas entidades o tienen rangos totalmente distintos por cada producto.

Subir el archivo exportado en formato txt a tu google Drive, es importante que el archivo deba tener la siguiente estructura:

    *"id_orden","orden_electronica_generada"*

Vuelve a google Collab y sigue las instrucciones del archivo **descarga_oc_os.py**

### Descarga de archivos pdf
<image src="/images/descargaPDF.png" alt="Descarga de archivos pdf">
