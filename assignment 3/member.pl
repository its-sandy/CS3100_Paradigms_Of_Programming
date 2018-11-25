mmember(X,[X|_]).
mmember(X,[Y|Z]) :- mmember(X,Z), Y\=X.