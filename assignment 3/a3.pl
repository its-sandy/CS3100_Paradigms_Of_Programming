edge(1, 2).
edge(2, 3).
edge(3, 4).
edge(1, 4).
edge(1, 5).
edge(5, 6).
edge(6, 7).
edge(7, 5).

mmember(X,[X|_]).
mmember(X,[Y|Z]) :- mmember(X,Z), Y\=X.

isedge(U, V) :- edge(U, V); edge(V, U).

getSequence(0,[]).
getSequence(N,[N|S]):-  isLessThan(1,N),
                        N1 is N-1,
                        getSequence(N1,S).

getAllVertices(Vertices):-  findall(X, isedge(X,_), VList),
                            max_member(N,VList),
                            getSequence(N,Vertices).

path(U, V, [U,V], AlreadySeen):- isedge(U, V),
                                 not(mmember(V, AlreadySeen)).

path(U, V, [U|Path], AlreadySeen):-  isedge(U, A),
                                     not(mmember(A, AlreadySeen)),
                                     path(A, V, Path, [A|AlreadySeen]).

% findpath is used to call path
findPath(U, V, Path, AlreadySeen):-  path(U, V, Path, [U|AlreadySeen]).

updateAlreadySeen(_, _, AlreadySeen, [], AlreadySeen).
updateAlreadySeen(U, V, AlreadySeen, [A|Path], NewAlreadySeen):-    (A=U; A=V),
                                                                    updateAlreadySeen(U, V, AlreadySeen, Path, NewAlreadySeen).
updateAlreadySeen(U, V, AlreadySeen, [A|Path], [A|NewAlreadySeen]):- (A\=U; A\=V),
                                                                     updateAlreadySeen(U, V, AlreadySeen, Path, NewAlreadySeen).
findKDisjointPaths(_, _, 0, [], []).

findKDisjointPaths(U, V, K, NewAlreadySeen, [Path|Paths]):-  not(isLessThan(K,0)),
                                                                            K1 is K-1,
                                                                            findKDisjointPaths(U, V, K1, AlreadySeen, Paths),
                                                                            findPath(U, V, Path, AlreadySeen),
                                                                            not(mmember(Path,Paths)),
                                                                            updateAlreadySeen(U,V,AlreadySeen,Path,NewAlreadySeen).

newVertexConnectedness(_, [], _).
newVertexConnectedness(U, [V|Vertices], K):- findKDisjointPaths(U, V, K, _, _),!,
                                             newVertexConnectedness(U, Vertices, K).

newGraphConnectedness([], _).
newGraphConnectedness([U|Vertices], K):- newVertexConnectedness(U, Vertices, K),!,
                                         newGraphConnectedness(Vertices, K).

conn(K):-   getAllVertices(GraphVertices),
            newGraphConnectedness(GraphVertices, K).

mpath(U, V, K):-    findKDisjointPaths(U, V, K, _, Paths),
                    printPaths(1, K, Paths).

biconn:- conn(2).

% printPath prints a path in given format
printPath([V]):-    write(' '), write(V).
printPath([V,W|Y]):-write(' '), write(V), write(' '), write('->'), printPath([W|Y]).

% printPath prints a set of paths in given format
printPaths(Cur, K, _):- Cur is K+1.
printPaths(Cur, K, [P|Paths]):- isLessThan(Cur, K),
                                write('Path '), write(Cur), write(':'),
                                printPath(P),
                                put(10),
                                Cur1 is Cur+1,
                                printPaths(Cur1, K, Paths).

isLessThan(K, K1):-  K=<K1.


vertexSameComp(U,V):-   U=V; findKDisjointPaths(U,V,2,_,_). 

edgeSameComp([W,X],[Y,Z]):- vertexSameComp(W,Y),
                            vertexSameComp(W,Z),
                            vertexSameComp(X,Y),
                            vertexSameComp(X,Z).

findAllEdgeSameComp(_,[],[]).
findAllEdgeSameComp(X,[Y|RemEdges], NewComp):- findAllEdgeSameComp(X, RemEdges, Comp), 
                                                (edgeSameComp(X,Y)-> NewComp = [Y|Comp]; NewComp = Comp).

findComponents([],[]).
findComponents([X| RemEdges], [[X|Comp]| Comps]):-  findAllEdgeSameComp(X,RemEdges, Comp),
                                                    subtract(RemEdges, Comp, NewRemEdges),
                                                    findComponents(NewRemEdges, Comps).

printbi():- findall([U,V], edge(U,V), Edges),
            findComponents(Edges, Comps),
            printComponents(1,Comps).

bicomp(K):- findall([U,V], edge(U,V), Edges),
            findComponents(Edges, Comps),
            length(Comps, K).

printEdges([[U,V]]):-   write(' ('), write(U), write(','), write(V), write(')').
printEdges([[U,V],W|Y]):-   write(' ('), write(U), write(','), write(V), write('),'),
                            printEdges([W|Y]).

printComponents(_,[]).
printComponents(Cur, [Comp|Comps]):-    write('Component '), write(Cur), write(':'),
                                        printEdges(Comp),
                                        put(10),
                                        Cur1 is Cur+1,
                                        printComponents(Cur1, Comps).
        