edge(1, 2).
edge(1, 4).
edge(1, 5).
edge(1, 7).
edge(2, 4).
edge(2, 5).
edge(2, 6).
edge(2, 7).
edge(3, 4).
edge(3, 5).
edge(3, 6).
edge(3, 7).
edge(4, 5).
edge(4, 6).
edge(4, 7).
edge(5, 6).
edge(6, 7).

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
findPath(U, V, Path, AlreadySeen):-   path(U, V, Path, [U|AlreadySeen]).

updateAlreadySeen(_, _, AlreadySeen, [], AlreadySeen).
updateAlreadySeen(U, V, AlreadySeen, [A|Path], NewAlreadySeen):-    (A=U; A=V),
                                                                    updateAlreadySeen(U, V, AlreadySeen, Path, NewAlreadySeen).
updateAlreadySeen(U, V, AlreadySeen, [A|Path], [A|NewAlreadySeen]):- (A\=U; A\=V),
                                                                     updateAlreadySeen(U, V, AlreadySeen, Path, NewAlreadySeen).
findKDisjointPaths(_, _, 0, _, [], []).

findKDisjointPaths(U, V, K, NewAlreadySeen, [Path|Paths]):-  not(isLessThan(K,0)),
                                                                            K1 is K-1,
                                                                            findKDisjointPaths(U, V, K1, AlreadySeen, Paths),
                                                                            findPath(U, V, Path, AlreadySeen),
                                                                            not(mmember(Path,Paths)),
                                                                            updateAlreadySeen(U,V,AlreadySeen,Path,NewAlreadySeen).

vertexConnectedness(_, [], _, _).
vertexConnectedness(U, [V|Vertices], K):-    findKDisjointPaths(U, V, K, _, _),!,
                                            vertexConnectedness(U, Vertices, K).

graphConnectedness([], _, _).
graphConnectedness([U|Vertices], K):- vertexConnectedness(U, Vertices, K),!,
                                      graphConnectedness(Vertices, K).

conn(K):-   getAllVertices(GraphVertices),
            graphConnectedness(GraphVertices, K).

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

% getUniqueElements finds the unique elements in a list
getUniqueElements([], []).

getUniqueElements([A|Old], [A|New]):-    getUniqueElements(Old, New), not(mmember(A, New)).

getUniqueElements([A|Old], New):-    getUniqueElements(Old, New), mmember(A, New).

isLessThan(K, K1):-  K=<K1.


nonSeparable(GraphVertices):-   graphConnectedness(GraphVertices, K1, GraphVertices),
                                isLessThan(2, K1).

nonSeparable([X,Y]):-   isedge(X, Y).

% vjoin(X,Y,Z):-  append(X,Y,Z).

allBiComponents(CurVertices, [], Components):- (nonSeparable(CurVertices) -> Components = [CurVertices]; Components = []).

allBiComponents(CurVertices, [U|RemVertices], Components):- allBiComponents(CurVertices, RemVertices, Components1),
                                                            allBiComponents([U|CurVertices], RemVertices, Components2),
                                                            append(Components1,Components2,Components).

isMaximal(_, []).

isMaximal(Comp1, [Comp2|Comps]):-   Comp1 \= Comp2,
                                    not(subset(Comp1, Comp2)),
                                    isMaximal(Comp1, Comps).

isMaximal(Comp1, [Comp2|Comps]):-   Comp1 = Comp2,
                                    isMaximal(Comp1, Comps).

maximalBiComponents([], _, []).

maximalBiComponents([Comp|GivenComps], AllComps, MaxComps):-    maximalBiComponents(GivenComps, AllComps, MaxComps1),
                                                                (isMaximal(Comp, AllComps) -> MaxComps = [Comp|MaxComps1]; MaxComps = MaxComps1).

getMaximalBiComponents(Components):-    getAllVertices(VSet),
                                        allBiComponents([], VSet, AllComps),
                                        maximalBiComponents(AllComps, AllComps, Components).

printEdges([[U,V]]):-   write(' ('), write(U), write(','), write(V), write(')').
printEdges([[U,V],W|Y]):-   write(' ('), write(U), write(','), write(V), write('),'),
                            printEdges([W|Y]).

printComponents(_,[]).
printComponents(Cur, [Comp|Comps]):-    findall([U,V], (mmember(U, Comp), mmember(V, Comp), edge(U, V)), Edges),
                                        write('Component '), write(Cur), write(':'),
                                        printEdges(Edges),
                                        put(10),
                                        Cur1 is Cur+1,
                                        printComponents(Cur1, Comps).

% printPaths(Cur, K, [P|Paths]):- isLessThan(Cur, K),
%                                 write('Path '), write(Cur), write(':'),
%                                 printPath(P),
%                                 put(10),
%                                 Cur1 is Cur+1,
%                                 printPaths(Cur1, K, Paths).

printbi():- getMaximalBiComponents(Comps),
            printComponents(1, Comps).

vertexSameComp(U,V):-   U=V; findKDisjointPaths(U,V,2,_,_). 

edgeSameComp([W,X],[Y,Z]):- vertexSameComp(W,Y),
                            vertexSameComp(W,Z),
                            vertexSameComp(X,Y),
                            vertexSameComp(X,Z).