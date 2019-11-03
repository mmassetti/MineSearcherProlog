/* Importación de mapa ejemplo*/
:-consult(minaExample).
:-consult(acciones).

:-dynamic ejecutar_accion/4.
:-dynamic frontera/1.  
:-dynamic visitados/1.

/* Generar vecinos */
generar_vecinos([Estado,Camino,CostoNodo,_],Vecinos):-
    findall([EstadoSiguiente,[Operacion|Camino],CostoTotal],accion_agente(Estado,EstadoSiguiente,Operacion,CostoNodo,CostoTotal),Vecinos).

/* Cascara accion agente */
accion_agente(Estado,EstadoSiguiente,Operacion,CostoNodo,CostoTotal):-
    ejecutar_accion(Estado,EstadoSiguiente,Operacion,CostoAccion),
    CostoTotal is CostoNodo + CostoAccion.


/* Agregar vecinos */
agregar_vecinos([]):-!.

agregar_vecinos([X|ListaVecinos]):-
    visitados(X),
    agregar_vecinos(ListaVecinos).

agregar_vecinos([X|ListaVecinos]):-
    X= [Estado,Camino,CostoNodo],
    not(visitados(X)),
    asserta(visitados(X)),
    fakeObtenerHeuristica(X,ValorH),
    CostoTotal is CostoNodo+ ValorH,
    Nuevo= [Estado,Camino,CostoNodo,CostoTotal],
    asserta(frontera(Nuevo)),
    agregar_vecinos(ListaVecinos).



/* Algoritmo A* */

/*
1) Sacar minimo de la frontera
2) Fijarse si es meta 
3) Si no es meta generar los vecinos
4) Agrego los vecinos a la frontera (control de ciclos)
5) Llamo recursivo a A* 

*/


/* algoritmoA*(+Costo,-Camino) */

/* Caso Base : Saco el minimo de la frontera y es meta */
algoritmoA*(Nodo):-
    minimo_frontera(Nodo),
    esMeta(Nodo).

/* Caso Recursivo */
algoritmoA*(Nodo):-
    minimo_frontera(Minimo),
    not(esMeta(Minimo)),
    generar_vecinos(Minimo,Vecinos),
    retract(frontera(Minimo)),
    agregar_vecinos(Vecinos),
    algoritmoA*(Nodo).


/* buscar_plan */
/* buscar_plan(+EInicial,-Plan,-Destino,-Costo)  */
buscar_plan(EstadoInicial,Plan,Destino,Costo):-
    /* En frontera tengo nodos de la forma: [Estado,Camino,CostoNodo,CostoTotal] */
    /* El EstadoInicial es de la forma: [Pos,Dir,ListaPosesiones,CargaPendiente] */
    limpiar_estructuras(),
    assertz(frontera([EstadoInicial,[],0,0])),
    algoritmoA*(NodoMeta),
    NodoMeta = [EstadoMeta,Camino,Costo,_],
    EstadoMeta= [Destino,_,_,_],
    reverse(Camino,Plan).

buscar_plan(_,_,_,_):-
	writeln('No es posible encontrar un plan para este estado'),
	fail.

/*------------------------HEURISTICAS------------------------------*/
    /* Desde la mas restrictiva a la mas general */
fakeObtenerHeuristica(Estado,0).



/* Caso 1 : El minero tiene el detonador y ya coloco la carga 
    la heuristica devuelve la menor distancia a un sitio de detonacion
*/
obtenerHeuristica(Estado,ValorH):-
        Estado= [Pos,_,ListaPosesiones,no],
        member([d,_,_],ListaPosesiones),
        menorDistanciaAMeta(Pos,ValorH).
        

/*------------------------------------------------------------------*/

/*---------------------------AUXILIARES-----------------------------*/

/*minimo_frontera(MinimoNodo):-
    findall(Nodo,frontera(Nodo),ListaNodosFrontera),
    minimoF(MinimoNodo,ListaNodosFrontera). 

minimoF(Nodo,[X|ListaNodos]):-
    minimoAux(Nodo,X,ListaNodos).

minimoAux(Nodo,Nodo,[]):-!.

minimoAux(Nodo1,Nodo2,[Nodo3|ListaNodos]):-
    Nodo1= [_,_,_,Costo1],
    Nodo2= [_,_,_,Costo2],
    Costo1=<Costo2,
    !,
    minimoAux(Nodo1,Nodo3,ListaNodos).

minimoAux(Nodo1,Nodo2,[Nodo3|ListaNodos]):-
    Nodo3 = [_,_,_,Costo3],
    Nodo2 = [_,_,_,Costo2],
    Costo3>=Costo2,
    minimoAux(Nodo1,Nodo2,ListaNodos).*/











/* minimo_frontera(-MinimoNodo) */
minimo_frontera(MinimoNodo):-
    findall(Nodo,frontera(Nodo),[PrimerNodo|Resto]),
    minimo(PrimerNodo,Resto,MinimoNodo).

/* minimo(+Nodo,+Resto,+MinimoNodo) */
minimo(Nodo,[],Nodo):- !.

minimo([Estado1,Camino1,CostoNodo1,CostoTotal1],[[Estado2,Camino2,CostoNodo2,CostoTotal2]|Resto],Minimo):-
    /*  [Estado,Camino,CostoNodo,CostoTotal]*/
     CostoTotal1 < CostoTotal2 -> minimo([Estado1,Camino1,CostoNodo1,CostoTotal1],Resto,Minimo)
                                 ; 
                                 minimo([Estado2,Camino2,CostoNodo2,CostoTotal2],Resto,Minimo).

/* esMeta(+Estado) 
    -No debe tener la carga pendiente 
    -Tiene que tener activado el detonador
    Tiene que estar en el sitio de detonación */

esMeta(Nodo):-
    Nodo=[Estado,_,_,_],
    Estado=[Pos,_,ListaPosesiones,no],
    member([d,_,_],ListaPosesiones),  /* tiene que estar en si el tercer argumento? */
    sitioDetonacion(Pos).


/* Menor distancia a meta */
menorDistanciaAMeta(Pos, Valor):- findall(X, esMeta(X), ListaMetas), metaDeMenorDistancia(Pos, ListaMetas, Valor).


/* Meta de menor distancia */
metaDeMenorDistancia(Pos, [Meta|Metas], ValorActual):- distanciaManhattan(Pos, Meta, ValorActual),
 metaDeMenorDistancia(Pos, Metas, ValorRecursivo), ValorActual < ValorRecursivo.

metaDeMenorDistancia(Pos, [Meta|Metas], ValorRecursivo):- distanciaManhattan(Pos, Meta, ValorActual),
 metaDeMenorDistancia(Pos, Metas, ValorRecursivo), ValorActual >= ValorRecursivo.

metaDeMenorDistancia(Pos,[Meta], Valor):- distanciaManhattan(Pos, Meta, Valor).
    
/* Calculo distancia de Manhattan */
distanciaManhattan([Pos1X, Pos1Y], [Pos2X, Pos2Y], Valor):- Valor is abs(Pos1X-Pos2X) + abs(Pos1Y-Pos2Y).


/* Se vacian estructuras para realizar nuevas consultas sin necesidad de cerrar y abrir nuevamente el archivo */
limpiar_estructuras():-
	retractall(frontera(_)),
	retractall(visitados(_)).



/*********************************************************************/





