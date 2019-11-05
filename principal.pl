/* Importación de mapa ejemplo*/
:-consult(minaExample).
:-consult(acciones).

:-dynamic ejecutar_accion/4.
:-dynamic frontera/1.  
:-dynamic visitados/1.

/* Generar vecinos */
generar_vecinos([Estado,Camino,CostoNodo,_],VecinosAgregar):-
    findall([EstadoSiguiente,[Operacion|Camino],CostoTotal],accion_agente(Estado,EstadoSiguiente,Operacion,CostoNodo,CostoTotal),Vecinos),
    control_visitados(Vecinos,VecinosAgregar).

/* Cascara accion agente */
accion_agente(Estado,EstadoSiguiente,Operacion,CostoNodo,CostoTotal):-
    ejecutar_accion(Estado,EstadoSiguiente,Operacion,CostoAccion),
    CostoTotal is CostoNodo + CostoAccion.


/* Agregar vecinos */
agregar_vecinos([]):-!.

agregar_vecinos([X|ListaVecinos]):-
    X= [Estado,_,_],
    visitados(Estado),
    agregar_vecinos(ListaVecinos).

agregar_vecinos([X|ListaVecinos]):-
    X= [Estado,Camino,CostoNodo],
    not(visitados(Estado)),
    asserta(visitados(Estado)),
    obtenerHeuristica(X,ValorH),
    CostoTotal is CostoNodo+ ValorH,
    Nuevo= [Estado,Camino,CostoNodo,CostoTotal],
    asserta(frontera(Nuevo)),
    agregar_vecinos(ListaVecinos).


/* algoritmoA*(+Costo,-Camino) */

/* Caso Base :  */
algoritmoA*(Nodo):-
    minimo_frontera(Nodo),
    esMeta(Nodo).

/* Caso Recursivo */
algoritmoA*(Nodo):-
    minimo_frontera(Minimo),
    generar_vecinos(Minimo,Vecinos),
    retract(frontera(Minimo)),
    agregar_vecinos(Vecinos),
    algoritmoA*(Nodo).


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

/* Caso 1 : TIENE detonador, COLOCO carga --> Se devuelve menor distancia a un sitio de detonacion */
obtenerHeuristica(Nodo,ValorH):-
    /*En Nodo viene, por ejemplo:  [[[12,2],e,[[d,d1,no],[c,c1]],no],[caminar],3] */
    Nodo= [Estado,_,_],
    Estado= [Pos,_,ListaPosesiones,no],
    member([d,_,_],ListaPosesiones),
    findall(Posicion, sitioDetonacion(Posicion), [Primera|Resto]),
	menorDistanciaASitioDetonacion(Pos, Primera, Resto, ValorH).
    
/* Caso 2 : NO TIENE detonador, COLOCO carga  --> Se devuelve distancia a detonador */
obtenerHeuristica(Nodo,ValorH):-
    Nodo= [Estado,_,_],
    Estado= [Pos,_,ListaPosesiones,no],
    not(member([d,_,_], ListaPosesiones)),
    estaEn([d,_,_],[PosXDet,PosYDet]),
    Pos = [X,Y],
    ValorH is abs(X-PosXDet) + abs(Y-PosYDet).

/* Caso 3 : TIENE detonador , TIENE carga , NO COLOCO carga  --> Se devuelve distancia a colocacion de carga */
obtenerHeuristica(Nodo,ValorH):-
    Nodo= [Estado,_,_],
    Estado= [Pos,_,ListaPosesiones,si],
    member([d,_,_],ListaPosesiones),
    member([c,_,_],ListaPosesiones),
    ubicacionCarga([PosXUbic,PosYUbic]),
    Pos = [X,Y],
    ValorH is abs(X-PosXUbic) + abs(Y-PosYUbic).

/* Caso 4 : TIENE detonador , NO TIENE carga, NO COLOCO carga --> Retorna distancia a carga */
obtenerHeuristica(Nodo,ValorH):-
    Nodo= [Estado,_,_],
    Estado= [Pos,_,ListaPosesiones,si],
    member([d,_,_],ListaPosesiones),
    not(member([c,_,_],ListaPosesiones)),
    estaEn([c,_],[PosXCarga,PosYCarga]),
    Pos = [X,Y],
    ValorH is abs(X-PosXCarga) + abs(Y-PosYCarga).

/* Caso 5 : NO TIENE detonador, TIENE carga, NO COLOCO carga 
            --> Se devuelve menor distancia a posicion de carga o a detonador */
obtenerHeuristica(Nodo,ValorH):-
    Nodo= [Estado,_,_],
    Estado= [Pos,_,ListaPosesiones,si],     
    not(member([d,_,_], ListaPosesiones)), 
    member([c,_,_],ListaPosesiones),
    ubicacionCarga([PosXUbic,PosYUbic]),
    estaEn([d,_,_],[PosXDet,PosYDet]),
    Pos = [X,Y],
    DistanciaUbicCarga is abs(X-PosXUbic) + abs(Y-PosYUbic),
    DistanciaDetonador is abs(X-PosXDet) + abs(Y-PosYDet),
    ValorH is min(DistanciaUbicCarga,DistanciaDetonador).

/* Caso 6 : NO TIENE detonador, NO TIENE carga, NO COLOCO carga 
            --> Se devuelve menor distancia a carga o a detonador*/
obtenerHeuristica(Nodo,ValorH):-
    Nodo= [Estado,_,_],
    Estado= [Pos,_,ListaPosesiones,si],     
    not(member([d,_,_], ListaPosesiones)), 
    not(member([c,_,_],ListaPosesiones)),
    estaEn([c,_],[PosXCarga,PosYCarga]),
    estaEn([d,_,_],[PosXDet,PosYDet]),
    Pos = [X,Y],
    DistanciaCarga is abs(X-PosXCarga) + abs(Y-PosYCarga),
    DistanciaDetonador is abs(X-PosXDet) + abs(Y-PosYDet),
    ValorH is min(DistanciaCarga,DistanciaDetonador).


/*------------------------------------------------------------------*/

/*---------------------------AUXILIARES HEURISTICAS-----------------------------*/

/* Menor distancia a sitio de detonacion */
menorDistanciaASitioDetonacion([X1,Y1], [X2, Y2], [], MenorDistancia):-
	MenorDistancia is abs(X1-X2) + abs(Y1-Y2).  /* Calculo distancia de Manhattan */

menorDistanciaASitioDetonacion([PosX,PosY], [X1, Y1], [[X2, Y2]|Resto], MenorDistancia) :-
	Distancia1 is abs(PosX-X1) + abs(PosY-Y1),  
	Distancia2 is abs(PosX-X2) + abs(PosY-Y2),
    Distancia1 < Distancia2  -> menorDistanciaASitioDetonacion([PosX,PosY],[X1, Y1],Resto,MenorDistancia) 
                             ;
							  menorDistanciaASitioDetonacion([PosX,PosY],[X2, Y2],Resto,MenorDistancia).


/*--------------------------------------------------------------------------------*/

/*-----------------------------AUXILIARES ESTRUCTURAS (NODOS)---------------------*/
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

/* esMeta(+Estado) */
esMeta(Nodo):-
    Nodo=[Estado,_,_,_],
    Estado=[_,_,ListaPosesiones,no],
    member([d,_,si],ListaPosesiones). 


/* control_visitados(+Vecinos,-VecinosAgregar): */
control_visitados([],[]):-!.

/* Caso 1 : Control frontera- Es posible alcanzar un determiando estado por un mejor camino que el asociado al nodo actual */
control_visitados(Vecinos,VecinosAgregar):-
	Vecinos=[Nodo|RestoVecinos],
    Nodo= [Estado,Camino,CostoNodo,CostoTotal],
    frontera([Estado,Camino1,CostoNodo1,CostoTotal1]),
    CostoTotal<CostoTotal1,!,
    retract(frontera([Estado,Camino1,CostoNodo1,CostoTotal1])),
    assertz(frontera([Estado,Camino,CostoNodo,CostoTotal])),
	control_visitados(RestoVecinos,VecinosAgregar).

/* Caso 2 : Control visitados- Es posible alcanzar un determiando estado por un mejor camino que el asociado al nodo actual*/
control_visitados(Vecinos,VecinosAgregar):-
    Vecinos=[Nodo|RestoVecinos],
    Nodo= [Estado,Camino,CostoNodo,CostoTotal],
    visitados([Estado,Camino1,CostoNodo1,CostoTotal1]),
    CostoTotal<CostoTotal1,
    retract(visitados([Estado,Camino1,CostoNodo1,CostoTotal1])),
    assertz(frontera(nodo(Estado,Camino,CostoNodo,CostoTotal))),
    control_visitados(RestoVecinos,VecinosAgregar).

/* Caso 3 : Control frontera-  No se efectúan cambios en la	Frontera*/
control_visitados(Vecinos,VecinosAgregar):-
    Vecinos=[Nodo|RestoVecinos],
    Nodo= [Estado,_,_,CostoTotal],
    frontera([Estado,_,_,CostoTotal1]),
    CostoTotal >= CostoTotal1,!,
    control_visitados(RestoVecinos,VecinosAgregar).
	

/* Caso 3: Control visitados - No se efectúan cambios en los Visitados */
control_visitados(Vecinos,VecinosAgregar):-
    Vecinos=[Nodo|RestoVecinos],
    Nodo= [Estado,_,_,CostoTotal],
    visitados([Estado,_,_,CostoTotal1]),
    CostoTotal > CostoTotal1, !,
    control_visitados(RestoVecinos,VecinosAgregar).

/* Caso 4 : Si no existe en la Frontera ni en el conjunto de Visitados un nodo N etiquetado con el estado E, 
entonces agregamos a la Frontera el nodo N2 */	
control_visitados([Nodo|RestoVecinos],[Nodo|VecinosAgregar]):-
	control_visitados(RestoVecinos,VecinosAgregar).

limpiar_estructuras():-
	retractall(frontera(_)),
	retractall(visitados(_)).


/*********************************************************************/





