# Informe ético y auditoría de IA responsable

## Sistema Experto para Diagnóstico Básico de Fallas en Redes

**Integrantes:** Juan Sebastián García Redondo, David Alexander Acosta Pineda y Ashlee Valentina Tapia Medina  
**Asignatura:** Sistemas Expertos e Inteligencia Artificial  
**Fecha:** julio de 2026

## Resumen ejecutivo

Este informe evalúa éticamente el Sistema Experto para Diagnóstico Básico de Fallas en Redes. La solución combina reglas IF-THEN en Prolog, una ontología y un grafo de conocimiento, un dataset sintético de 600 casos, modelos de Machine Learning y una interfaz conversacional con un modelo de lenguaje. Aunque el prototipo tiene fines académicos y usa datos sintéticos, una implementación real podría procesar información personal, registros técnicos y detalles sensibles de infraestructura.

La auditoría identificó como riesgos principales: diagnósticos incorrectos, automatización excesiva, sesgos del dataset sintético, bajo desempeño en clases minoritarias, divulgación de topología de red, recolección innecesaria de datos, transferencia de información a proveedores de LLM, alucinaciones, prompt injection, recomendaciones técnicas inseguras y falta de responsables definidos. El riesgo inherente global se clasifica como **alto** para un despliegue real sin controles y como **medio** para el prototipo académico actual.

El sistema no debe desplegarse en producción hasta implementar validación humana, minimización y anonimización de datos, control de acceso, registro de decisiones, pruebas por subgrupos, umbrales de confianza, respuesta segura ante incertidumbre, política de retención, gestión de incidentes y revisión periódica. K-Means y la red neuronal MLP no deben tomar decisiones operativas debido a sus resultados actuales; Random Forest solo debe complementar, no reemplazar, las reglas y la evaluación humana.

## 1. Objetivo y alcance de la auditoría

El objetivo es determinar si el proyecto se diseña y puede utilizarse de manera responsable, respetando privacidad, seguridad, equidad, transparencia, explicabilidad y supervisión humana.

La auditoría incluye:

- Base de conocimiento y reglas Prolog.
- Ontología OWL y grafo de conocimiento.
- Dataset sintético y proceso futuro de recolección de tickets reales.
- Árbol de Decisión, Random Forest, K-Means y red neuronal MLP.
- Interfaz conversacional propuesta con LLM y Prompt Engineering.
- Documentación, repositorio, operación, mantenimiento y escalamiento.

No se realizó una auditoría de código fuente ni una prueba de penetración porque esos artefactos no están incluidos actualmente en la carpeta documental. Las conclusiones se basan en la arquitectura, resultados y procedimientos documentados.

## 2. Investigación conceptual

### 2.1 Inteligencia Artificial responsable

La IA responsable es el diseño, desarrollo, despliegue y supervisión de sistemas de IA para que sus beneficios se obtengan sin vulnerar derechos ni producir riesgos inaceptables. No es una característica aislada del modelo: comprende datos, personas, procesos, tecnología y gobernanza durante todo el ciclo de vida.

El NIST AI Risk Management Framework propone cuatro funciones: **Govern**, para establecer políticas y responsabilidades; **Map**, para comprender contexto e impactos; **Measure**, para evaluar riesgos y desempeño; y **Manage**, para priorizar y tratar riesgos [1]. UNESCO centra su recomendación en derechos humanos, dignidad, proporcionalidad, seguridad, privacidad, equidad, transparencia, responsabilidad y supervisión humana [2]. Los principios de la OCDE añaden robustez, rendición de cuentas y crecimiento inclusivo [3].

Aplicados al proyecto, estos marcos exigen que el diagnóstico sea un apoyo y no una decisión autónoma irreversible, que exista una persona responsable y que el sistema pueda declarar incertidumbre y escalar.

### 2.2 Privacidad y protección de datos

La privacidad consiste en permitir que las personas conozcan y controlen el uso de sus datos. La protección de datos exige finalidad legítima, minimización, calidad, seguridad, acceso restringido, retención limitada y mecanismos para conocer, corregir o suprimir la información.

En Colombia, la Ley 1581 de 2012 define dato personal como información vinculada o asociable a una persona natural y establece principios de legalidad, finalidad, libertad, calidad, transparencia, acceso restringido, seguridad y confidencialidad [4]. Una dirección IP, nombre de usuario, correo, ubicación o identificador de dispositivo puede convertirse en dato personal si permite identificar directa o indirectamente a una persona.

La información de infraestructura también requiere protección aunque no siempre sea un dato personal. Topologías, hostnames, direcciones internas, reglas de firewall y configuraciones pueden facilitar ataques si se publican o transfieren sin control.

### 2.3 Sesgos y equidad

Un sesgo es una desviación sistemática que perjudica la calidad o distribuye errores de manera desigual. Puede originarse en:

- **Selección:** los datos no representan todas las redes o usuarios.
- **Medición:** los síntomas se registran de forma diferente según la experiencia del usuario.
- **Etiquetado:** la categoría asignada por técnicos puede ser incorrecta o inconsistente.
- **Clase:** algunas fallas tienen muchos más ejemplos que otras.
- **Automatización:** las personas aceptan la recomendación del sistema sin verificarla.
- **Despliegue:** el sistema se usa en organizaciones distintas a aquellas para las que fue diseñado.

En este proyecto, el dataset sintético reproduce las reglas que lo generaron. Por ello puede sobreestimar el rendimiento: el modelo aprende la lógica del generador y no necesariamente la complejidad de incidentes reales. El 5 % de ruido simulado no representa todas las ambigüedades, errores humanos y cambios de infraestructura.

### 2.4 Transparencia

La transparencia permite conocer que se utiliza IA, cuál es su finalidad, qué información procesa, quién es responsable, cuáles son sus limitaciones y cómo reclamar o solicitar revisión. No obliga a publicar datos personales, credenciales ni detalles que comprometan la seguridad.

El usuario debe recibir un aviso claro: interactúa con un sistema automatizado, el resultado es orientativo, puede equivocarse y siempre puede solicitar atención humana. La organización debe mantener documentación de versiones, datos, reglas, modelos, métricas, cambios e incidentes.

### 2.5 Explicabilidad

La explicabilidad permite comprender por qué se produjo una salida. Debe adaptarse al destinatario:

- **Usuario final:** diagnóstico probable, síntomas considerados, acción segura y forma de escalar.
- **Técnico:** hechos, regla aplicada o modelo utilizado, confianza, alternativas y datos faltantes.
- **Auditor:** versión de reglas/modelo, origen de datos, métricas, logs y responsable.

Las reglas Prolog son más explicables porque sus antecedentes pueden mostrarse. Random Forest requiere explicaciones adicionales, como importancia local de variables, y nunca debe justificarse únicamente con una puntuación global. El LLM no debe inventar una explicación: debe redactar solo a partir de hechos y resultados validados.

## 3. Descripción ética del sistema

### 3.1 Propósito legítimo

El propósito es apoyar el diagnóstico inicial de fallas básicas, reducir tiempos de atención y orientar acciones seguras. El sistema no debe utilizarse para vigilar empleados, evaluar su productividad, atribuir culpa por incidentes ni ejecutar cambios automáticos en infraestructura crítica.

### 3.2 Partes interesadas

| Parte interesada | Interés o posible impacto |
|---|---|
| Usuarios finales | Recibir orientación clara, segura y no discriminatoria |
| Técnicos de soporte | Contar con evidencia y evitar sobrecarga o automatización acrítica |
| Administradores de red | Proteger infraestructura, credenciales y continuidad del servicio |
| Organización responsable | Cumplir privacidad, seguridad, auditoría y atención de reclamos |
| Titulares de datos | Conocer, corregir o solicitar supresión de información personal |
| Proveedores de IA o nube | Procesar datos bajo condiciones contractuales y de seguridad |
| Equipo desarrollador | Mantener reglas, modelos, documentación y controles |

### 3.3 Flujo de información

1. El usuario describe síntomas.
2. La interfaz extrae variables técnicas.
3. Los datos se validan y se almacenan temporalmente.
4. Prolog intenta aplicar una regla.
5. Si no existe coincidencia suficiente, Random Forest puede sugerir una clase con confianza.
6. El módulo de fusión selecciona regla, ML o escalamiento.
7. El LLM redacta la explicación a partir del resultado validado.
8. El caso se registra, anonimiza o elimina según la política de retención.

Cada transferencia debe tener finalidad, responsable, base autorizada, registro y control de acceso.

## 4. Inventario y clasificación de datos

| Dato | Ejemplo | Clasificación | Necesidad | Tratamiento recomendado |
|---|---|---|---|---|
| Síntomas de red | LED, ping, acceso web | Técnico | Necesario | Conservar solo para diagnóstico y evaluación |
| Tipo de conexión | Ethernet o WiFi | Técnico | Necesario | Categoría controlada |
| Nombre de persona | Usuario que reporta | Personal | No necesario para el modelo | Reemplazar por identificador aleatorio |
| Correo/teléfono | Contacto del usuario | Personal | Solo para soporte | Separar del dataset de entrenamiento |
| Usuario corporativo | nombre.apellido | Personal | Evitable | Tokenizar o seudonimizar |
| Hostname del equipo | pc_finanzas | Personal/técnico | Parcial | Usar ID interno no descriptivo |
| Dirección IP o MAC | 10.x.x.x / MAC | Personal/técnico sensible | Puede ser necesaria | Enmascarar en reportes y restringir acceso |
| Ubicación/área | Finanzas, sede | Personal/organizacional | Parcial | Generalizar y limitar granularidad |
| Topología y configuración | Routers, switches, ACL | Infraestructura sensible | Necesaria para técnicos | Cifrar, segmentar y no enviar a LLM externo |
| Credenciales | Contraseñas, tokens | Secreto crítico | Nunca necesaria | Bloquear captura y eliminar de inmediato |
| Contenido del ticket | Relato libre | Puede mezclar categorías | Necesario de forma temporal | Detección y redacción automática de PII |
| Logs y auditoría | Consultas, resultados | Personal/técnico | Necesario para trazabilidad | Minimizar, proteger y definir retención |
| Diagnóstico y confianza | fallo_dns, 0.91 | Derivado | Necesario | Conservar con versión y fuente |
| Feedback del técnico | Confirmado/corregido | Técnico | Útil para mejora | Control de calidad antes de reentrenar |

### 4.1 Datos que no deben recolectarse

- Contraseñas WiFi, credenciales administrativas, tokens o claves API.
- Contenido personal no relacionado con el incidente.
- Datos sensibles definidos por la Ley 1581, salvo necesidad excepcional y autorización aplicable.
- Información de menores de edad.
- Capturas completas de pantalla sin revisión y redacción.
- Topología completa cuando basta con datos del equipo afectado.

## 5. Auditoría ética por componente

| Componente | Hallazgo | Riesgo ético | Recomendación |
|---|---|---|---|
| Reglas Prolog | Reglas claras pero cobertura limitada | Falsa certeza y omisión de casos | Mostrar antecedentes, versión y salida “sin evidencia” |
| Base de hechos | Puede contener hostnames y áreas | Identificación indirecta | Seudonimizar y separar identidad de síntomas |
| Ontología | Formaliza relaciones de infraestructura | Exposición de topología | Control de acceso y versión pública reducida |
| Grafo | Revela puntos críticos y dependencias | Facilita reconocimiento a atacantes | No publicar el grafo productivo |
| Dataset | 600 casos sintéticos y 5 % de ruido | Sesgo de simulación y clases | Incorporar datos reales anonimizados y muestreo por clase |
| Árbol de Decisión | Accuracy 0.800, F1 0.657 | Errores previsibles | Uso experimental y reporte por clase |
| Random Forest | Mejor modelo: Accuracy 0.917, F1 0.859 | Opacidad y error residual | Umbral, explicación local y revisión humana |
| K-Means | ARI 0.184 y Silhouette 0.277 | Clústeres mal interpretados | Solo análisis exploratorio, nunca diagnóstico |
| MLP | Accuracy 0.725, F1 0.499 | Fallo en clases minoritarias | No usar para decisiones operativas |
| LLM | Interfaz conceptual | Alucinación, inyección y fuga de datos | JSON validado, mínimo privilegio y redacción de PII |
| Módulo de fusión | Política aún conceptual | Conflictos no resueltos | Prioridad de reglas completas, umbral y escalamiento |
| Explicación | Puede sonar convincente | Confianza indebida | Expresar incertidumbre, fuente y limitaciones |
| Repositorio público | Documentación accesible | Publicación accidental de secretos | Escaneo de secretos y revisión antes de cada push |
| Operación | No hay roles formalizados | Falta de rendición de cuentas | Asignar propietario, técnico revisor y responsable de datos |

## 6. Metodología de valoración del riesgo

Se usa una escala de probabilidad e impacto de 1 a 5.

| Valor | Probabilidad | Impacto |
|---:|---|---|
| 1 | Raro | Menor, sin interrupción relevante |
| 2 | Improbable | Limitado y reversible |
| 3 | Posible | Afecta usuarios o servicio de forma moderada |
| 4 | Probable | Daño operativo, privacidad o seguridad importante |
| 5 | Casi seguro | Daño grave, extendido o difícil de revertir |

El nivel se calcula como `Probabilidad x Impacto`:

- 1 a 4: bajo.
- 5 a 9: medio.
- 10 a 15: alto.
- 16 a 25: crítico.

## 7. Matriz de riesgos éticos

| ID | Riesgo | Causa | Afectados | P | I | Nivel inherente | Control propuesto | Nivel residual |
|---|---|---|---|---:|---:|---|---|---|
| R1 | Diagnóstico incorrecto | Reglas incompletas o error ML | Usuarios y operación | 4 | 4 | 16 Crítico | Umbral, revisión humana y salida sin evidencia | 8 Medio |
| R2 | Acción insegura | Recomendación de desactivar controles o reiniciar infraestructura | Organización | 3 | 5 | 15 Alto | Lista blanca de acciones y aprobación técnica | 5 Medio |
| R3 | Automatización excesiva | Usuario confía por lenguaje convincente | Usuarios/técnicos | 4 | 4 | 16 Crítico | Aviso de límites, confianza y escalamiento | 8 Medio |
| R4 | Sesgo del dataset sintético | Casos derivados de reglas y entorno simulado | Grupos con fallas no representadas | 5 | 4 | 20 Crítico | Datos reales anonimizados, validación externa | 10 Alto |
| R5 | Desempeño desigual por clase | Clases minoritarias y ruido | Usuarios con fallas raras | 4 | 4 | 16 Crítico | F1/recall por clase, balanceo y umbrales | 8 Medio |
| R6 | Datos personales innecesarios | Texto libre de tickets | Titulares | 4 | 4 | 16 Crítico | Minimización, PII redaction y consentimiento | 6 Medio |
| R7 | Fuga de infraestructura | IP, MAC, topología o reglas en logs/repositorio | Organización | 3 | 5 | 15 Alto | Cifrado, acceso restringido y escaneo de secretos | 5 Medio |
| R8 | Transferencia a proveedor LLM | Uso de API externa | Usuarios/organización | 3 | 5 | 15 Alto | Anonimizar, contrato, región y opción local | 6 Medio |
| R9 | Prompt injection | Texto del usuario altera instrucciones | Organización/usuarios | 4 | 4 | 16 Crítico | Separar datos e instrucciones, esquema y lista blanca | 8 Medio |
| R10 | Alucinación del LLM | Generación no anclada | Usuarios | 4 | 4 | 16 Crítico | Explicar solo resultado firmado por motor | 6 Medio |
| R11 | Explicación engañosa | Justificación generada después del resultado | Usuarios/auditores | 3 | 4 | 12 Alto | Mostrar hechos, regla/fuente y versión | 6 Medio |
| R12 | Falta de trazabilidad | No registrar versión o entradas | Auditores y soporte | 4 | 4 | 16 Crítico | Log inmutable mínimo y ID de decisión | 4 Bajo |
| R13 | Uso fuera de propósito | Vigilancia o evaluación de empleados | Trabajadores | 2 | 5 | 10 Alto | Política de uso prohibido y control de finalidad | 4 Bajo |
| R14 | Retención indefinida | No existe calendario de borrado | Titulares | 4 | 3 | 12 Alto | Periodos definidos y borrado verificable | 4 Bajo |
| R15 | Acceso no autorizado | Permisos débiles | Usuarios/organización | 3 | 5 | 15 Alto | RBAC, MFA, cifrado y revisión de accesos | 5 Medio |
| R16 | Falta de accesibilidad | Lenguaje técnico o interfaz no inclusiva | Usuarios con baja alfabetización o discapacidad | 3 | 3 | 9 Medio | Lenguaje claro, accesibilidad y canal humano | 3 Bajo |
| R17 | Deriva del modelo | Cambian redes, equipos y patrones | Usuarios | 3 | 4 | 12 Alto | Monitoreo, alertas y revalidación periódica | 6 Medio |
| R18 | Manipulación del feedback | Etiquetas incorrectas ingresan al entrenamiento | Usuarios/modelo | 3 | 4 | 12 Alto | Doble revisión y procedencia de etiquetas | 4 Bajo |
| R19 | Ausencia de responsable | No hay propietario del riesgo | Todas las partes | 4 | 4 | 16 Crítico | Matriz RACI y comité de revisión | 4 Bajo |
| R20 | Incidente sin respuesta | No existe procedimiento | Titulares/organización | 3 | 5 | 15 Alto | Plan de incidentes, contacto y simulacros | 5 Medio |

### 7.1 Riesgos prioritarios

Los riesgos R1, R3, R4, R5, R6, R9, R10, R12 y R19 requieren tratamiento antes de cualquier piloto real. El riesgo residual R4 permanece alto hasta disponer de evidencia con datos reales representativos y revisión independiente. Este riesgo no puede aceptarse únicamente con documentación.

## 8. Análisis de sesgos

### 8.1 Grupos y dimensiones a evaluar

El sistema no utiliza atributos protegidos para decidir, pero puede producir impactos desiguales mediante variables indirectas. Deben compararse resultados por:

- Tipo de conexión: Ethernet frente a WiFi.
- Tipo de dispositivo y sistema operativo.
- Sede, área o tipo de infraestructura, usando categorías no identificables.
- Nivel técnico del usuario y calidad del reporte.
- Fallas frecuentes frente a clases minoritarias.
- Casos completos frente a casos con datos faltantes.
- Idioma, variaciones regionales y uso de términos coloquiales en la interfaz LLM.

### 8.2 Métricas mínimas

- Recall y F1 por clase diagnóstica.
- Tasa de falsos positivos y negativos por subgrupo.
- Cobertura: porcentaje con diagnóstico frente a escalamiento.
- Diferencia máxima de error entre subgrupos.
- Tasa de datos inventados por el LLM.
- Tasa de preguntas innecesarias o repetidas.
- Porcentaje de correcciones realizadas por técnicos.

No debe publicarse una única métrica global como prueba de equidad. Accuracy de 0.917 no demuestra buen desempeño para todas las clases.

## 9. Transparencia y explicabilidad requeridas

### 9.1 Aviso al usuario

Antes de iniciar, la interfaz debe informar:

> Este asistente usa reglas y modelos de IA para orientar el diagnóstico. Puede equivocarse y no realiza cambios automáticos en la red. No escriba contraseñas, tokens ni datos personales innecesarios. Puede solicitar revisión humana en cualquier momento.

### 9.2 Contenido mínimo de cada respuesta

- Diagnóstico o declaración de evidencia insuficiente.
- Síntomas utilizados, sin exponer datos sensibles.
- Fuente de la decisión: regla, ML o revisión humana.
- Confianza cuando proceda.
- Acción permitida y reversible.
- Limitaciones y vía de escalamiento.
- Identificador de decisión para auditoría.

### 9.3 Registro técnico

El log debe incluir fecha, versión de reglas, versión del modelo, variables normalizadas, resultado, confianza, fuente seleccionada, acción sugerida, revisión humana y resultado final. No debe registrar texto libre completo si basta con variables seudonimizadas.

## 10. Plan de mitigación

| Acción | Riesgos | Prioridad | Responsable sugerido | Plazo | Evidencia de cierre | Indicador |
|---|---|---|---|---|---|---|
| Definir propietario del sistema y RACI | R19, R20 | Crítica | Líder del proyecto | 0-15 días | RACI aprobada | 100 % de roles asignados |
| Crear política de privacidad y consentimiento | R6, R8, R14 | Crítica | Responsable de datos | 0-30 días | Aviso y política publicados | 100 % de usuarios informados |
| Bloquear credenciales y redactar PII | R6, R7, R8 | Crítica | Desarrollo/seguridad | 0-30 días | Pruebas automatizadas | 0 secretos en logs |
| Implementar salida “sin evidencia” | R1, R3 | Crítica | Ingeniería de conocimiento | 0-30 días | Casos de prueba | 100 % de casos incompletos escalados |
| Definir lista blanca de acciones | R2 | Crítica | Administrador de red | 0-30 días | Catálogo aprobado | 0 acciones no autorizadas |
| Validar JSON y aislar instrucciones LLM | R9, R10 | Crítica | Desarrollo | 0-30 días | Pruebas adversariales | 100 % de salidas validadas |
| Implementar logs mínimos con versión | R11, R12 | Alta | Desarrollo/operaciones | 31-60 días | Muestra de auditoría | 100 % de decisiones trazables |
| Configurar RBAC, MFA y cifrado | R7, R15 | Alta | Seguridad TI | 31-60 días | Revisión de configuración | 0 accesos huérfanos |
| Evaluar métricas por clase y subgrupo | R4, R5 | Alta | Ciencia de datos | 31-60 días | Informe de equidad | Brecha de error bajo umbral acordado |
| Construir conjunto de validación real anonimizado | R4, R17 | Alta | Datos/soporte | 31-90 días | Dataset con ficha técnica | Cobertura de clases objetivo |
| Implementar explicación por hechos y fuente | R3, R10, R11 | Alta | Desarrollo/UX | 31-60 días | Plantilla de respuesta | 100 % de salidas con fuente |
| Establecer retención y borrado | R6, R14 | Alta | Responsable de datos | 31-60 días | Calendario y prueba de borrado | 0 registros vencidos |
| Crear procedimiento de incidentes y reclamos | R20 | Alta | Seguridad/privacidad | 31-60 días | Playbook y simulacro | Tiempo de respuesta medido |
| Monitorear deriva y correcciones | R17, R18 | Media | MLOps/soporte | Continuo | Dashboard mensual | Alertas dentro de umbral |
| Capacitar a usuarios y técnicos | R3, R13, R16 | Media | Líder de soporte | Antes del piloto | Registro de capacitación | 90 % de personal capacitado |
| Repetir auditoría ética | Todos | Alta | Comité de revisión | Trimestral y antes de cambios | Informe versionado | Riesgos vencidos = 0 |

### 10.1 Fases de implementación

#### Fase 1. Contención antes del piloto

- Prohibir datos reales hasta aprobar privacidad y seguridad.
- Añadir aviso al usuario y canal humano.
- Implementar “desconocido” y “sin evidencia suficiente”.
- Eliminar recomendaciones que desactiven firewall o controles sin aprobación.
- Proteger el repositorio y ejecutar escaneo de secretos.

#### Fase 2. Piloto controlado

- Usar un grupo pequeño con consentimiento y técnicos supervisores.
- Registrar decisiones, correcciones e incidentes.
- Comparar resultados por clase y subgrupo.
- Mantener el sistema en modo recomendación, sin acciones automáticas.
- Detener el piloto si aparece daño, fuga, comportamiento desigual grave o deriva.

#### Fase 3. Operación limitada

- Aprobar umbrales de confianza y riesgo residual.
- Formalizar responsables, proveedores y acuerdos de tratamiento.
- Implementar monitoreo, retención y gestión de incidentes.
- Revisar trimestralmente reglas, datos, modelos y explicaciones.

## 11. Gobernanza y responsabilidades

| Rol | Responsabilidad |
|---|---|
| Propietario del sistema | Aceptar o rechazar riesgo residual y autorizar despliegue |
| Ingeniero de conocimiento | Mantener reglas, antecedentes, prioridades y explicaciones |
| Responsable de datos | Finalidad, autorización, calidad, retención y derechos del titular |
| Científico de datos | Métricas, sesgos, deriva, documentación y reentrenamiento |
| Seguridad TI | Accesos, cifrado, secretos, vulnerabilidades e incidentes |
| Técnico revisor | Confirmar casos, corregir etiquetas y escalar |
| Comité ético o académico | Revisar impactos, quejas, cambios mayores y auditorías |
| Usuario | Reportar síntomas sin compartir secretos y solicitar revisión si es necesario |

Ningún proveedor de IA ni modelo debe ser considerado responsable final. La responsabilidad permanece en la organización y las personas que deciden desarrollar, desplegar y usar el sistema.

## 12. Protocolo de incidentes éticos y de privacidad

1. Detectar y registrar el incidente sin copiar más datos de los necesarios.
2. Contener: suspender integración, revocar accesos o detener el modelo afectado.
3. Evaluar alcance, personas, infraestructura y decisiones comprometidas.
4. Notificar al responsable de seguridad y protección de datos.
5. Informar a titulares y autoridades cuando corresponda.
6. Corregir datos, reglas, modelos o permisos.
7. Verificar la eficacia del control y documentar aprendizaje.
8. Reabrir el servicio solo con autorización del propietario del sistema.

## 13. Criterios de aprobación antes de producción

El proyecto solo debería aprobarse para uso real si cumple todos los siguientes criterios:

- Existe responsable formal y canal de reclamación.
- No almacena contraseñas ni secretos.
- Los datos personales tienen finalidad, autorización, retención y seguridad definidas.
- El usuario conoce que interactúa con IA y puede escalar.
- Toda salida indica fuente y nivel de incertidumbre.
- Casos incompletos o contradictorios no reciben diagnóstico forzado.
- Acciones de alto impacto requieren aprobación humana.
- Se validó con datos reales anonimizados y representativos.
- Se reportan métricas por clase y subgrupo.
- Existe monitoreo de deriva, incidentes y correcciones.
- Proveedores externos tienen condiciones de privacidad evaluadas.
- Se realizó una nueva auditoría ética y de seguridad.

## 14. Resultado de la auditoría

| Área | Estado actual | Evaluación |
|---|---|---|
| Propósito y beneficio | Definido y legítimo | Favorable |
| Supervisión humana | Recomendada, no implementada técnicamente | Parcial |
| Privacidad | Dataset sintético, sin política operacional | Insuficiente para producción |
| Seguridad | Controles descritos, no verificados | Insuficiente para producción |
| Sesgos | Reconocidos, sin evaluación por subgrupo | Insuficiente |
| Transparencia | Documentación amplia | Parcialmente favorable |
| Explicabilidad | Reglas explicables; ML y LLM requieren controles | Parcial |
| Rendición de cuentas | Roles no formalizados | Insuficiente |
| Monitoreo | Propuesto, no implementado | Insuficiente |

**Dictamen:** el proyecto es aceptable como prototipo académico y base de experimentación, siempre que se identifique claramente como tal. **No está listo para producción** ni para procesar tickets reales sin ejecutar el plan de mitigación. La principal condición para avanzar es validar con datos reales anonimizados, bajo supervisión humana y con gobierno de datos formal.

## 15. Conclusiones

La IA responsable exige más que una buena métrica. El sistema debe ser seguro, trazable, comprensible, supervisado y proporcional al impacto de sus recomendaciones. La combinación de reglas y Machine Learning puede favorecer la explicabilidad, pero también crea riesgos de conflicto, automatización excesiva y falsa confianza.

El dataset sintético permite desarrollar el prototipo sin exponer personas, pero introduce un sesgo estructural: los modelos aprenden principalmente las reglas utilizadas para generar los datos. Por ello, las métricas actuales no justifican un despliegue real. K-Means y MLP deben mantenerse como experimentos; Random Forest debe actuar solo como respaldo con umbral y revisión humana.

La privacidad debe diseñarse desde el inicio. Los relatos libres y registros de red pueden contener datos personales, secretos y detalles de infraestructura. La minimización, seudonimización, cifrado, acceso restringido, retención limitada y control de proveedores son requisitos previos.

El plan de mitigación propone controles concretos, responsables, plazos e indicadores. Una vez implementados, el riesgo residual debe revisarse nuevamente. La aceptación final del riesgo corresponde a una persona u organización responsable, nunca al modelo.

## Referencias

[1] National Institute of Standards and Technology, “Artificial Intelligence Risk Management Framework (AI RMF 1.0),” NIST AI 100-1, Jan. 2023. doi: 10.6028/NIST.AI.100-1.

[2] UNESCO, *Recommendation on the Ethics of Artificial Intelligence*. Paris, France: UNESCO, 2021. [Online]. Available: https://www.unesco.org/en/artificial-intelligence/recommendation-ethics

[3] OECD, “OECD AI Principles,” updated May 2024. [Online]. Available: https://oecd.ai/en/ai-principles

[4] Congreso de la República de Colombia, “Ley Estatutaria 1581 de 2012, por la cual se dictan disposiciones generales para la protección de datos personales,” Diario Oficial 48.587, Oct. 18, 2012.

[5] National Institute of Standards and Technology, “Artificial Intelligence Risk Management Framework: Generative Artificial Intelligence Profile,” NIST AI 600-1, Jul. 2024. doi: 10.6028/NIST.AI.600-1.

> Nota: este documento es una evaluación académica y no sustituye asesoría jurídica, de ciberseguridad ni de protección de datos aplicable a una implementación real.
