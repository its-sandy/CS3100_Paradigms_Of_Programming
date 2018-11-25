edge(1,2).
edge(2,3).
edge(4,3).
edge(1,3).
edge(4,5).
edge(1,5).
edge(3,5).
% edge(6,7).

mmember(X,[X|_]).
mmember(X,[Y|Z]) :- mmember(X,Z), Y\=X.

isedge(U,V) :- edge(U,V); edge(V,U).

% path(U,U,[U]).
% path(U,V,[U|Visited]):- isedge(U,A),
%                         path(A,V,Visited),
%                         not(mmember(U,Visited)).

path(U,V,[U,V],AlreadySeen):-   isedge(U,V),
                                not(mmember(V,AlreadySeen)).

path(U,V,[U|Path],AlreadySeen):-    isedge(U,A),
                                    not(mmember(A,AlreadySeen)),
                                    path(A,V,Path,[A|AlreadySeen]).

findPath(U,V,Path) :- path(U,V,Path,[U]).

disjointPaths([],_,_,_).

disjointPaths([A|P1],P2,U,V):- (A=U; A=V),
                                disjointPaths(P1,P2,U,V).

disjointPaths([A|P1],P2,U,V):- (A\=U; A\=V),
                                disjointPaths(P1,P2,U,V),
                                not(mmember(A,P2)).

disjointPathAndPathSet(_,[],_,_).

disjointPathAndPathSet(P1,[P2|X],U,V):- disjointPaths(P1,P2,U,V),
                                        disjointPathAndPathSet(P1,X,U,V).    

% maxDisjointPathsSet([],CurPaths,_,_,Count):-  length(CurPaths, Count).

% maxDisjointPathsSet([P1|RemPaths],CurPaths,U,V,Count):-    (disjointPathAndPathSet(P1,CurPaths,U,V) -> maxDisjointPathsSet(RemPaths,[P1|CurPaths],U,V,C1); C1 is 0),
%                                                             maxDisjointPathsSet(RemPaths,CurPaths,U,V,C2),
%                                                             Count is max(C1,C2).

maxDisjointPathsSet([],CurPaths,_,_,Count,MaxSet):-  length(CurPaths, Count), MaxSet = CurPaths.

maxDisjointPathsSet([P1|RemPaths],CurPaths,U,V,Count,MaxSet):-  (disjointPathAndPathSet(P1,CurPaths,U,V) -> maxDisjointPathsSet(RemPaths,[P1|CurPaths],U,V,C1,MaxSet1); C1 is 0),
                                                                maxDisjointPathsSet(RemPaths,CurPaths,U,V,C2,MaxSet2),
                                                                (isLessThan(C1,C2) -> MaxSet = MaxSet2, Count = C2; MaxSet = MaxSet1, Count = C1).

uvConnectedness(U,V,K,MaxSet):- findall(Path, findPath(U,V,Path), PathSet),
                                maxDisjointPathsSet(PathSet,[],U,V,K,MaxSet).    

getUniqueElements([],[]).

getUniqueElements([A|Old],[A|New]):-    getUniqueElements(Old,New), not(mmember(A,New)).

getUniqueElements([A|Old],New):-    getUniqueElements(Old,New), mmember(A,New).

vertexConnectedness(_,[],K):-   K is 1000000.

vertexConnectedness(U,[V|Vertices],K):- uvConnectedness(U,V,K1,_),
                                        vertexConnectedness(U,Vertices,K2),
                                        K is min(K1,K2).

graphConnectedness([_],K):- K is 1000000.

graphConnectedness([U|VertexSet],K):-   graphConnectedness(VertexSet,K1),
                                        vertexConnectedness(U,VertexSet,K2),
                                        K is min(K1,K2).
isLessThan(K,K1):-  K=<K1.

conn(K):-   findall(X,(edge(X,_);edge(_,X)),VList),
            getUniqueElements(VList,VSet),
            graphConnectedness(VSet,K1),
            isLessThan(K,K1).

biconn:- conn(2).

printPath([V]):-    write(' '), write(V).
printPath([V,W|Y]):-write(' '), write(V), write(' '), write('->'), printPath([W|Y]).

printPaths(Cur,K,[P|Paths]):-   isLessThan(Cur,K),
                                write('Path '), write(Cur), write(':'),
                                printPath(P),
                                put(10),
                                Cur1 is Cur+1,
                                printPaths(Cur1,K,Paths).
% printPaths(Cur,K,_):-   Cur == K+1, put(10).

mpath(U,V,K):-  uvConnectedness(U,V,K1,MaxSet),
                isLessThan(K,K1),
                printPaths(1,K,MaxSet).