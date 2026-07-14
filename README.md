# Sistema Experto para Diagnóstico Básico de Fallas en Redes

Repositorio documental del proyecto académico desarrollado para la asignatura **Inteligencia Artificial**. El proyecto propone un sistema híbrido para diagnosticar fallas básicas de red mediante reglas lógicas, Prolog, una ontología, un grafo de conocimiento y modelos de Machine Learning.

## Integrantes

- Juan Sebastián García Redondo
- David Alexander Acosta Pineda
- Ashlee Valentina Tapia Medina

## Descripción del proyecto

El sistema busca reducir el tiempo necesario para identificar problemas comunes de conectividad. A partir de síntomas como el tipo de conexión, el estado del LED del router, la dirección IP asignada, los resultados de pruebas `ping`, la resolución DNS y el acceso web, el sistema puede proponer un diagnóstico y una acción correctiva.

La solución documentada combina:

- Una base de conocimiento y reglas IF-THEN.
- Lógica de predicados implementada en Prolog.
- Una ontología OWL y un grafo de conocimiento.
- Un dataset sintético de 600 casos.
- Árbol de Decisión y Random Forest.
- Agrupamiento no supervisado con K-Means.
- Una red neuronal artificial MLP.
- Una propuesta de interfaz conversacional con LLM y Prompt Engineering.
- Consideraciones éticas, de privacidad y supervisión humana.

## Contenido del repositorio

### `InformeFinal.docx`

Documento editable que integra y organiza el contenido del informe técnico y los manuales según la estructura obligatoria del proyecto ABP.

Contiene:

- Portada, resumen y tabla de contenido automática.
- Introducción, problema, justificación y objetivos.
- Descripción de la solución y arquitectura general.
- Representación del conocimiento.
- Reglas IF-THEN y casos de uso.
- Lógica de predicados y ejemplos en Prolog.
- Sistema experto, ontología y grafo de conocimiento.
- Dataset y modelos de Machine Learning.
- Modelo supervisado, K-Means y red neuronal MLP.
- IA generativa, modelo LLM y diez prompts.
- Consideraciones éticas e integración completa.
- Conclusiones, trabajo futuro y referencias IEEE.
- Anexos con un resumen del manual técnico y campos pendientes.

Este es el archivo principal para revisión y modificación antes de la entrega final. Los textos resaltados como pendientes deben completarse con capturas, enlaces, conclusiones personales u otras evidencias.

### `Informe_Tecnico_Sistema_Experto_Redes.pdf`

Informe técnico fuente del proyecto. Explica el problema, los objetivos, el marco conceptual, la metodología ABP y el desarrollo realizado por sesiones.

Incluye:

- Fundamentos de Inteligencia Artificial y sistemas expertos.
- Reglas, lógica de predicados y base de conocimiento.
- Ontología y grafo de conocimiento.
- Construcción del dataset.
- Entrenamiento y evaluación de los modelos.
- Arquitectura híbrida con Prolog, Machine Learning y LLM.
- Resultados, discusión, trabajo futuro, referencias y anexos.

También contiene las figuras y métricas empleadas en `InformeFinal.docx`.

### `Manual_Tecnico_Sistema_Experto_Redes.pdf`

Manual dirigido a desarrolladores, ingenieros de conocimiento y personal técnico responsable de instalar, mantener o ampliar la solución.

Describe:

- Arquitectura general y estructura de archivos.
- Requisitos de instalación.
- Puesta en marcha de SWI-Prolog, Protégé y Google Colab.
- Componentes técnicos y dependencias.
- Procedimiento para agregar reglas, clases o relaciones.
- Reentrenamiento de modelos.
- Mantenimiento, monitoreo y solución de problemas.

### `Manual_Usuario_Sistema_Experto_Redes.pdf`

Guía simplificada para usuarios finales y técnicos de primer nivel.

Explica:

- Qué hace y qué no hace el sistema.
- Qué información se debe observar antes de consultar.
- Cómo reportar síntomas y ejecutar una consulta.
- Cómo interpretar diagnósticos y acciones sugeridas.
- Preguntas frecuentes y solución de problemas de uso.
- Glosario básico de términos de redes.

### `README.md`

Este archivo. Resume el propósito del proyecto, describe cada documento y orienta la navegación del repositorio.

### `Investigacion_Prompt_Engineering.docx`

Entregable académico editable sobre técnicas de Prompt Engineering aplicadas al sistema experto. Incluye la investigación de Zero-Shot, One-Shot, Few-Shot y Chain of Thought; veinte prompts especializados; criterios de optimización; casos de prueba; métricas y un protocolo para comparar diferentes modelos de IA sin inventar resultados no ejecutados.

### `Investigacion_Prompt_Engineering.md`

Versión en Markdown del entregable anterior, preparada para consultarse directamente desde GitHub. Contiene los veinte prompts completos y sirve como fuente fácil de versionar y actualizar.

## Resultados principales

| Modelo | Tipo | Accuracy | F1-Score macro |
|---|---|---:|---:|
| Árbol de Decisión | Supervisado | 0.800 | 0.657 |
| Random Forest | Supervisado | 0.917 | 0.859 |
| K-Means | No supervisado | No aplica | ARI = 0.184 |
| Red neuronal MLP | Supervisado | 0.725 | 0.499 |

Random Forest obtuvo el mejor rendimiento sobre el dataset tabular y fue seleccionado como componente probabilístico recomendado para complementar el sistema basado en reglas.

## Cómo revisar la documentación

1. Abrir `InformeFinal.docx` para revisar y modificar el documento de entrega.
2. Consultar `Informe_Tecnico_Sistema_Experto_Redes.pdf` para ampliar fundamentos, metodología y resultados.
3. Consultar `Manual_Tecnico_Sistema_Experto_Redes.pdf` para instalación, mantenimiento y extensión.
4. Consultar `Manual_Usuario_Sistema_Experto_Redes.pdf` para comprender el uso desde la perspectiva del usuario final.
5. Consultar `Investigacion_Prompt_Engineering.docx` o su versión `.md` para revisar las técnicas y los veinte prompts especializados.
6. En Word, actualizar la tabla de contenido de `InformeFinal.docx` con clic derecho y **Actualizar campo**.

## Elementos pendientes para un repositorio completo de implementación

Actualmente esta carpeta contiene la documentación del proyecto. Si los siguientes artefactos están disponibles, conviene añadirlos posteriormente:

- `diagnostico_red.pl`: base de conocimiento Prolog.
- `ontologia_diagnostico_red.owl`: ontología compatible con Protégé.
- `dataset_diagnostico_red.csv`: dataset de 600 casos.
- `modelo_supervisado_diagnostico_red.ipynb`: Árbol de Decisión y Random Forest.
- `modelo_no_supervisado_red_neuronal.ipynb`: K-Means y MLP.
- Capturas de ejecución de Prolog, Protégé y Google Colab.
- Enlace o archivos del video demostrativo.

## Estado

Versión documental académica en revisión. Antes de la entrega se deben comprobar los campos pendientes del informe final, actualizar su tabla de contenido y agregar las evidencias solicitadas por la rúbrica.
