import os
import glob
import matlab.engine
from threading import Thread

# Constantes configurables
FORCE_GRAFICAR = False  # Cambiar a True para forzar la regeneración
AP_P_CONSTANT = 600
SAMPLES_DIR = "samples"
GRAPHS_DIR = "../samples/samples_graphs"
RESULTS_DIR = "../bode"

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
        
        # 4. Ejecutar graficar.m
        try:
            print("🚀 Ejecutando script matlab_plot_and_analyze_script.m...")
            
            def execute_script():
                try:
                    self.eng.run('matlab_plot_and_analyze_script.m', nargout=0)
                    print("✅ Script gramatlab_plot_and_analyze_scriptficar.m ejecutado exitosamente")
                except Exception as e:
                    print(f"❌ Error ejecutando matlab_plot_and_analyze_script.m: {e}")
            
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
