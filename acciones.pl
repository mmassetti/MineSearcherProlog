:-consult(minaExample). 

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

suelo(firme,2).
suelo(resbaladizo,3).


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

ejecutar_accion(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],caminar,Costo):-
	caminar(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],Costo).

ejecutar_accion(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],girar(DirDestino),Costo):-
	girar(Estado,DirDestino,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],Costo).

ejecutar_accion(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],saltar,Costo):-
	saltar(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],Costo).

ejecutar_accion(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],juntar_llave,Costo):-
	juntar_llave(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],Costo).

ejecutar_accion(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],juntar_carga,Costo):-
	juntar_carga(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],Costo).

ejecutar_accion(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],juntar_detonador,Costo):-
	juntar_detonador(Estado,[Pos,DirDestino,ListaPosesiones,ColocacionCargaPendiente],Costo).

ejecutar_accion(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],dejar_carga,Costo):-
	dejar_carga(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],Costo).

ejecutar_accion(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],detonar,Costo):-
	detonar(Estado,[Pos,Dir,ListaPosesiones,ColocacionCargaPendiente],Costo).

caminar([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente],[PosDestino,Dir,ListaPosesiones,ColocacionCargaPendiente],Costo):-
    celdaDestino(Pos,PosDestino,avanzar,Dir),
    (libreDeObstaculos(PosDestino); estaEn([r,Rid],PosDestino),member([l,Lid],ListaPosesiones),abreReja([l,Lid],[r,Rid])),
    celda(PosDestino,TipoSuelo),
    suelo(TipoSuelo,Costo).

girar([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente], DirDestino, [Pos, DirDestino, ListaPosesiones,ColocacionCargaPendiente], 1):- distancia90grados(Dir, DirDestino).
girar([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente], DirDestino, [Pos, DirDestino, ListaPosesiones,ColocacionCargaPendiente], 2):- distancia180grados(Dir, DirDestino).

saltar([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente],[PosDestino,Dir,ListaPosesiones,ColocacionCargaPendiente],Costo):- 
    celdaDestino(Pos,PosDestino,saltar, Dir), /*Celda a donde quiero saltar */
    libreDeObstaculos(PosDestino),
    celda(PosDestino,TipoSuelo),
    suelo(TipoSuelo,CostoSuelo),
    celdaDestino(Pos,PosObstaculo,avanzar,Dir),  /* Celda por la que tengo que saltar */
    estaEn([v,_,Altura],PosObstaculo),  /* Solo puedo saltar vallas */
    Altura < 4,  /*Con altura menor a 4 */
    Costo is 1 + CostoSuelo.

juntar_llave([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente],[Pos,Dir,NuevaListaPosesiones,ColocacionCargaPendiente], Costo):-
    estaEn([l,NombreL],Pos),
    not(member([l,NombreL],ListaPosesiones)),
    Costo is 1,
    append(ListaPosesiones,[[l,NombreL]],NuevaListaPosesiones).

juntar_carga([Pos, Dir, ListaPosesiones,si],[Pos,Dir,NuevaListaPosesiones,si],Costo):-
    estaEn([c,NombreC],Pos),
    not(member([c,NombreC],ListaPosesiones)),
    Costo is 3,
    append(ListaPosesiones,[[c,NombreC]],NuevaListaPosesiones).

 juntar_detonador([Pos, Dir, ListaPosesiones,ColocacionCargaPendiente],[Pos,Dir,NuevaListaPosesiones,ColocacionCargaPendiente], Costo):-
    estaEn([d,NombreD,Activo],Pos),
    not(member([d,NombreD,Activo],ListaPosesiones)),
    Costo is 2,
    append(ListaPosesiones,[[d,NombreD,Activo]],NuevaListaPosesiones).

dejar_carga([Pos,Dir,ListaPosesiones,si],[Pos,Dir,NuevaListaPosesiones,no],Costo):-
    member([c,NombreC],ListaPosesiones),
    ubicacionCarga(Pos),
    delete(ListaPosesiones,[c,NombreC],NuevaListaPosesiones),
    Costo is 1.

detonar([Pos,Dir,ListaPosesiones,no],[Pos,Dir,NuevaListaPosesiones,no],Costo):-
    member([d,NombreD,no],ListaPosesiones),
    sitioDetonacion(Pos),
    delete(ListaPosesiones,[d,NombreD,no],ListaAux),  
    append(ListaAux,[[d,NombreD,si]],NuevaListaPosesiones),
    Costo is 1.





