:-consult(busqueda.pl):

/* Auxiliar Minimo frontera */
minimo_frontera(MinimoNodo):-
    frontera(Min,Valor1),
    forall(frontera(_,Valor2),Valor2 =< Valor1),
    MinimoNodo is Min.

%---------------------------------------------------------------------
%Se vac�an estructuras para realizar nuevas consultas sin necesidad de
%cerrar y abrir nuevamente el archivo
limpiar_estructuras():-
	retractall(frontera(_)),
	retractall(visitados(_)),
%--------------------------------------------------------------------
