#!/usr/bin/env python3
"""
🌾 EJECUTOR MEJORADO - ANÁLISIS CULTIVO ARROZ
Versión corregida para mostrar gráficos Plotly correctamente

Analista: Samir Caizapasto 
Fecha: Octubre 2024
Fix: Visualizaciones Plotly en HTML
"""

import subprocess
import sys
import os
import shutil
import re
import json
from pathlib import Path

def instalar_dependencias():
    """Instala las dependencias necesarias incluyendo kaleido para Plotly"""
    dependencias = [
        'pandas>=1.5.0',
        'numpy>=1.24.0', 
        'matplotlib>=3.6.0',
        'seaborn>=0.12.0',
        'plotly>=5.17.0',
        'jupyter>=1.0.0',
        'nbconvert>=7.0.0',
        'kaleido>=0.2.1',  # Crítico para exportar Plotly
        'nbformat>=5.0.0'
    ]
    
    print("📦 Instalando dependencias para visualizaciones...")
    for dep in dependencias:
        try:
            subprocess.check_call([sys.executable, '-m', 'pip', 'install', dep])
            print(f"✅ {dep.split('>=')[0]} instalado")
        except subprocess.CalledProcessError as e:
            print(f"⚠️ Error con {dep}: {e}")

def crear_template_plotly():
    """Crea un template personalizado para nbconvert que funciona con Plotly"""
    template_dir = Path("nbconvert_templates")
    template_dir.mkdir(exist_ok=True)
    
    template_content = '''
{%- extends 'classic/index.html.j2' -%}

{%- block header -%}
{{ super() }}

<!-- Plotly.js from CDN -->
<script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/require.js/2.3.6/require.min.js"></script>

<!-- Plotly configuration -->
<script>
    window.PlotlyConfig = {MathJaxConfig: 'local'};
    if (typeof define === "function" && define.amd) {
        define('plotly', function() { return Plotly; });
    }
</script>

<!-- Custom CSS para mejor presentación -->
<style>
    .jp-OutputArea-output {
        overflow-x: auto;
    }
    
    .plotly-graph-div {
        margin: 20px 0;
        border: 1px solid #ddd;
        border-radius: 8px;
        box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }
    
    /* Ocultar celdas de código de configuración */
    .jp-Cell[data-cell-type="code"]:has(.jp-OutputArea:empty) {
        display: none;
    }
    
    /* Ocultar imports y configuraciones */
    .highlight:has(.kn:contains("import")) {
        display: none;
    }
    
    .cell:has(.output_area:empty) {
        display: none;
    }
    
    /* Mejorar visualización de outputs */
    .output_result {
        max-width: 100%;
        overflow-x: auto;
    }
    
    /* Estilo profesional */
    body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        line-height: 1.6;
        color: #333;
        background-color: #f9f9f9;
    }
    
    .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px;
        background: white;
        border-radius: 10px;
        box-shadow: 0 0 20px rgba(0,0,0,0.1);
    }
    
    h1, h2, h3, h4, h5, h6 {
        color: #2E7D32;
        border-bottom: 2px solid #66BB6A;
        padding-bottom: 10px;
    }
</style>

{%- endblock header -%}

{%- block body_loop -%}
{%- for cell in nb.cells -%}
    {%- if cell.cell_type == 'markdown' -%}
        {{ self.markdown_cell(cell) }}
    {%- elif cell.cell_type == 'code' -%}
        {%- if not (
            'import' in cell.source or 
            'from ' in cell.source or
            'plt.style.use' in cell.source or
            'warnings.filterwarnings' in cell.source or
            'COLOR_PALETTE' in cell.source
        ) -%}
            {{ self.code_cell(cell) }}
        {%- endif -%}
    {%- endif -%}
{%- endfor -%}
{%- endblock body_loop -%}
'''
    
    template_path = template_dir / "plotly_template.html.j2"
    with open(template_path, 'w', encoding='utf-8') as f:
        f.write(template_content)
    
    return str(template_path)

def arreglar_notebook_para_plotly(notebook_path):
    """Modifica el notebook para asegurar que Plotly funcione en HTML"""
    print("🔧 Preparando notebook para exportación Plotly...")
    
    try:
        import nbformat
        
        # Leer notebook
        with open(notebook_path, 'r', encoding='utf-8') as f:
            nb = nbformat.read(f, as_version=4)
        
        # Agregar celda de configuración Plotly al inicio
        plotly_config_cell = nbformat.v4.new_code_cell("""
# Configuración especial para exportación HTML
import plotly.io as pio
import plotly.offline as pyo

# Configurar Plotly para funcionar sin conexión
pio.renderers.default = "notebook"
pyo.init_notebook_mode(connected=True)

# Configurar para mostrar en HTML
import plotly.graph_objects as go
from plotly.subplots import make_subplots
go.Figure().show = lambda self: self.show(renderer="notebook")
""")
        
        # Insertar al inicio (después de imports básicos)
        if nb.cells and 'import' in nb.cells[0].source:
            nb.cells.insert(1, plotly_config_cell)
        else:
            nb.cells.insert(0, plotly_config_cell)
        
        # Marcar celdas de configuración para ocultarlas
        for cell in nb.cells:
            if cell.cell_type == 'code':
                source_lower = cell.source.lower()
                if any(keyword in source_lower for keyword in [
                    'import ', 'from ', 'plt.style.use', 'warnings.filterwarnings',
                    'color_palette =', 'rcparams'
                ]):
                    # Agregar tag para ocultar
                    if 'tags' not in cell.metadata:
                        cell.metadata['tags'] = []
                    cell.metadata['tags'].append('hide-input')
                    cell.metadata['tags'].append('hide-output')
        
        # Guardar notebook modificado
        backup_path = notebook_path.replace('.ipynb', '_backup.ipynb')
        shutil.copy2(notebook_path, backup_path)
        
        with open(notebook_path, 'w', encoding='utf-8') as f:
            nbformat.write(nb, f)
        
        print(f"✅ Notebook preparado (backup: {backup_path})")
        return True
        
    except Exception as e:
        print(f"⚠️ Error preparando notebook: {e}")
        return False

def encontrar_nbconvert():
    """Encuentra nbconvert con mejor detección"""
    print("🔍 Buscando nbconvert...")
    
    opciones = [
        [sys.executable, '-m', 'nbconvert'],
        ['jupyter', 'nbconvert'],
        ['python', '-m', 'nbconvert'],
        ['python3', '-m', 'nbconvert']
    ]
    
    for cmd in opciones:
        try:
            result = subprocess.run(
                cmd + ['--version'], 
                capture_output=True, 
                text=True, 
                timeout=10
            )
            if result.returncode == 0:
                print(f"✅ Encontrado: {' '.join(cmd)}")
                return cmd
        except:
            continue
    
    return None

def ejecutar_conversion_mejorada():
    """Ejecuta la conversión con configuración optimizada para Plotly"""
    
    notebook_file = 'analisis_cultivos_arroz_profesional.ipynb'
    output_html = 'analisis_cultivos_arroz_profesional.html'
    
    if not os.path.exists(notebook_file):
        print(f"❌ No se encontró {notebook_file}")
        return False
    
    # Preparar notebook
    notebook_preparado = arreglar_notebook_para_plotly(notebook_file)
    if not notebook_preparado:
        print("⚠️ Continuando sin preparación del notebook...")
    
    # Encontrar nbconvert
    nbconvert_cmd = encontrar_nbconvert()
    if not nbconvert_cmd:
        print("❌ No se pudo encontrar nbconvert")
        return False
    
    # Crear template personalizado
    template_path = crear_template_plotly()
    
    try:
        print("🚀 Generando HTML con soporte Plotly completo...")
        
        # Comando optimizado para Plotly
        cmd_completo = nbconvert_cmd + [
            '--to', 'html',
            '--output', output_html,
            '--execute',  # Ejecutar celdas
            '--allow-errors',  # Continuar con errores
            '--ExecutePreprocessor.timeout=300',  # 5 minutos timeout
            '--no-input',  # Solo mostrar outputs
            '--template', 'classic',  # Template que funciona con Plotly
            notebook_file
        ]
        
        print(f"🔧 Ejecutando: {' '.join(cmd_completo)}")
        
        result = subprocess.run(
            cmd_completo,
            capture_output=True,
            text=True,
            timeout=300
        )
        
        if result.returncode == 0:
            print("✅ HTML generado exitosamente")
            
            if os.path.exists(output_html):
                # Post-procesar HTML para mejorar Plotly
                procesar_html_final(output_html)
                
                size = os.path.getsize(output_html)
                print(f"📄 Archivo: {output_html} ({size:,} bytes)")
                return True
            else:
                print("❌ Archivo HTML no se generó")
                return False
        else:
            print(f"❌ Error en nbconvert:")
            print(f"STDERR: {result.stderr}")
            print(f"STDOUT: {result.stdout}")
            return False
            
    except subprocess.TimeoutExpired:
        print("⏰ Timeout en nbconvert (5 minutos)")
        return False
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def procesar_html_final(html_path):
    """Post-procesa el HTML para optimizar Plotly"""
    print("🎨 Optimizando HTML final...")
    
    try:
        with open(html_path, 'r', encoding='utf-8') as f:
            html_content = f.read()
        
        # Agregar configuración mejorada de Plotly
        plotly_enhancement = '''
<script>
    // Configuración mejorada para Plotly
    document.addEventListener('DOMContentLoaded', function() {
        // Asegurar que todos los gráficos Plotly se muestren
        var plotlyDivs = document.querySelectorAll('.js-plotly-plot, [id*="plotly-div"], .plotly-graph-div');
        
        plotlyDivs.forEach(function(div) {
            if (div.data && div.layout) {
                // Redimensionar gráficos
                Plotly.Plots.resize(div);
            }
        });
        
        // Configurar responsive
        window.addEventListener('resize', function() {
            plotlyDivs.forEach(function(div) {
                if (div.data && div.layout) {
                    Plotly.Plots.resize(div);
                }
            });
        });
    });
</script>

<style>
    /* Mejorar visualización de gráficos */
    .js-plotly-plot, .plotly-graph-div {
        width: 100% !important;
        height: auto !important;
        min-height: 400px;
        margin: 20px 0;
        border: 1px solid #e0e0e0;
        border-radius: 8px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    
    /* Ocultar celdas de imports */
    .highlight:has(.kn, .nn) { display: none !important; }
    .input_area:has(.highlight .kn) { display: none !important; }
    
    /* Estilo profesional */
    body { 
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background: #f5f5f5;
        margin: 0;
        padding: 20px;
    }
    
    .container {
        max-width: 1200px;
        margin: 0 auto;
        background: white;
        padding: 30px;
        border-radius: 10px;
        box-shadow: 0 0 20px rgba(0,0,0,0.1);
    }
</style>
'''
        
        # Insertar antes de </head>
        if '</head>' in html_content:
            html_content = html_content.replace('</head>', plotly_enhancement + '\n</head>')
        
        # Escribir HTML mejorado
        with open(html_path, 'w', encoding='utf-8') as f:
            f.write(html_content)
        
        print("✅ HTML optimizado para Plotly")
        
    except Exception as e:
        print(f"⚠️ Error optimizando HTML: {e}")

def main():
    """Función principal mejorada"""
    print("🌾 SISTEMA CULTIVO ARROZ - GENERADOR HTML MEJORADO")
    print("="*60)
    print("🎯 Objetivo: HTML con gráficos Plotly funcionando")
    print()
    
    # Verificar archivos
    notebook_file = 'analisis_cultivos_arroz_profesional.ipynb'
    if not os.path.exists(notebook_file):
        print(f"❌ Notebook no encontrado: {notebook_file}")
        return
    
    # Instalar dependencias
    print("📦 PASO 1: Instalando dependencias...")
    instalar_dependencias()
    print()
    
    # Ejecutar conversión
    print("🔄 PASO 2: Generando HTML con Plotly...")
    exito = ejecutar_conversion_mejorada()
    print()
    
    # Resultado final
    print("🎯 RESULTADO FINAL:")
    print("="*40)
    
    if exito:
        html_file = 'analisis_cultivos_arroz_profesional.html'
        size = os.path.getsize(html_file)
        print(f"✅ HTML generado exitosamente")
        print(f"📄 Archivo: {html_file}")
        print(f"📊 Tamaño: {size:,} bytes")
        print()
        print("🎉 CARACTERÍSTICAS DEL HTML:")
        print("   ✅ Gráficos Plotly interactivos")
        print("   ✅ Celdas de código ocultas")
        print("   ✅ Diseño profesional")
        print("   ✅ Responsive design")
        print()
        print("🌐 PARA VER EL REPORTE:")
        print(f"   - Abrir: {html_file}")
        print("   - O arrastrar al navegador")
        print("   - Verificar que los gráficos se muestran")
    else:
        print("❌ No se pudo generar el HTML")
        print()
        print("🛠️ SOLUCIONES ALTERNATIVAS:")
        print("1. Usar VS Code para exportar manualmente")
        print("2. Abrir Jupyter Notebook y usar File > Download as > HTML")
        print("3. Verificar que todas las dependencias estén instaladas")
        print("4. Revisar que el notebook funcione correctamente")
    
    print()
    print("🔧 NOTAS TÉCNICAS:")
    print("   - Plotly requiere kaleido para exportar")
    print("   - Los gráficos usan CDN para JavaScript")
    print("   - Se necesita conexión a internet para visualizar")

if __name__ == "__main__":
    main()