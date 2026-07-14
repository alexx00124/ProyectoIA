# Investigación y desarrollo de Prompt Engineering

## Sistema Experto para Diagnóstico Básico de Fallas en Redes

**Integrantes:** Juan Sebastián García Redondo, David Alexander Acosta Pineda y Ashlee Valentina Tapia Medina  
**Asignatura:** Sistemas Expertos e Inteligencia Artificial  
**Fecha:** julio de 2026

## 1. Introducción

Un prompt es la instrucción y el contexto que recibe un modelo de lenguaje para realizar una tarea. Su diseño influye en la precisión, consistencia, formato y seguridad de la respuesta. En este proyecto, el modelo de lenguaje no reemplaza el sistema experto: actúa como interfaz para convertir la descripción del usuario en hechos estructurados y para explicar un diagnóstico previamente validado por reglas o por el modelo de Machine Learning.

La estrategia evita pedirle al LLM que invente diagnósticos. Primero se extraen ocho variables controladas; luego Prolog o Random Forest determinan la salida; finalmente el LLM redacta una explicación. Esta separación conserva la trazabilidad y reduce alucinaciones.

## 2. Investigación de técnicas

### 2.1 Zero-Shot Prompting

Zero-Shot consiste en solicitar una tarea sin incluir ejemplos resueltos. El modelo depende de la instrucción, de su conocimiento preentrenado y del contexto proporcionado. Es rápido, consume pocos tokens y resulta adecuado para tareas sencillas o formatos bien definidos. Su principal limitación es que puede interpretar de forma diferente etiquetas técnicas o formatos ambiguos.

**Aplicación al proyecto:** clasificar una descripción en variables conocidas, resumir un incidente o explicar un diagnóstico cuando la instrucción define claramente los valores permitidos.

**Ejemplo:** “Extrae el tipo de conexión del texto. Responde únicamente `ethernet`, `wifi` o `desconocido`”.

### 2.2 One-Shot Prompting

One-Shot proporciona una sola demostración de entrada y salida antes del caso nuevo. El ejemplo ayuda a enseñar el formato, el nivel de detalle y la forma de tratar datos desconocidos. Es útil cuando la tarea es estable y un ejemplo representativo basta para eliminar ambigüedad.

**Aplicación al proyecto:** enseñar la estructura JSON requerida o mostrar cómo traducir expresiones cotidianas a etiquetas como `acceso_web=nulo`.

**Riesgo:** si el único ejemplo es poco representativo, el modelo puede copiar patrones incorrectos o generalizar de manera deficiente.

### 2.3 Few-Shot Prompting

Few-Shot incluye varias demostraciones dentro del prompt. Brown et al. mostraron que los modelos de gran escala pueden aprender tareas en contexto sin actualizar sus parámetros [1]. Los ejemplos deben cubrir casos normales, ambiguos y límites; además, deben mantener un formato consistente.

**Aplicación al proyecto:** diferenciar fallas parecidas, normalizar síntomas expresados de distintas maneras y producir tickets con una plantilla uniforme.

**Ventaja:** mejora la consistencia y aclara el espacio de etiquetas. **Costo:** aumenta la longitud, la latencia y el consumo de tokens. Ejemplos sesgados también pueden inducir respuestas sesgadas.

### 2.4 Chain of Thought

Chain of Thought (CoT) solicita o demuestra una secuencia de pasos intermedios para tareas que requieren razonamiento multietapa. Wei et al. reportaron mejoras en tareas aritméticas, simbólicas y de sentido común al incluir demostraciones razonadas [2]. Kojima et al. mostraron que una instrucción de razonamiento paso a paso puede mejorar ciertos escenarios Zero-Shot [3].

En una aplicación técnica no es necesario exponer razonamientos internos extensos al usuario. Es preferible solicitar una **justificación verificable y breve**: hechos utilizados, regla coincidente, datos faltantes y conclusión. Así se obtiene trazabilidad sin depender de explicaciones libres que podrían contener errores.

**Aplicación al proyecto:** comprobar contradicciones, decidir si existe evidencia suficiente y verificar qué regla IF-THEN coincide con los hechos.

### 2.5 Comparación de las técnicas

| Técnica | Ejemplos incluidos | Ventaja principal | Limitación principal | Uso recomendado |
|---|---:|---|---|---|
| Zero-Shot | 0 | Menor costo y rapidez | Mayor ambigüedad | Extracciones simples |
| One-Shot | 1 | Enseña formato con poco contexto | Dependencia de un ejemplo | Salida JSON estable |
| Few-Shot | 2 o más | Mayor consistencia entre clases | Más tokens y posible sesgo | Clasificación de síntomas |
| Chain of Thought | Pasos o demostraciones razonadas | Ayuda en tareas multietapa | Mayor latencia; la explicación puede fallar | Verificación de reglas y contradicciones |

## 3. Criterios de optimización

Los veinte prompts siguen estos criterios:

1. Definir un rol y una tarea única.
2. Separar extracción, diagnóstico y explicación.
3. Indicar valores permitidos para cada variable.
4. Usar `desconocido` cuando no haya evidencia.
5. Prohibir la invención de pruebas o síntomas.
6. Exigir JSON válido cuando la salida será procesada por software.
7. Limitar longitud y lenguaje técnico según el destinatario.
8. Incluir criterio de escalamiento cuando la confianza sea baja.
9. Evitar acciones peligrosas o cambios automáticos en la red.
10. Proteger datos personales y detalles sensibles de infraestructura.

## 4. Veinte prompts especializados

### Prompt 1. Extracción completa de síntomas (Zero-Shot)

**Objetivo:** convertir lenguaje natural en las ocho variables del sistema.

```text
Eres un extractor de síntomas de red. Lee la descripción del usuario y responde únicamente un objeto JSON válido con estas claves: tipo_conexion, led_enlace_router, ip_asignada, ping_router, ping_dns_externo, resolucion_dns, acceso_web y autenticacion_usuario.

Valores permitidos:
- tipo_conexion: ethernet, wifi, desconocido
- led_enlace_router: apagado, rojo, parpadeante, verde, desconocido
- ip_asignada: ninguna, autoconfigurada_apipa, valida_dhcp, desconocido
- ping_router y ping_dns_externo: exitoso, fallido, desconocido
- resolucion_dns: funciona, falla, desconocido
- acceso_web: nulo, parcial, total, desconocido
- autenticacion_usuario: correcta, rechazada, desconocido

No diagnostiques, no inventes datos y no añadas texto fuera del JSON.
Descripción: {descripcion_usuario}
```

### Prompt 2. Clasificación del tipo de conexión (Zero-Shot)

```text
Identifica el tipo de conexión mencionado o implicado explícitamente en el texto. Responde únicamente una etiqueta: ethernet, wifi o desconocido. No asumas que un computador usa ethernet ni que un celular usa wifi.
Texto: {descripcion_usuario}
```

### Prompt 3. Detección de acceso web (Zero-Shot)

```text
Clasifica el acceso web según el texto: nulo si ninguna página carga; parcial si solo algunas cargan o la conexión es intermitente/lenta; total si todo funciona; desconocido si no hay evidencia. Responde solo la etiqueta.
Texto: {descripcion_usuario}
```

### Prompt 4. Preguntas para datos faltantes (Zero-Shot)

```text
Recibirás un JSON con síntomas de red. Formula como máximo tres preguntas breves para completar únicamente los campos con valor "desconocido" que más ayuden a diferenciar una falla física, DHCP, DNS, firewall, WiFi o caída WAN. No repitas información conocida ni emitas un diagnóstico.
JSON: {sintomas_json}
```

### Prompt 5. Explicación para usuario final (Zero-Shot)

```text
Explica el diagnóstico y la acción sugerida en máximo tres frases, con lenguaje sencillo. No cambies el diagnóstico, no prometas que la acción resolverá el problema y recomienda soporte humano si persiste. Diagnóstico validado: {diagnostico}. Acción validada: {accion}.
```

### Prompt 6. Extracción JSON con un ejemplo (One-Shot)

```text
Transforma la descripción en JSON usando solo valores permitidos y "desconocido" si falta evidencia.

Ejemplo:
Usuario: "Estoy por WiFi y la contraseña aparece incorrecta".
Salida: {"tipo_conexion":"wifi","led_enlace_router":"desconocido","ip_asignada":"desconocido","ping_router":"desconocido","ping_dns_externo":"desconocido","resolucion_dns":"desconocido","acceso_web":"desconocido","autenticacion_usuario":"rechazada"}

Caso nuevo: {descripcion_usuario}
Salida (solo JSON):
```

### Prompt 7. Normalización de dirección APIPA (One-Shot)

```text
Clasifica el estado de la IP como ninguna, autoconfigurada_apipa, valida_dhcp o desconocido.

Ejemplo: "Mi dirección empieza por 169.254" -> autoconfigurada_apipa
Caso: {descripcion_usuario}
Responde solo la etiqueta y no infieras datos no mencionados.
```

### Prompt 8. Creación de ticket técnico (One-Shot)

```text
Genera un ticket con los campos RESUMEN, SÍNTOMAS CONFIRMADOS, PRUEBAS, DIAGNÓSTICO VALIDADO, ACCIÓN REALIZADA y ESTADO.

Ejemplo:
RESUMEN: Equipo sin acceso web.
SÍNTOMAS CONFIRMADOS: Ethernet; LED apagado.
PRUEBAS: Cable inspeccionado.
DIAGNÓSTICO VALIDADO: Falla de enlace físico.
ACCIÓN REALIZADA: Reconectar cable UTP.
ESTADO: Pendiente de verificación.

Datos del caso: {datos_caso}
No agregues pruebas ni acciones que no estén en los datos.
```

### Prompt 9. Explicación de un resultado Prolog (One-Shot)

```text
Convierte la salida Prolog en una explicación de máximo dos frases.

Ejemplo: diagnostico(pc_finanzas, falla_hardware_fisico) -> "El sistema detectó una posible falla física en pc_finanzas. Revisa el cable de red en ambos extremos."

Salida nueva: {salida_prolog}
Acción autorizada: {accion}
No añadas una causa diferente.
```

### Prompt 10. Anonimización de incidentes (One-Shot)

```text
Anonimiza nombres, correos, teléfonos, IP públicas y ubicaciones precisas, pero conserva síntomas técnicos.

Ejemplo: "Ana Pérez, 3001234567, equipo 192.0.2.10, no resuelve DNS" -> "[USUARIO], [TELÉFONO], equipo [IP], no resuelve DNS".

Incidente: {texto_incidente}
Devuelve únicamente el texto anonimizado.
```

### Prompt 11. Clasificación con varios ejemplos (Few-Shot)

```text
Clasifica el caso en una sola etiqueta diagnóstica usando únicamente evidencia explícita.

Ejemplo 1: ethernet + LED apagado -> falla_enlace_fisico
Ejemplo 2: IP APIPA + ping_router fallido -> fallo_dhcp
Ejemplo 3: ping_dns_externo exitoso + resolucion_dns falla -> fallo_dns
Ejemplo 4: wifi + autenticacion rechazada -> fallo_credenciales_wifi

Caso: {sintomas_json}
Si faltan antecedentes para aplicar una regla, responde sin_evidencia_suficiente.
```

### Prompt 12. Diferenciación DNS frente a caída WAN (Few-Shot)

```text
Determina si el caso corresponde a fallo_dns, caida_wan o sin_evidencia_suficiente.

Ejemplo A: ping_router=exitoso, ping_dns_externo=exitoso, resolucion_dns=falla -> fallo_dns
Ejemplo B: ping_router=exitoso, ping_dns_externo=fallido, acceso_web=nulo -> caida_wan
Ejemplo C: ping_router=desconocido, ping_dns_externo=desconocido -> sin_evidencia_suficiente

Caso: {sintomas_json}
Responde solo una etiqueta.
```

### Prompt 13. Selección de acción segura (Few-Shot)

```text
Selecciona únicamente una acción de la lista autorizada: verificar_cable, reiniciar_router, renovar_ip, revisar_firewall, contactar_isp, cambiar_dns, reingresar_clave_wifi, cambiar_canal_wifi, revisar_proxy, escalar_soporte.

falla_enlace_fisico -> verificar_cable
fallo_dhcp -> renovar_ip
fallo_dns -> cambiar_dns
fallo_credenciales_wifi -> reingresar_clave_wifi
diagnóstico desconocido -> escalar_soporte

Diagnóstico: {diagnostico}
Responde solo la acción. No propongas comandos destructivos ni desactives controles de seguridad.
```

### Prompt 14. Priorización del incidente (Few-Shot)

```text
Asigna prioridad baja, media, alta o crítica.

- Un usuario con lentitud parcial -> baja
- Un usuario sin conexión -> media
- Varios usuarios afectados por el mismo switch/router -> alta
- Servicio crítico y toda la organización sin red -> crítica

Caso: {descripcion_incidente}
Responde JSON: {"prioridad":"...","motivo":"máximo 20 palabras"}.
```

### Prompt 15. Respuesta conversacional consistente (Few-Shot)

```text
Redacta una respuesta empática, breve y verificable.

Ejemplo 1:
Diagnóstico: fallo_dns. Acción: cambiar_dns.
Respuesta: "La conexión llega a internet, pero el equipo no traduce los nombres de las páginas. Soporte puede configurar un DNS alternativo; si el problema continúa, escala el caso."

Ejemplo 2:
Diagnóstico: falla_enlace_fisico. Acción: verificar_cable.
Respuesta: "No se detecta enlace físico. Revisa que el cable esté conectado en ambos extremos y solicita soporte si el LED continúa apagado."

Caso: diagnóstico={diagnostico}; acción={accion}.
No agregues pasos diferentes a la acción autorizada.
```

### Prompt 16. Verificación estructurada de una regla (Chain of Thought verificable)

```text
Evalúa el caso sin mostrar razonamiento interno libre. Devuelve una tabla con: HECHO REQUERIDO, VALOR OBSERVADO y CUMPLE (sí/no/desconocido). Después indica REGLA APLICABLE y CONCLUSIÓN. Si algún antecedente obligatorio es desconocido, la conclusión debe ser sin_evidencia_suficiente.

Regla candidata: {regla_if_then}
Hechos observados: {sintomas_json}
```

### Prompt 17. Detección de contradicciones (Chain of Thought verificable)

```text
Comprueba de forma ordenada la consistencia del caso. Lista únicamente: 1) contradicciones directas, 2) campos que necesitan confirmación y 3) estado final: consistente, inconsistente o incompleto. No diagnostiques.

Caso: {sintomas_json}
Ejemplos de contradicción: acceso_web=total junto con acceso_web=nulo; autenticacion=correcta y rechazada para la misma prueba.
```

### Prompt 18. Diagnóstico híbrido reglas más ML (Chain of Thought verificable)

```text
Compara dos resultados sin inventar un tercero.

Paso verificable 1: indica si la regla tiene todos sus antecedentes confirmados.
Paso verificable 2: registra la predicción y confianza del modelo ML.
Paso verificable 3: aplica esta política: regla completa tiene prioridad; sin regla completa, usa ML solo si confianza >= {umbral}; en otro caso escala.

Entrada: regla={resultado_regla}; prediccion_ml={prediccion_ml}; confianza={confianza}; umbral={umbral}.
Salida JSON: {"fuente":"regla|ml|escalamiento","diagnostico":"...","motivo_verificable":"..."}.
```

### Prompt 19. Análisis de causa compartida en el grafo (Chain of Thought verificable)

```text
Analiza las relaciones proporcionadas como una lista de triples sujeto-relación-objeto. No uses conocimiento externo. Devuelve: dispositivos afectados, infraestructura compartida, fallas relacionadas y causa común candidata. Incluye las rutas del grafo que respaldan la conclusión. Si no existe una ruta común, responde "sin causa común demostrable".

Triples: {triples_grafo}
```

### Prompt 20. Decisión de escalamiento seguro (Chain of Thought verificable)

```text
Evalúa el caso mediante esta lista de comprobación: evidencia completa, coincidencia de regla, confianza ML, impacto, acción segura ya intentada y presencia de infraestructura crítica. Devuelve la lista con sí/no/desconocido y una decisión final entre autoservicio, soporte_nivel_1 o escalar_especialista.

Reglas: escalar si hay infraestructura crítica, contradicciones, confianza inferior al umbral o si una acción segura ya falló. No sugieras cambios de firewall, credenciales administrativas ni reinicios de infraestructura compartida al usuario final.

Caso: {datos_caso}
```

## 5. Optimización realizada

La versión inicial de los prompts permitía respuestas abiertas. La versión optimizada introdujo cinco mejoras:

| Problema inicial | Optimización | Resultado esperado |
|---|---|---|
| El modelo inventa valores | Etiquetas cerradas y `desconocido` | Menos alucinaciones |
| Mezcla extracción y diagnóstico | Prompts separados por etapa | Mayor trazabilidad |
| Respuesta difícil de procesar | JSON o etiquetas únicas | Integración automática |
| Recomienda acciones riesgosas | Lista de acciones autorizadas | Mayor seguridad |
| Explicaciones extensas | Límites de frases/palabras | Respuestas más claras |

Los prompts 1, 6, 11 y 16 permiten comparar la misma tarea bajo Zero-Shot, One-Shot, Few-Shot y razonamiento verificable. La hipótesis es que Zero-Shot será suficiente para casos explícitos; One-Shot mejorará el formato; Few-Shot ayudará a diferenciar clases; y el enfoque verificable reducirá conclusiones cuando falten antecedentes.

## 6. Comparación entre modelos de IA

### 6.1 Modelos propuestos

Para una comparación reproducible se recomienda ejecutar los mismos casos en tres categorías:

1. **Modelo comercial de razonamiento alto:** orientado a instrucciones complejas y verificación multietapa.
2. **Modelo comercial rápido/generalista:** orientado a baja latencia y extracción estructurada.
3. **Modelo abierto ejecutado localmente:** orientado a privacidad y control de infraestructura.

Se pueden usar modelos disponibles de OpenAI, Google, Anthropic o familias abiertas como Llama/Mistral, registrando siempre el identificador y la versión exacta. No debe compararse solo el nombre del proveedor, porque las versiones cambian.

### 6.2 Casos de prueba comunes

| Caso | Entrada resumida | Resultado esperado |
|---|---|---|
| C1 | Ethernet y LED apagado | falla_enlace_fisico |
| C2 | APIPA y ping al router fallido | fallo_dhcp |
| C3 | Ping externo exitoso y DNS falla | fallo_dns |
| C4 | WiFi y autenticación rechazada | fallo_credenciales_wifi |
| C5 | Datos incompletos: “No tengo internet” | sin_evidencia_suficiente + preguntas |
| C6 | Datos contradictorios | inconsistente + solicitud de confirmación |
| C7 | Regla ausente y ML con confianza 0.91 | usar ML si supera el umbral |
| C8 | Regla ausente y ML con confianza 0.52 | escalar |

### 6.3 Métricas

Cada combinación modelo-prompt debe ejecutarse al menos tres veces con temperatura 0 o el valor determinista más cercano. Se registran:

- Exactitud diagnóstica sobre los casos con respuesta conocida.
- Validez del JSON.
- Porcentaje de campos inventados.
- Cumplimiento del formato.
- Decisiones de escalamiento correctas.
- Latencia media.
- Tokens o costo estimado.
- Claridad, evaluada de 1 a 5 por una persona.

### 6.4 Matriz para registrar resultados reales

| Modelo y versión | Técnica | Exactitud | JSON válido | Datos inventados | Escalamiento correcto | Latencia | Observaciones |
|---|---|---:|---:|---:|---:|---:|---|
| Por ejecutar | Zero-Shot | — | — | — | — | — | — |
| Por ejecutar | One-Shot | — | — | — | — | — | — |
| Por ejecutar | Few-Shot | — | — | — | — | — | — |
| Por ejecutar | CoT verificable | — | — | — | — | — | — |

> **Nota metodológica:** en esta entrega no se inventan puntuaciones de modelos externos. La matriz queda preparada para registrar evidencia real cuando se disponga de acceso a sus interfaces o API. Una comparación sin ejecutar los mismos casos, parámetros y versiones no constituye un experimento válido.

### 6.5 Comparación cualitativa para selección

| Criterio | Modelo de razonamiento alto | Modelo rápido/generalista | Modelo abierto local |
|---|---|---|---|
| Reglas complejas | Recomendado | Adecuado con prompts estrictos | Depende del tamaño y ajuste |
| Extracción JSON | Muy adecuado | Recomendado por costo/latencia | Adecuado con validación |
| Privacidad | Depende del proveedor | Depende del proveedor | Mayor control local |
| Costo operativo | Generalmente mayor | Generalmente menor | Requiere infraestructura |
| Trazabilidad | Exige salida verificable | Exige salida verificable | Exige salida verificable |

La arquitectura recomendada no obliga a usar un solo modelo. Un modelo rápido puede extraer JSON y uno de mayor razonamiento puede revisar casos contradictorios. Para información sensible, un modelo local puede anonimizar o procesar datos antes de cualquier servicio externo.

## 7. Prompt recomendado

El Prompt 1 es el mejor punto de entrada porque restringe el vocabulario, admite incertidumbre, evita diagnosticar y produce una salida procesable. Para diagnóstico se recomienda combinarlo con el Prompt 18, que aplica una política explícita de fusión entre reglas y Machine Learning. Esta cadena ofrece mayor seguridad que un único prompt que reciba el relato y decida todo.

## 8. Conclusiones

Zero-Shot es útil para tareas simples y económicas; One-Shot enseña rápidamente el formato; Few-Shot mejora la estabilidad cuando existen varias clases; y Chain of Thought es apropiado para decisiones multietapa. En este proyecto se propone una variante verificable que muestra hechos y reglas aplicadas, en vez de solicitar explicaciones internas extensas.

La optimización más importante no consiste en hacer el prompt más largo, sino en dividir responsabilidades, cerrar el espacio de valores, declarar incertidumbre, validar formatos y definir cuándo escalar. Los veinte prompts cubren extracción, normalización, clasificación, explicación, anonimización, priorización, verificación, fusión híbrida y análisis del grafo.

La comparación entre modelos debe realizarse con las mismas entradas, versiones, parámetros y métricas. La matriz propuesta permite documentar resultados reales sin atribuir capacidades o puntuaciones no comprobadas.

## Referencias

[1] T. B. Brown et al., “Language Models are Few-Shot Learners,” *Advances in Neural Information Processing Systems*, vol. 33, pp. 1877-1901, 2020. doi: 10.48550/arXiv.2005.14165.

[2] J. Wei et al., “Chain-of-Thought Prompting Elicits Reasoning in Large Language Models,” arXiv:2201.11903, 2022. doi: 10.48550/arXiv.2201.11903.

[3] T. Kojima, S. S. Gu, M. Reid, Y. Matsuo and Y. Iwasawa, “Large Language Models are Zero-Shot Reasoners,” in *Advances in Neural Information Processing Systems*, 2022. doi: 10.48550/arXiv.2205.11916.

[4] DAIR.AI, “Few-Shot Prompting,” *Prompt Engineering Guide*. [Online]. Available: https://www.promptingguide.ai/techniques/fewshot. [Accessed: Jul. 13, 2026].
