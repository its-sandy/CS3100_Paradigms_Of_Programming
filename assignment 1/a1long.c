#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#define ll long int


#define forl(i, n) for (i = 0; i < n; i++)
#define fore(i, n) for (i = 1; i <= n; i++)

#define LEFT_PARAN (INT_MAX)
#define RIGHT_PARAN (INT_MAX - 1)
#define PLUS (INT_MAX - 2)
#define MINUS (INT_MAX - 3)
#define STAR (INT_MAX - 4)
#define A_MAT (INT_MAX - 5)
#define B_MAT (INT_MAX - 6)
#define UPLUS (INT_MAX - 7)
#define UMINUS (INT_MAX - 8)
#define EOI (INT_MAX - 9)

ll n, prevop, inptr;
ll *Aptr, *Bptr;
ll* values[200];
ll ops[200];
ll values_top, ops_top;
char expression[200];

void printmat(ll *a)
{
	ll i,j;
	forl(i,n)
	{
		forl(j,n)
		printf("%ld ", a[i*n+j]);
		printf("\n");
	}
}

ll* getscalar(ll x)
{
	ll* c = (ll*)malloc(sizeof(ll) * n*n);
	ll i;
	memset(c, 0, sizeof(ll)*n*n);

	forl(i,n)
		c[i*n + i] = x;

	return c;
}

ll* matmul(ll* a, ll* b)
{
	ll* c = (ll*)malloc(sizeof(ll) * n*n);
	ll i,j,k;

	forl(i,n)
	forl(j,n)
	{
		c[i*n + j] = 0;
		forl(k,n)
		c[i*n+j] += (a[i*n+k] * b[k*n+j]);
	}

	if(a != Aptr && a != Bptr)
		free(a);
	if(b != Aptr && b != Bptr)
		free(b);
	return c;
}

ll* matadd(ll* a, ll* b, ll as)	//as = 1 for add, -1 for sub
{
	ll i,j;

	forl(i,n)
	forl(j,n)
		a[i*n + j] = a[i*n + j] + as*b[i*n + j];

	if(b != Aptr && b != Bptr)
		free(b);
	return a;
}

ll* unarymatadd(ll *b, ll as)
{
	ll *a = getscalar(0);
	return matadd(a,b,as);
}

ll readinput()
{
	ll t, inp;

	if(expression[inptr] == '(')
	{
		prevop = 1;
		inp = LEFT_PARAN;
	}
	else if(expression[inptr] == ')')
	{
		prevop = 0;
		inp = RIGHT_PARAN;
	}
	else if(expression[inptr] == '+')
	{
		t = prevop;
		prevop = 1;
		if(t == 0)
			inp = PLUS;
		else
			inp = UPLUS;
	}
	else if(expression[inptr] == '-')
	{
		t = prevop;
		prevop = 1;
		if(t == 0)
			inp = MINUS;
		else
			inp = UMINUS;
	}
	else if(expression[inptr] == '*')
	{
		prevop = 1;
		inp = STAR;
	}
	else if(expression[inptr] == 'A')
	{
		prevop = 0;
		inp = A_MAT;
	}
	else if(expression[inptr] == 'B')
	{
		prevop = 0;
		inp = B_MAT;
	}
	else if(48<=expression[inptr] && expression[inptr]<=57)
	{
		prevop = 0;
		ll x = expression[inptr]-48;
		while(48<=expression[inptr+1] && expression[inptr+1]<=57)
		{
			x = (x*10) + expression[inptr+1]-48;
			inptr++;
		}
		inp = x;
	}
	else 
		inp = EOI;

	inptr++;
	return inp;
}

ll precedence(ll op)
{
	if(op == UPLUS || op == UMINUS)
		return 3;
	else if(op == STAR)
		return 2;
	else if(op == PLUS || op == MINUS)
		return 1;
	else
		return 0;
}

void initialise()
{
	ll i,j,x;
	scanf("%ld",&n);
	Aptr = (ll*)malloc(sizeof(ll) * n*n);
	Bptr = (ll*)malloc(sizeof(ll) * n*n);

	forl(i,n)
	forl(j,n)
	scanf("%ld", &Aptr[i*n + j]);

	forl(i,n)
	forl(j,n)
	scanf("%ld", &Bptr[i*n + j]);

	prevop = 1;
	ops_top = values_top = 0;

	scanf("%s", expression);
	inptr = 0;
}

void applyop()
{
	if(ops[ops_top] == UPLUS)
		values[values_top] = unarymatadd(values[values_top], 1);
	else if(ops[ops_top] == UMINUS)
		values[values_top] = unarymatadd(values[values_top], -1);
	else if(ops[ops_top] == PLUS)
	{
		values[values_top-1] = matadd(values[values_top-1],values[values_top],1);
		values_top--;
	}
	else if(ops[ops_top] == MINUS)
	{
		values[values_top-1] = matadd(values[values_top-1],values[values_top],-1);
		values_top--;
	}
	else if(ops[ops_top] == STAR)
	{
		values[values_top-1] = matmul(values[values_top-1],values[values_top]);
		values_top--;
	}

	ops_top--;
}

void evaluate()
{
	ll inp;

	inp = readinput();
	while(inp != EOI)
	{
		if(inp == LEFT_PARAN)
		{
			ops_top++;
			ops[ops_top] = LEFT_PARAN;
		}
		else if(inp == RIGHT_PARAN)
		{
			while(ops_top != 0 && ops[ops_top] != LEFT_PARAN)
				applyop();
			ops_top--;
		}
		else if(inp == UPLUS || inp == UMINUS || inp == PLUS || inp == MINUS || inp == STAR)
		{
			while(ops_top != 0 && precedence(ops[ops_top]) >= precedence(inp))
				applyop();
			ops_top++;
			ops[ops_top] = inp;
		}
		else if(inp == A_MAT)
		{
			values_top++;
			values[values_top] = Aptr;
		}
		else if(inp == B_MAT)
		{
			values_top++;
			values[values_top] = Bptr;
		}
		else
		{
			values_top++;
			values[values_top] = getscalar(inp);
		}

		inp = readinput();
	}

	while(ops_top != 0)
		applyop();
}

// see if matrix has to be converted to ll
// unary operator ... update prevop
// should spaces be handled?
// handle eof or put whole input in character array

int main()
{
	initialise();
	evaluate();
	printmat(values[1]);    
    
    return 0;
}