/* Importación de mapa ejemplo*/
:-consult(minaExample).
:-consult(acciones).

:-dynamic ejecutar_accion/4.

/* Generar vecinos */
generar_vecinos(Estado,Vecinos):-
    findall([EstadoSiguiente,Operacion,Costo], ejecutar_accion(Estado,EstadoSiguiente,Operacion,Costo), Vecinos).

