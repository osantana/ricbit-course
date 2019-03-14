% This file is part of the Stanford GraphBase (c) Stanford University 1993
@i boilerplate.w %<< legal stuff: PLEASE READ IT BEFORE MAKING ANY CHANGES!

\def\title{GB\_\,FLIP}
\hyphenation{semi-numer-ical}

@* Introduction. This is {\sc GB\_\,FLIP}, the module used by GraphBase
programs to generate random numbers.

To use the routines in this file, first call the function |gb_init_rand(seed)|.
Subsequent uses of the macro |gb_next_rand()| will then return pseudo-random
integers between 0 and $2^{31}-1$, inclusive.

GraphBase programs are designed to produce identical results on almost
all existing computers and operating systems.  An improved version of the
portable subtractive method recommended in {\sl Seminumerical Algorithms},
Section~3.6, is used to generate random numbers in the routines below.
The period length of the generated numbers is $2^{85}-2^{30}$.
The low-order bits of the
generated numbers are just as random as the high-order bits.

@ Changes might be needed when these routines are ported to different
systems, because the programs have been written to be most efficient
on binary computers that use two's complement notation. Almost all
modern computers are based on two's complement arithmetic, but if you have a
nonconformist machine you might have to revise the code in sections that
are listed under `system dependencies' in the index.

A validation program is provided so that installers can tell if
{\sc GB\_\,FLIP} is working properly. To make the test, simply run
\.{test\_flip}.

@(test_flip.c@>=
#include <stdio.h>
#include "gb_flip.h"   /* all users of {\sc GB\_\,FLIP} should do this */
@#@;
int main()
{@+long j;
  gb_init_rand(-314159L);
  if (gb_next_rand()!=119318998) {
     fprintf(stderr,"Failure on the first try!\n"); return -1;
  }
  for (j=1; j<=133; j++)
    gb_next_rand();
  if (gb_unif_rand(0x55555555L)!=748103812) {
     fprintf(stderr,"Failure on the second try!\n"); return -2;
  }
  fprintf(stderr,"OK, the gb_flip routines seem to work!\n");
  return 0;
}

@ The \CEE/ code for {\sc GB\_\,FLIP} doesn't have a main routine; it's just a
bunch of subroutines to be incorporated into programs at a higher level
via the system loading routine. Here is the general outline of \.{gb\_flip.c}:

@p
@<Private declarations@>@;
@<External declarations@>@;
@<External functions@>

@* The subtractive method. If $m$ is any even number and if the
numbers $a_0$, $a_1$, \dots,~$a_{54}$ are not all even, then the numbers
generated by the recurrence
$$ a_n=(a_{n-55}-a_{n-24})\bmod m $$
have a period length of at least $2^{55}-1$, because the residues
$a_n\bmod2$ have a period of this length. Furthermore, the numbers 24 and~55
in this recurrence are sufficiently large that deficiencies in randomness
due to the simplicity of the recurrence are negligible in most applications.

Here we take $m=2^{31}$ so that we get the full set of nonnegative numbers
on a 32-bit computer. The recurrence is computed by maintaining an array
of 55 values, $A[1]\ldots A[55]$. We also set |A[0]=-1| to act as a sentinel.

@<Private...@>=
static long A[56] = {-1}; /* pseudo-random values */

@ Every external variable should be declared twice in this \.{CWEB}
file: once for {\sc GB\_\,FLIP} itself (the ``real'' declaration for
storage allocation purposes), and once in \.{gb\_flip.h} (for
cross-references by {\sc GB\_\,FLIP} users).

The pointer variable |gb_fptr| should not be mentioned explicitly
by user routines. It is made public only for efficiency, so that the
|gb_next_rand| macro can access the private |A| table.

@<External declarations@>=
long *gb_fptr=A; /* the next |A| value to be exported */

@ The numbers generated by |gb_next_rand()| seem to be satisfactory for most
purposes, but they do fail a stringent test called the ``birthday spacings
test,'' devised by George Marsaglia. [See, for example, {\sl Statistics and
Probability Letters\/ \bf9} (1990), 35--39.] One way to get numbers that
pass the birthday test is to discard half of the values, for example
by changing `|gb_flip_cycle()|' to `|(gb_flip_cycle(),gb_flip_cycle())|'
in the definition of |gb_next_rand()|. Users who wish to make such a change
should define their own substitute macro.

Incidentally, we hope that optimizing compilers are smart enough to
do the right thing with |gb_next_rand|.

@d gb_next_rand() (*gb_fptr>=0? *gb_fptr--: gb_flip_cycle())

@(gb_flip.h@>=
#define gb_next_rand() @t\quad@>(*gb_fptr>=0?*gb_fptr--:gb_flip_cycle())
extern long *gb_fptr; /* the next |A| value to be used */
extern long gb_flip_cycle(); /* compute 55 more pseudo-random numbers */

@ The user is not supposed to call |gb_flip_cycle| directly either.
It is a routine invoked by the macro |gb_next_rand()| when |gb_fptr|
points to the negative value in |A[0]|.

The purpose of |gb_flip_cycle| is to do 55 more steps of the basic
recurrence, at high speed, and to reset |gb_fptr|.

The nonnegative remainder of $(x-y)$ divided by $2^{31}$ is computed here by
doing a bitwise-and with the constant |0x7fffffff|. This technique
doesn't work on computers that do not perform two's complement
arithmetic. An alternative for such machines is to add the value
$2^{30}$ twice to $(x-y)$, when $(x-y)$ turns out to be negative.
Careful calculations are essential because the GraphBase results
must be identical on all computer systems.
@^system dependencies@>

The sequence of random numbers returned by successive calls of |gb_next_rand()|
isn't really $a_n$, $a_{n+1}$, \dots, as defined by the basic recurrence above.
Blocks of 55 consecutive values are essentially being ``flipped'' or
``reflected''---output in reverse order---because |gb_next_rand()|
makes the value of |gb_fptr| decrease instead of increase.
But such flips don't make the results any less random.

@d mod_diff(x,y) (((x)-(y))&0x7fffffff) /* difference modulo $2^{31}$ */

@<External functions@>=
long gb_flip_cycle()
{@+register long *ii, *jj;
  for (ii=&A[1],jj=&A[32];jj<=&A[55];ii++,jj++)
    *ii=mod_diff(*ii,*jj);
  for (jj=&A[1];ii<=&A[55];ii++,jj++)
    *ii=mod_diff(*ii,*jj);
  gb_fptr=&A[54];
  return A[55];
}
  
@* Initialization. To get everything going, we use a scheme like that
recommended in {\sl Seminumerical Algorithms}, but revised so that the
least significant bits of the starting values depend on the entire
seed, not just on the seed's least significant bits.

Notice that we jump around in the array by increments of 21, a number that is
relatively prime to~55. Repeated skipping by steps of 21~mod~55 keeps the
values we're computing spread out as far from each other as possible in the
array, since 21, 34, and 55 are consecutive
Fibonacci numbers (see the discussion of Fibonacci hashing in
Section 6.4 of {\sl Sorting and Searching\/}). Our initialization mechanism
would be rather poor if we didn't do something like that to disperse the values
(see {\sl Seminumerical Algorithms}, exercise 3.2.2--2).

@<External f...@>=
void gb_init_rand(seed)
    long seed;
{@+register long i;
  register long prev=seed, next=1;
  seed=prev=mod_diff(prev,0); /* strip off the sign */
  A[55]=prev;
  for (i=21; i; i=(i+21)%55) {
    A[i]=next;
    @<Compute a new |next| value, based on |next|, |prev|, and |seed|@>;
    prev=A[i];
  }
  @<Get the array values ``warmed up''@>;
}

@ Incidentally, if \.{test\_flip} fails, the person debugging these
routines will want to know some of the intermediate numbers computed
during initialization.  The first nontrivial values calculated by
|gb_init_rand| are |A[42]=2147326568|, |A[8]=1073977445|, and
|A[29]=536517481|.  Once you get those right, the rest should be easy.

An early version of this routine simply said `|seed>>1|' instead of making
|seed| shift cyclically. This method had an interesting flaw:
When the original |seed| was a number of the form $4s+1$, the first
54 elements $A[1]$, \dots,~$A[54]$ were set to exactly the same values
as when |seed| was $4s+2$. Therefore one out of every four seed values
was effectively being wasted.

@<Compute a new |next|...@>=
next=mod_diff(prev,next);
if (seed&1) seed=0x40000000+(seed>>1);
else seed>>=1; /* cyclic shift right 1 */
next=mod_diff(next,seed);

@ After the first 55 values have been computed as a function of |seed|,
they aren't random enough for us to start using them right away. For example,
we have set |A[21]=1| in order to ensure that at least one starting value
is an odd number. But once the sequence $a_n$ gets going far enough from
its roots, the initial transients become imperceptible. Therefore we call
|gb_flip_cycle| five times, effectively skipping past the first 275
elements of the sequence; this has the desired effect. It also
initializes |gb_fptr|.

Note: It is possible to express the least significant bit of the
generated numbers as a linear combination mod~2 of the 31 bits of
|seed| and of the constant~1.  For example, the first generated number
turns out to be odd if and only if
$$s_{24}+s_{23}+s_{22}+s_{21}+s_{19}+s_{18}+s_{15}+s_{14}+s_{13}+s_{11}+
s_{10}+s_{8}+s_{7}+s_{6}+s_{2}+s_{1}+s_{0}$$ is odd, when
$|seed|=(s_{31}\ldots s_1s_0)_2$.  We can represent this linear
combination conveniently by the hexadecimal number |0x01ecedc7|; the
\.1 stands for $s_{24}$ and the final \.7 stands for $s_2+s_1+s_0$.
The first ten least-significant bits turn out to be respectively
|0x01ecedc7|, |0xdbbdc362|, |0x400e0b06|, |0x0eb73780|, |0xda0d66ae|,
|0x002b63bc|, |0xadb801ed|, |0x8077bbbc|, |0x803d9db5|, and
|0x401a0eda| in this notation (using the sign bit to indicate cases
when 1 must be added to the sum).

We must admit that these ten 32-bit patterns do not look at all
random; the number of \.b's, \.d's, and \.0's is unusually high. (Before
the ``warmup cycles,'' the patterns are even more regular.) This
phenomenon eventually disappears, however, as the sequence proceeds;
and it does not seem to imply any serious deficiency in practice, even
at the beginning of the sequence, once we've done the warmup exercises.

@<Get the array...@>=
(void) gb_flip_cycle();
(void) gb_flip_cycle();
(void) gb_flip_cycle();
(void) gb_flip_cycle();
(void) gb_flip_cycle();

@ @(gb_flip.h@>=
extern void gb_init_rand();

@* Uniform integers.
Here is a simple routine that produces a uniform integer between
0 and~$m-1$, inclusive, when $m$ is any positive integer less than $2^{31}$.
It avoids the bias toward small values that would occur if we simply
calculated |gb_next_rand()%m|. (The bias is insignificant when |m| is
small, but it can be serious when |m| is large. For example, if
$m\approx 2^{32}\!/3$, the simple remainder algorithm would give an answer
less than $m/2$ about 2/3 of the time.)

This routine consumes fewer than two random numbers, on the average,
for any fixed~$m$.

In the \.{test\_flip} program (|main|), this routine should compute |t=m|,
then it should reject the values |r=2081307921|, 1621414801, and
1469108743 before returning the answer 748103812.

@d two_to_the_31 ((unsigned long)0x80000000)

@<External f...@>=
long gb_unif_rand(m)
    long m;
{@+register unsigned long t=two_to_the_31-(two_to_the_31 % m);
  register long r;
  do@+{
    r=gb_next_rand();
  }@+while (t<=(unsigned long)r);
  return r%m;
}

@ @(gb_flip.h@>=
extern long gb_unif_rand();

@* Index. Here is a list that shows where the identifiers of this program are
defined and used.
