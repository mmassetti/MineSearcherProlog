/* Importación de mapa ejemplo*/
/*:-consult(minaExample).

:-dynamic estaEn/2.
:-dynamic celda/2.

/* Reglas del juego */
distancia180grados(n,s).
distancia180grados(s,n).
distancia180grados(e,o).
distancia180grados(o,e).

distancia90grados(n, o).
distancia90grados(n, e).
distancia90grados(s, o).
distancia90grados(s, e).
distancia90grados(o, n).
distancia90grados(o, s).
distancia90grados(e, n).
distancia90grados(e, s).

/* suelo(tipo,costo) */
suelo(firme,2).
suelo(resbaladizo,3).


/* Celdas luego de avanzar o saltar - Notar que el norte es hacia abajo en la grilla  y el sur hacia arriba */   
celdaDestino([FilOrigen,ColOrigen],[FilDestino,ColOrigen],saltar,n):- FilDestino is (FilOrigen-2).
celdaDestino([FilOrigen,ColOrigen],[FilDestino,ColOrigen],saltar,s):- FilDestino is (FilOrigen+2).
celdaDestino([FilOrigen,ColOrigen],[FilOrigen,ColDestino],saltar,e):- ColDestino is (ColOrigen+2).
celdaDestino([FilOrigen,ColOrigen],[FilOrigen,ColDestino],saltar,o):- ColDestino is (ColOrigen-2).

celdaDestino([FilOrigen,ColOrigen],[FilDestino,ColOrigen],avanzar,n):- FilDestino is (FilOrigen-1).
celdaDestino([FilOrigen,ColOrigen],[FilDestino,ColOrigen],avanzar,s):- FilDestino is (FilOrigen+1).
celdaDestino([FilOrigen,ColOrigen],[FilOrigen,ColDestino],avanzar,e):- ColDestino is (ColOrigen+1).
celdaDestino([FilOrigen,ColOrigen],[FilOrigen,ColDestino],avanzar,o):- ColDestino is (ColOrigen-1).

libreDeObstaculos(PosDestino):-
    not(estaEn([r,_],PosDestino)), 
    not(estaEn([p,_,_],PosDestino)), 
    not(estaEn([v,_,_],PosDestino)).

/*------------------------------------Acciones del agente -----------------------------*/
%ejecutar_accion(+Estado,-NuevoEstado,+Accion,-CostoA):

ejecutar_accion(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],caminar,Costo):-
	caminar(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],Costo).

ejecutar_accion(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],girar,Costo):-
	girar(Estado,DirDestino,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],Costo).

ejecutar_accion(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],saltar,Costo):-
	saltar(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],Costo).

ejecutar_accion(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],juntar_llave,Costo):-
	juntar_llave(Estado,Llave,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],Costo).

ejecutar_accion(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],juntar_carga,Costo):-
	juntar_carga(Estado,Carga,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],Costo).

ejecutar_accion(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],juntar_detonador,Costo):-
	juntar_detonador(Estado,Detonador,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],Costo).

ejecutar_accion(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],dejar_carga,Costo):-
	dejar_carga(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],Costo).

ejecutar_accion(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],detonar,Costo):-
	detonar(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],Costo).


/*--------------------------------------------------------------------------------------/*

/*caminar(+EInicial,-EFinal,-Costo)   */
caminar([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente],[PosDestino,Dir,ListaPosesiones,ColocacionCargaPendiente],Costo):-
    celdaDestino(Pos,PosDestino,avanzar,Dir),
    (libreDeObstaculos(PosDestino); estaEn([r,Rid],PosDestino),member([l,Lid],ListaPosesiones),abreReja([l,Lid],[r,Rid])),
    celda(PosDestino,TipoSuelo),
    suelo(TipoSuelo,Costo).

/* girar(+EInicial,+DirDestino,-EFinal, -Costo) */  
girar([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente], DirDestino, [Pos, DirDestino, ListaPosesiones,ColocacionCargaPendiente], 1):- distancia90grados(Dir, DirDestino).
girar([Pos, Dir, ListaPosesiones], DirDestino, [Pos, DirDestino, ListaPosesiones], 2):- distancia180grados(Dir, DirDestino).

/* saltar(+EInicial, -EFinal, -Costo) */
saltar([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente],[PosDestino,Dir,ListaPosesiones,ColocacionCargaPendiente],Costo):- 
    celdaDestino(Pos,PosDestino,saltar, Dir), /*Celda a donde quiero saltar */
    libreDeObstaculos(PosDestino),
    celda(PosDestino,TipoSuelo),
    suelo(TipoSuelo,CostoSuelo),
    celdaDestino(Pos,PosObstaculo,avanzar,Dir),  /* Celda por la que tengo que saltar */
    estaEn([v,_,Altura],PosObstaculo),  /* Solo puedo saltar vallas */
    Altura < 4,  /*Con altura menor a 4 */
    Costo is 1 + CostoSuelo.

/* juntar_llave(+EInicial,+Llave,-EFinal,-Costo)   //Llave= [l; NombreL] */
juntar_llave([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente],[l,NombreL],[Pos,Dir,NuevaListaPosesiones,ColocacionCargaPendiente], Costo):-
    estaEn([l,NombreL],Pos),
    not(member([l,NombreL],ListaPosesiones)),
    Costo is 1,
    append(ListaPosesiones,[l,NombreL],NuevaListaPosesiones).

/* juntar_carga(+EInicial,+Carga,-EFinal,-Costo)   // Carga = [c; NombreC] */
juntar_carga([Pos, Dir, ListaPosesiones,si],[c,NombreC],[Pos,Dir,NuevaListaPosesiones,si],Costo):-
    estaEn([c,NombreC],Pos),
    not(member([c,NombreC],ListaPosesiones)),
    Costo is 3,
    append(ListaPosesiones,[c,NombreC],NuevaListaPosesiones).

 /* juntar_detonador(+EInicial,+Detonador,-EFinal,-Costo)   // Detonador = [d; NombreD] */
 juntar_detonador([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente],[d,NombreD,_],[Pos,Dir,NuevaListaPosesiones,ColocacionCargaPendiente], Costo):-
    estaEn([d,NombreD,_],Pos),
    not(member([d,NombreD,_],ListaPosesiones)),
    Costo is 2,
    append(ListaPosesiones,[d,NombreD],NuevaListaPosesiones).

/*dejar_carga(+EInicial,-EFinal,-Costo)*/
dejar_carga([Pos,Dir,ListaPosesiones,si],[Pos,Dir,NuevaListaPosesiones,no],Costo):-
    member([c,NombreC],ListaPosesiones),
    ubicacionCarga(Pos),
    delete(ListaPosesiones,[c,NombreC],NuevaListaPosesiones),
    Costo is 1.

/* Detonar: detonar(Detonador), donde Detonador = [d; NombreD; ActivadoD] es un detonador
que posee el minero y sera activado.*/

detonar([Pos,Dir,ListaPosesiones,no],[Pos,Dir,NuevaListaPosesiones,no]):-
    member([d,NombreD,no],ListaPosesiones),
    sitioDetonacion(Pos),
    delete(ListaPosesiones,[d,NombreD,no],ListaAux),  
    append(ListaAux,[d,NombreD,si],NuevaListaPosesiones).




