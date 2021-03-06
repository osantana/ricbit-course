/*1:*/
#line 25 "test_sample.w"

#include "gb_graph.h" 
#include "gb_io.h" 
/*2:*/
#line 40 "test_sample.w"

#include "gb_basic.h" 
#include "gb_books.h" 
#include "gb_econ.h" 
#include "gb_games.h" 
#include "gb_gates.h" 
#include "gb_lisa.h" 
#include "gb_miles.h" 
#include "gb_plane.h" 
#include "gb_raman.h" 
#include "gb_rand.h" 
#include "gb_roget.h" 
#include "gb_save.h" 
#include "gb_words.h" 

/*:2*/
#line 28 "test_sample.w"


/*7:*/
#line 104 "test_sample.w"

static long dst[]= {0x20000000,0x10000000,0x10000000};


/*:7*//*12:*/
#line 154 "test_sample.w"

static long wt_vector[]= 
{100,-80589,50000,18935,-18935,18935,18935,18935,18935};

/*:12*/
#line 30 "test_sample.w"

/*13:*/
#line 164 "test_sample.w"

static void pr_vert();

static void pr_arc();
static void pr_util();
static void print_sample(g,n)
Graph*g;
int n;
{
printf("\n");
if(g==NULL){
printf("Ooops, we just ran into panic code %ld!\n",panic_code);
if(io_errors)
printf("(The I/O error code is 0x%lx)\n",(unsigned long)io_errors);
}else{
/*18:*/
#line 262 "test_sample.w"

printf("\"%s\"\n%ld vertices, %ld arcs, util_types %s",
g->id,g->n,g->m,g->util_types);
pr_util(g->uu,g->util_types[8],0,g->util_types);
pr_util(g->vv,g->util_types[9],0,g->util_types);
pr_util(g->ww,g->util_types[10],0,g->util_types);
pr_util(g->xx,g->util_types[11],0,g->util_types);
pr_util(g->yy,g->util_types[12],0,g->util_types);
pr_util(g->zz,g->util_types[13],0,g->util_types);
printf("\n");

/*:18*/
#line 179 "test_sample.w"
;
/*17:*/
#line 254 "test_sample.w"

printf("V%d: ",n);
if(n>=g->n||n<0)printf("index is out of range!\n");
else{
pr_vert(g->vertices+n,1,g->util_types);
printf("\n");
}

/*:17*/
#line 180 "test_sample.w"
;
gb_recycle(g);
}
}

/*:13*//*14:*/
#line 190 "test_sample.w"

static void pr_vert(v,l,s)
Vertex*v;
int l;
char*s;
{
if(v==NULL)printf("NULL");
else if(is_boolean(v))printf("ONE");
else{
printf("\"%s\"",v->name);
pr_util(v->u,s[0],l-1,s);
pr_util(v->v,s[1],l-1,s);
pr_util(v->w,s[2],l-1,s);
pr_util(v->x,s[3],l-1,s);
pr_util(v->y,s[4],l-1,s);
pr_util(v->z,s[5],l-1,s);
if(l> 0){register Arc*a;
for(a= v->arcs;a;a= a->next){
printf("\n   ");
pr_arc(a,1,s);
}
}
}
}

/*:14*//*15:*/
#line 215 "test_sample.w"

static void pr_arc(a,l,s)
Arc*a;
int l;
char*s;
{
printf("->");
pr_vert(a->tip,0,s);
if(l> 0){
printf(", %ld",a->len);
pr_util(a->a,s[6],l-1,s);
pr_util(a->b,s[7],l-1,s);
}
}

/*:15*//*16:*/
#line 230 "test_sample.w"

static void pr_util(u,c,l,s)
util u;
char c;
int l;
char*s;
{
switch(c){
case'I':printf("[%ld]",u.I);break;
case'S':printf("[\"%s\"]",u.S?u.S:"(null)");break;
case'A':if(l<0)break;
printf("[");
if(u.A==NULL)printf("NULL");
else pr_arc(u.A,l,s);
printf("]");
break;
case'V':if(l<0)break;
printf("[");
pr_vert(u.V,l,s);
printf("]");
default:break;
}
}

/*:16*/
#line 31 "test_sample.w"

int main()
{Graph*g,*gg;long i;Vertex*v;
printf("GraphBase samples generated by test_sample:\n");
/*6:*/
#line 93 "test_sample.w"

g= random_graph(3L,10L,1L,1L,0L,NULL,dst,1L,2L,1L);

gg= complement(g,1L,1L,0L);
v= gb_typed_alloc(1,Vertex,gg->data);
v->name= gb_save_string("Testing");
gg->util_types[10]= 'V';
gg->ww.V= v;
save_graph(gg,"test.gb");
gb_recycle(g);gb_recycle(gg);

/*:6*/
#line 35 "test_sample.w"
;
/*3:*/
#line 62 "test_sample.w"

print_sample(raman(31L,3L,0L,4L),4);

/*:3*//*4:*/
#line 77 "test_sample.w"

print_sample(board(1L,1L,2L,-33L,1L,-0x40000000L-0x40000000L,1L),2000);


/*:4*//*5:*/
#line 84 "test_sample.w"

print_sample(subsets(32L,18L,16L,0L,999L,-999L,0x80000000L,1L),1);

/*:5*//*8:*/
#line 111 "test_sample.w"

g= restore_graph("test.gb");
if(i= random_lengths(g,0L,10L,12L,dst,2L))
printf("\nFailure code %ld returned by random_lengths!\n",i);
else{
gg= random_graph(3L,10L,1L,1L,0L,NULL,dst,1L,2L,1L);
print_sample(gunion(g,gg,1L,0L),2);
gb_recycle(g);gb_recycle(gg);
}

/*:8*//*9:*/
#line 125 "test_sample.w"

print_sample(partial_gates(risc(0L),1L,43210L,98765L,NULL),79);

/*:9*//*10:*/
#line 132 "test_sample.w"

print_sample(book("homer",500L,400L,2L,12L,10000L,-123456L,789L),81);
print_sample(econ(40L,0L,400L,-111L),11);
print_sample(games(60L,70L,80L,-90L,-101L,60L,0L,999999999L),14);
print_sample(miles(50L,-500L,100L,1L,500L,5L,314159L),20);
print_sample(plane_lisa(100L,100L,50L,1L,300L,1L,200L,
50L*299L*199L,200L*299L*199L),1294);
print_sample(plane_miles(50L,500L,-100L,1L,1L,40000L,271818L),14);
print_sample(random_bigraph(300L,3L,1000L,-1L,0L,dst,-500L,500L,666L),3);
print_sample(roget(1000L,3L,1009L,1009L),40);

/*:10*//*11:*/
#line 148 "test_sample.w"

print_sample(words(100L,wt_vector,70000000L,69L),5);
wt_vector[1]++;
print_sample(words(100L,wt_vector,70000000L,69L),5);
print_sample(words(0L,NULL,0L,69L),5555);

/*:11*/
#line 36 "test_sample.w"
;
return 0;
}

/*:1*/
