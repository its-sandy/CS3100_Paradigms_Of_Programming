factorial(0,1).
factorial(N,M) :- N>0,
				 S is N-1,
				 factorial(S,X),
				 M is N*X.