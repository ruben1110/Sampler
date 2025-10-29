import re
import os

# Macros con los nombres de archivo
MACRO_ARCHIVO_FUENTE = "C:/Users/R/Desktop/Workspaces/STM32CudeIDE/Blackpill_01_blink/Core/Src/main.c"
MACRO_ARCHIVO_PLANTILLA = "C:/Users/R/Downloads/ABCD_SERVOMECANISMOS/practica4/Sampler/resources/sampler_code_template.txt"
MACRO_ARCHIVO_SALIDA = "C:/Users/R/Downloads/ABCD_SERVOMECANISMOS/practica4/Sampler/resources/sampler_code.cpp"
MACRO_ARCHIVO_BAT = "C:/Users/R/Downloads/ABCD_SERVOMECANISMOS/practica4/Sampler/utils/execute_sampler.bat"

# Expresión regular para encontrar el bloque y capturar los valores
patron = r'/\*OMEGA_INIT\*/(.*?)/\*OMEGA_END\*/'
regex = re.compile(patron, re.DOTALL)

# 1. Leer y extraer valores del archivo main.c
with open(MACRO_ARCHIVO_FUENTE, 'r') as archivo:
    contenido = archivo.read()
    bloque = regex.search(contenido)
    
    if not bloque:
        raise ValueError("No se encontró el bloque OMEGA en el archivo")
    
    # Extraer valores numéricos
    OMEGA_MIN = int(re.search(r'#define OMEGA_MIN\s+(\d+)', bloque.group(1)).group(1))
    OMEGA_MAX = int(re.search(r'#define OMEGA_MAX\s+(\d+)', bloque.group(1)).group(1))
    OMEGA_INCREMENT = int(re.search(r'#define OMEGA_INCREMENT\s+(\d+)', bloque.group(1)).group(1))

# 2. Procesar plantilla
with open(MACRO_ARCHIVO_PLANTILLA, 'r') as plantilla:
    contenido_plantilla = plantilla.read()

# Reemplazar valores en la plantilla
contenido_plantilla = re.sub(
    r'#define OMEGA_MIN\s+\d+',
    f'#define OMEGA_MIN {OMEGA_MIN}',
    contenido_plantilla
)
contenido_plantilla = re.sub(
    r'#define OMEGA_MAX\s+\d+',
    f'#define OMEGA_MAX {OMEGA_MAX}',
    contenido_plantilla
)
contenido_plantilla = re.sub(
    r'#define OMEGA_INCREMENT\s+\d+',
    f'#define OMEGA_INCREMENT {OMEGA_INCREMENT}',
    contenido_plantilla
)

# 3. Guardar archivo de salida
with open(MACRO_ARCHIVO_SALIDA, 'w+') as salida:
    salida.write(contenido_plantilla)

# 4. Ejecutar archivo BAT
os.system(MACRO_ARCHIVO_BAT)
