function graficar()
    clc; clear; close all;

    %% CONFIGURACIÓN - MACROS
    DIR_SAMPLES = '';
    DIR_GRAFICAS = '../graficas';
    DIR_FIGS = '../graficas/figs';
    DIR_BODE = '../bode';
    MAGNITUD_DE_FRECUENCIA_CORTE = 0;  % dB

    %% CREAR DIRECTORIOS
    if ~exist(DIR_GRAFICAS, 'dir'), mkdir(DIR_GRAFICAS); end
    if ~exist(DIR_FIGS, 'dir'), mkdir(DIR_FIGS); end
    if ~exist(DIR_BODE, 'dir'), mkdir(DIR_BODE); end

    %% ENCONTRAR Y PROCESAR ARCHIVOS
    archivos = dir(fullfile(DIR_SAMPLES, 'omega_*.txt'));
    if isempty(archivos)
        error('No se encontraron archivos omega_*.txt en %s', DIR_SAMPLES);
    end

    % Extraer frecuencias y ordenar
    frecuencias = zeros(length(archivos), 1);
    for i = 1:length(archivos)
        num_str = regexp(archivos(i).name, 'omega_(\d+)\.txt', 'tokens');
        frecuencias(i) = str2double(num_str{1}{1});
    end
    [frecuencias, idx] = sort(frecuencias);
    archivos = archivos(idx);

    fprintf('📁 Encontrados %d archivos\n', length(archivos));

    %% INICIALIZAR TABLA DE RESULTADOS
    resultados = [];

    %% PROCESAR CADA ARCHIVO
    for i = 1:length(archivos)
        nombre_archivo = archivos(i).name;
        freq = frecuencias(i);
        
        fprintf('📊 Procesando: %s (ω = %d rad/s)\n', nombre_archivo, freq);
        
        try
            % Leer datos
            datos = load(fullfile(DIR_SAMPLES, nombre_archivo));
            tiempo = datos(:,1);
            entrada = datos(:,2);
            salida = datos(:,3);
            
            % CÁLCULO DE LAS 11 COLUMNAS
            % 1. Frecuencia [rad/s] - usar 'freq'
            
            % 2. BMax (pico máximo de salida)
            BMax = max(salida);
            
            % 3. Bmin (pico mínimo de salida)  
            Bmin = min(salida);
            
            % 4. ΔB = BMax - Bmin
            delta_B = BMax - Bmin;
            
            % 5. Ap-p (constante)
            A_pp = max(entrada) - min(entrada);
            
            % 6. Gain = ΔB / Ap-p
            gain = delta_B / A_pp;
            
            % 7. Φ1 (tiempo del primer pico máximo en entrada)
            [~, idx_max_entrada] = max(entrada);
            phi1 = tiempo(idx_max_entrada);
            
            % 8. Φ2 (tiempo del primer pico máximo en salida)
            [~, idx_max_salida] = max(salida);
            phi2 = tiempo(idx_max_salida);
            
            % 9. ΔΦ = Φ2 - Φ1
            delta_phi =  phi1 - phi2;
            
            % 10. Phase = (180 * freq * ΔΦ) / π
            phase = (180 * freq * delta_phi) / pi;
            
            % 11. Magnitud = 20 * log10(Gain)
            magnitud = 20 * log10(gain);
            
            % Almacenar resultados
            resultados(i, :) = [freq, BMax, Bmin, delta_B, A_pp, gain, ...
                               phi1, phi2, delta_phi, phase, magnitud];
            
            %% GENERAR GRÁFICA INDIVIDUAL
            fig = figure('Visible', 'off', 'Position', [100, 100, 1000, 600]);
            
            % Graficar entrada y salida
            yyaxis left;
            h_entrada = plot(tiempo, entrada, 'b-', 'LineWidth', 2);
            ylabel('$A\sin(\omega t)$', 'Interpreter', 'latex', 'FontSize', 12);
            ylim([min(entrada)*1.1, max(entrada)*1.1]);
            
            yyaxis right;
            h_salida = plot(tiempo, salida, 'r-', 'LineWidth', 2);
            ylabel('$B\sin(\omega t + \Phi)$', 'Interpreter', 'latex', 'FontSize', 12);
            ylim([min(salida)*0.9, max(salida)*1.1]);
            
            % Configuración común
            xlim([0, tiempo(end)]);
            grid on;
            xlabel('$t[s]$', 'Interpreter', 'latex', 'FontSize', 12);
            titulo = sprintf('Respuesta del sistema con $\\omega = %d [\\frac{rad}{s}]$', freq);
            title(titulo, 'Interpreter', 'latex', 'FontSize', 14);
            
            %% AGREGAR DATATIPS EN PICOS
            % Calcular picos
            [~, idx_max_entrada] = max(entrada);
            [~, idx_min_entrada] = min(entrada);
            [~, idx_max_salida] = max(salida);
            [~, idx_min_salida] = min(salida);
            
            % Configurar DataTipTemplate en las LÍNEAS
            dtt_entrada = h_entrada.DataTipTemplate;
            dtt_entrada.Interpreter = 'latex';
            dtt_salida = h_salida.DataTipTemplate;
            dtt_salida.Interpreter = 'latex';

            h_entrada.DataTipTemplate.DataTipRows(1).Label = '$t = $';
            h_entrada.DataTipTemplate.DataTipRows(2).Label = '$A\sin(\omega t) = $';

            h_salida.DataTipTemplate.DataTipRows(1).Label = '$t = $';
            h_salida.DataTipTemplate.DataTipRows(2).Label = '$B\sin(\omega t + \Phi) = $';
            
            % Crear DataTips usando coordenadas (x, y)
            yyaxis left;
            datatip(h_entrada, tiempo(idx_max_entrada), entrada(idx_max_entrada));
            datatip(h_entrada, tiempo(idx_min_entrada), entrada(idx_min_entrada));
            
            yyaxis right;
            datatip(h_salida, tiempo(idx_max_salida), salida(idx_max_salida));
            datatip(h_salida, tiempo(idx_min_salida), salida(idx_min_salida));
            
            %% GUARDAR GRÁFICAS INDIVIDUALES
            % Guardar como FIG
            nombre_fig = sprintf('omega_%d.fig', freq);
            savefig(fig, fullfile(DIR_FIGS, nombre_fig));
            
            % Guardar como PNG
            nombre_png = sprintf('omega_%d.png', freq);
            saveas(fig, fullfile(DIR_GRAFICAS, nombre_png), 'png');
            
            close(fig);
            fprintf('   ✅ Gráfica guardada: %s\n', nombre_fig);
            
        catch ME
            fprintf('   ❌ Error procesando %s: %s\n', nombre_archivo, ME.message);
            continue;
        end
    end

    %% GUARDAR TABLA DE RESULTADOS
    guardar_tabla_resultados(resultados, DIR_BODE);

    %% GENERAR DIAGRAMA DE BODE
    generar_diagrama_bode(resultados, DIR_BODE, MAGNITUD_DE_FRECUENCIA_CORTE);

    fprintf('\n🎉 ANÁLISIS COMPLETADO\n');
    fprintf('📊 Resultados guardados en: %s/\n', DIR_BODE);
    fprintf('🖼️  Gráficas guardadas en: %s/ y %s/\n', DIR_GRAFICAS, DIR_FIGS);
end

%% FUNCIÓN PARA GUARDAR TABLA DE RESULTADOS
function guardar_tabla_resultados(resultados, dir_bode)
    % Crear tabla
    tabla = array2table(resultados, ...
        'VariableNames', {'frecuencia_rad_s', 'BMax', 'Bmin', 'delta_B', 'Ap_p', ...
                         'Gain', 'Phi1', 'Phi2', 'delta_Phi', 'Phase_grados', 'Magnitud_dB'});
    
    % Guardar como CSV
    writetable(tabla, fullfile(dir_bode, 'resultados_bode.csv'));
    
    % Guardar como TXT (solo datos, separado por tabs)
    writetable(tabla, fullfile(dir_bode, 'datos_bode.txt'), ...
               'Delimiter', '\t', 'WriteVariableNames', false);
    
    fprintf('📋 Tabla de resultados guardada en: %s/\n', dir_bode);
end

%% FUNCIÓN PARA GENERAR DIAGRAMA DE BODE
function generar_diagrama_bode(resultados, dir_bode, magnitud_corte)
    frecuencias = resultados(:,1);
    magnitudes = resultados(:,11);
    fases = resultados(:,10);
    
    % Crear figura
    fig_bode = figure('Position', [100, 100, 1200, 800]);
    
    %% SUBPLOT MAGNITUD
    subplot(2,1,1);
    h_mag = semilogx(frecuencias, magnitudes, 'bo-', 'LineWidth', 2, 'MarkerSize', 6);
    grid on;
    xlabel('$\omega [\frac{rad}{s}]$', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('$|G(j\omega)|[dB]$', 'Interpreter', 'latex', 'FontSize', 12);
    title('Diagrama de Bode - Magnitud', 'Interpreter', 'latex', 'FontSize', 14);
    
    %% SUBPLOT FASE
    subplot(2,1,2);
    h_phase = semilogx(frecuencias, fases, 'ro-', 'LineWidth', 2, 'MarkerSize', 6);
    grid on;
    xlabel('$\omega [\frac{rad}{s}]$', 'Interpreter', 'latex', 'FontSize', 12);
    ylabel('$\angle G(j\omega)[^{\circ}]$', 'Interpreter', 'latex', 'FontSize', 12);
    title('Diagrama de Bode - Fase', 'Interpreter', 'latex', 'FontSize', 14);
    
    %% AGREGAR DATATIPS EN MAGNITUD ESPECIFICADA
    % Encontrar punto más cercano a la magnitud de corte
    [~, idx_corte] = min(abs(magnitudes - magnitud_corte));
    wc = frecuencias(idx_corte);
    mag_wc = magnitudes(idx_corte);
    phase_wc = fases(idx_corte);
    
    fprintf('🔍 Punto en magnitud %.1f dB:\n', magnitud_corte);
    fprintf('   ω = %.2f rad/s, |G| = %.4f dB, ∠G = %.4f°\n', wc, mag_wc, phase_wc);
    
    % Configurar DataTipTemplate en las LÍNEAS
    dtt_mag = h_mag.DataTipTemplate;
    dtt_mag.Interpreter = 'latex';
    dtt_phase = h_phase.DataTipTemplate;
    dtt_phase.Interpreter = 'latex';

    h_mag.DataTipTemplate.DataTipRows(1).Label = '$\omega = $';
    h_mag.DataTipTemplate.DataTipRows(2).Label = '$|G(j\omega)| = $';

    h_phase.DataTipTemplate.DataTipRows(1).Label = '$\omega = $';
    h_phase.DataTipTemplate.DataTipRows(2).Label = '$\angle G = $';
    
    % Crear DataTips usando coordenadas (x, y)
    subplot(2,1,1);
    datatip(h_mag, wc, mag_wc);
    
    subplot(2,1,2);
    datatip(h_phase, wc, phase_wc);
    
    %% GUARDAR DIAGRAMA DE BODE
    savefig(fig_bode, fullfile(dir_bode, 'diagrama_bode.fig'));
    saveas(fig_bode, fullfile(dir_bode, 'diagrama_bode.png'), 'png');
    
    fprintf('📈 Diagrama de Bode guardado en: %s/\n', dir_bode);
end