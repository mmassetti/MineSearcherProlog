/* Importación de mapa ejemplo*/
:-consult(minaExample).
:-consult(acciones).

:-dynamic ejecutar_accion/4.
:-dynamic frontera/2.  /* Guardo estado y valor de la heuristica */
:-dynamic visitados/1.

/* Generar vecinos */
generar_vecinos(Estado,Vecinos):-
    findall([EstadoSiguiente,Operacion,Costo], ejecutar_accion(Estado,EstadoSiguiente,Operacion,Costo), Vecinos).

/* Agregar vecinos */
agregar_vecinos([X|ListaVecinos]):-
    not(visitados(X)),
    asserta(visitados,X),
    obtenerHeuristica(X,ValorH),
    asserta(frontera(X,ValorH)),
    agregar_vecinos(ListaVecinos).

/* Auxiliar Minimo frontera */
minimo_frontera(MinimoNodo):-
    frontera(Min,Valor1),
    forall(frontera(_,Valor2),Valor2 =< Valor1),
    MinimoNodo is Min.
    
/* Obtener heuristica  */
obtenerHeuristica(Nodo,ValorH):-
    ValorH is 99.






