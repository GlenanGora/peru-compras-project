# -*- coding: utf-8 -*-
"""

"""

import pandas as pd
import os
import urllib.request
from urllib.request import urlopen

# instalar la libreria pdfplumber
#!pip install pdfplumber

import pdfplumber
import re
from collections import namedtuple


# Ver la ruta actual
# os.getcwd() 

file="/path_del_archivo/down_ordencompra.txt"
carpeta_destino="/path_to_save_pdf/pdf/"
archivo = pd.read_csv(file,index_col=None)

# ----------------------------------------------------------------------
# descargamos los archivos pdf y los almacenamos en gdrive
# ----------------------------------------------------------------------

for indice, fila in archivo.iterrows():
    id_registro = fila['id_orden']
    url_pdf = fila['orden_electronica_generada']
    nombre_archivo = os.path.join(carpeta_destino, f"{id_registro}.pdf")

    try:
        with urlopen(url_pdf) as response, open(nombre_archivo, 'wb') as archivo:
            archivo.write(response.read())
        print(f"Archivo {nombre_archivo} descargado correctamente.")
    except Exception as e:
        print(f"Fallo al descargar el archivo {nombre_archivo}. Error: {str(e)}")

# ----------------------------------------------------------------------
# Leemos cada pdf descargado y obtenemos los datos necesarios segun el 
# criterio de busqueda para el codigo de producto, precio unitario y cantidad
# ----------------------------------------------------------------------

lista = []
ruta_directorio=carpeta_destino
cabecera = namedtuple('datos', 'id_registro cod_articulo cantidad preciounit igv importe')
re_buscar_re= re.compile(r"(([\w-]+)\s+(\d+)\s+([\d.,]+)\s+([\d.,]+)\s+([\d.,]+))$")
# Obtener la lista de archivos en el directorio
archivos_en_directorio = os.listdir(ruta_directorio)
for fila in archivos_en_directorio:
  try:
    with pdfplumber.open(ruta_directorio + fila) as pdf:
      _l = len(pdf.pages)
      for i in range(_l-1):
        page = pdf.pages[i+1]
        texto = page.extract_text()

        for row in texto.split("\n"):
          linea = re.search(re_buscar_re,row)
          if linea:
              id_archivo=os.path.splitext(fila)[0]
              cod_articulo = linea.group(2)
              cantidad = linea.group(3)
              preciounit = linea.group(4)
              igv = linea.group(5)
              importe = linea.group(6)
              lista.append(cabecera(id_archivo, cod_articulo,cantidad,preciounit,igv,importe))
  except Exception as e:
    print(f"Fallo al abrir el archivo {ruta_directorio + fila}. Error: {str(e)}")

pdffile = pd.DataFrame(lista)


##############################################################################
# Limpiamos los datos
# Los campos numericos cargaron con '.' y ',' esto es un problema al momento
# de guardar como campo numerico.
##############################################################################

def reemplazacoma(valor):
  if isinstance(valor,str):
    return valor.replace(',','')
  return valor

pdffile['preciounit']=pdffile['preciounit'].apply(reemplazacoma)
pdffile['cantidad']=pdffile['cantidad'].apply(reemplazacoma)
pdffile['igv']=pdffile['igv'].apply(reemplazacoma)
pdffile['importe']=pdffile['importe'].apply(reemplazacoma)

pdffile.to_csv("/path_to_save/oc_detalles_clean.csv",index=False)

#----------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------
# Finalmente el archivo oc_detalles_clean.csv lo cargamos a la tabla: det_ocompras en postgres
# esto lo podemos realizar con el comando COPY o usando Pentaho o directamente desde python
#----------------------------------------------------------------------------------------------
#----------------------------------------------------------------------------------------------