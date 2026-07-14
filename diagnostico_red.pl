% =================================================================
% BASE DE CONOCIMIENTO EN PROLOG
% Proyecto: Sistema Experto para Diagnostico Basico de Fallas en Redes
% =================================================================

% =================================================================
% 1. HECHOS (10 hechos sobre el estado de la red y los dispositivos)
% =================================================================

% Estados fisicos de los dispositivos (un ping fallido o puerto caido)
ping_falla(router_principal).
ping_falla(servidor_web).
puerto_caido(switch_piso1).

% Configuraciones de red incorrectas o fallas de software
ip_duplicada(pc_contabilidad).
dns_incorrecto(pc_marketing).
dhcp_desactivado(router_principal).

% Reportes de los usuarios del sistema
usuario_reporta(pc_marketing, no_abre_paginas_web).
usuario_reporta(pc_finanzas, sin_internet_total).
usuario_reporta(pc_contabilidad, conexion_intermitente).

% Informacion de infraestructura fisica
cable_desconectado(pc_finanzas).

% =================================================================
% 2. REGLAS (5 reglas de diagnostico para inferir fallas)
% =================================================================

% Regla 1: Falla de hardware fisico
diagnostico(Dispositivo, falla_hardware_fisico) :-
    cable_desconectado(Dispositivo).

% Regla 2: Falla de resolucion de nombres (DNS)
diagnostico(Dispositivo, error_configuracion_dns) :-
    dns_incorrecto(Dispositivo),
    usuario_reporta(Dispositivo, no_abre_paginas_web).

% Regla 3: Conflicto de direccionamiento IP en la red
diagnostico(Dispositivo, conflicto_ip) :-
    ip_duplicada(Dispositivo).

% Regla 4: Caida critica de la red local (falta de enrutamiento o DHCP)
diagnostico(Dispositivo, aislamiento_red_por_router) :-
    usuario_reporta(Dispositivo, sin_internet_total),
    ping_falla(router_principal).

% Regla 5: Falla de enlace o infraestructura de distribucion
diagnostico(switch_piso1, falla_enlace_troncal) :-
    puerto_caido(switch_piso1),
    dhcp_desactivado(router_principal).

% =================================================================
% 3. CONSULTAS DE EJEMPLO
% =================================================================
% ?- diagnostico(pc_marketing, Falla).
% ?- diagnostico(X, falla_hardware_fisico).
% ?- diagnostico(X, aislamiento_red_por_router).
% ?- ping_falla(Dispositivo).
% ?- diagnostico(Equipo, Problema).
