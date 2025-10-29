import os
import glob
import matlab.engine
from threading import Thread

# Constantes configurables
FORCE_GRAFICAR = False  # Cambiar a True para forzar la regeneración
AP_P_CONSTANT = 600
SAMPLES_DIR = "samples"
GRAPHS_DIR = "samples/samples_graphs"
RESULTS_DIR = "bode_results"

class Execute_analysis_and_plot_class():
    def __init__(self):
        self.eng = self.connect_matlab()
        self.Execute_analysis_and_plot()

    def connect_matlab(self):
        """Conectar con instancia existente de MATLAB o iniciar una nueva"""
        try:
            eng = matlab.engine.connect_matlab()
            print("✅ Conectado a instancia existente de MATLAB")
            return eng
        except Exception as e:
            try:
                eng = matlab.engine.start_matlab()
                print("✅ Nueva instancia de MATLAB iniciada")
                return eng
            except Exception as e2:
                print(f"❌ No se pudo conectar con MATLAB: {e2}")
                return None
        
    def Execute_analysis_and_plot(self):
        """Generar y ejecutar graficar.m basado en plantilla y análisis previo"""
        if not self.eng:
            return
        
        # 1. Calcular min_omega, max_omega desde los archivos analizados
        if not self.files_data:
            print("❌ No hay datos de archivos para generar graficar.m")
            return
        
        # Extraer todas las frecuencias
        frecuencias = [fd['freq'] for fd in self.files_data]
        min_omega = min(frecuencias)
        max_omega = max(frecuencias)
        
        print(f"📊 Parámetros calculados: min={min_omega}, max={max_omega}")
        
        # 2. Verificar si las gráficas ya existen (a menos que FORCE_GRAFICAR sea True)
        existing_graphs = glob.glob(os.path.join(GRAPHS_DIR, "omega_*.fig"))
        if existing_graphs and not FORCE_GRAFICAR:
            print(f"✅ Gráficas existentes encontradas: {len(existing_graphs)} archivos")
            return
        
        if FORCE_GRAFICAR:
            print("⚡ FORCE_GRAFICAR activado - Regenerando gráficas")
        
        # 3. Leer y modificar la plantilla
        try:
            with open('graficar_template.m', 'r', encoding='utf-8') as f:
                template = f.read()
            
            # Reemplazar valores (aunque el nuevo script los ignora, los mantenemos por compatibilidad)
            template = template.replace('min_omega = 5;', f'min_omega = {min_omega};')
            template = template.replace('max_omega = 35;', f'max_omega = {max_omega};')
            
            # Escribir el archivo graficar.m en el directorio raíz
            with open('graficar.m', 'w', encoding='utf-8') as f:
                f.write(template)
            
            print("✅ Script graficar.m generado")
            
        except Exception as e:
            print(f"❌ Error procesando plantilla: {e}")
            return
        
        # 4. Ejecutar graficar.m
        try:
            print("🚀 Ejecutando script graficar.m...")
            
            def execute_script():
                try:
                    self.eng.run('graficar.m', nargout=0)
                    print("✅ Script graficar.m ejecutado exitosamente")
                except Exception as e:
                    print(f"❌ Error ejecutando graficar.m: {e}")
            
            thread = Thread(target=execute_script)
            thread.daemon = True
            thread.start()
            thread.join()
            
        except Exception as e:
            print(f"❌ Error al intentar ejecutar graficar.m: {e}")
    
    def main():
        print("=" * 60)
        print("Executing analysis and plotting..")
        print("=" * 60)
        analyzer = Execute_analysis_and_plot_class()

    if __name__ == "__main__":
        main()
