
%{
#include <stdio.h>
int yylineno;
int yyerror(const char *s)
{
	fprintf (stderr,"%s, line %d\n", s, yylineno);
}

%}

%start stylesheet

%union{
    char* string;
}

%token <string> ANGLE
%token <string> BAD_STRING
%token <string> BAD_URI
%token CDC CDO
%token <string> DASHMATCH
%token DIMENSION
%token <string> CONTAINED
%token EMS EXS
%token DOUBLEPOINT
%token LOGAND
%token NOTONLY
%token INHERIT
%token TO
%token FROM
%token <string> STRING
%token <string> FREQ
%token FUNCTION
%token <string> HASH
%token <string> IDENT
%token <string> UPIDENT
%token <string> INCLUDES
%token IMPORTANT_SYM
%token <string> LENGTH
%token MULTI_CLASS
%token SYM
%token <string> NUMBER
%token <string> PERCENTAGE 
%token <string> TIME
%token <string> URI
%token VAR
%token CALC

%type <string> type_selector
%type <string> id_selector
%type <string> class_selector

%type <string> attrib_eq
%type <string> attrib_value

%type <string> term
%type <string> property
%type <string> expr

%%

stylesheet
    : 
    | comments sym_block body stylesheet
;

comments
    :
    | comments CDO
    | comments CDC
;


sym_block
    :
    | sym comments
;

sym
    : SYM '{' declarations '}'
    | SYM notonly sub_sym_namespace
    | SYM sub_sym_namespace
    | SYM IDENT ',' media_declar '{' body '}' 
    | SYM STRING  media_list ';' 
    | SYM URI  media_list ';' 
    | SYM STRING ';' 
    | SYM URI  ';' 
    | SYM pseudo_page '{' page_declarations '}' 
    | SYM '{' page_declarations '}' 
;

sub_sym_namespace
    : media_list URI ';'
    | media_list STRING ';'
    | media_list BAD_URI ';'
    | media_list '{' keyframe_ruleset '}' 
    ;



keyframe_ruleset
    : 
    | FROM '{' declarations '}' keyframe_ruleset
    | TO '{' declarations '}' keyframe_ruleset
    | percent keyframe_ruleset
    | ruleset keyframe_ruleset
;

percent
    :  
    | PERCENTAGE many_percent '{' declarations '}' percent
    | FROM many_percent '{' declarations '}' percent
;


many_percent
    :
    | ',' PERCENTAGE many_percent
    | ',' TO many_percent
    | ',' FROM many_percent
;

body
    :
    | body ruleset comments
    | body sym comments
;

notonly
    :
    | NOTONLY
;

rulesets
    :
    | rulesets ruleset
;

media_list // : medium [ COMMA S* medium]* ;
    : medium
    | media_list ',' medium
    | media_list LOGAND media_declar
    | media_declar ',' medium
    | attribute_selector
;

media_declar
    : '(' declarations ')'
    | media_declar ','  '(' declarations ')'

medium // : IDENT S* ;
    : IDENT
;


page_declarations
    :  declaration
    | page_declarations ';'  declaration
    | page_declarations ';' 
;

pseudo_page // : ':' IDENT S* ;
    : ':' IDENT
;

operator // : '/' S* | ',' S* ;
    : '/' 
    | ',' 
    | '='
;

combinator // : '+' S* | '>' S* ;
    : '+' 
    {

    }
    | '>' 
    {
        
    }
    | '~' 
    {
        
    }
;

unary_operator // : '-' | '+' ;
    : '-'
    | '+'
    | '/'
    | '*'
;


ruleset
    : selector_list '{' declarations '}' 
    | selector_list '{'  '}' 
;

selector_list
    : complex_selector
    | universal_selector
    | selector_list ','  complex_selector
    | selector_list ','  universal_selector
;

complex_selector
    : compound_selector 
    | inherit_selector
    | complex_selector combinator compound_selector
    | complex_selector combinator complex_selector
    | complex_selector combinator '*'
    | complex_selector '*'
    | complex_selector complex_selector 
;

inherit_selector
    : 
    | compound_selector INHERIT compound_selector ')'
    | INHERIT compound_selector ')' inherit_selector
;

universal_selector
    :
    | '*'
;

compound_selector
    : '*' type_selector
    | type_selector 
    | '*' simple_selector
    | simple_selector
    | compound_selector simple_selector
;

simple_selector
    : attribute_selector
    | class_selector
    | id_selector
    | pseudo_class_selector
;

id_selector
    : HASH
;

class_selector // : '.' IDENT ;
    : MULTI_CLASS
;

type_selector
    : IDENT
;


attribute_selector // : '[' S* IDENT S* [ [ '=' | INCLUDES | DASHMATCH ] S* [ IDENT | STRING ] S* ]? ']';
    : '['  IDENT  ']'
    | '['  IDENT  attrib_eq  attrib_value  ']'
;

attrib_eq
    : '='
    {   $$ = "=";    }
    | INCLUDES
    {   $$ = $1;    }
    | DASHMATCH
    {   $$ = $1;    }
    | CONTAINED
    {   $$ = $1;    }
;

attrib_value
    : IDENT
    {   $$ = $1;    }
    | STRING
    {   $$ = $1;    }
;

pseudo_class_selector // : ':' [ IDENT | FUNCTION S* [IDENT S*]? ')' ] ;
    : ':' pseudo_block
    | ':' function
    | DOUBLEPOINT pseudo_block
;

pseudo_block
    : IDENT
    | FUNCTION pseudo_block_function_ident ')'
;
//.list-item:nth-child(2n-1)


pseudo_block_function_ident
    :
    | IDENT 
;

property
    : IDENT 
    {
        $$ = $1;
    }
    | '-' IDENT
    {
        $$ = '-' + $2;
    }
    | '_' IDENT
    {
        $$ = '_' + $2;
    }
    | '*' IDENT
    {
        $$ = '*' + $2;
    }
;

declarations
    : 
    | declaration
    | declarations ';' declaration
    | declarations ';'
;

declaration
    : property  ':' expr prio
    | property ':' expr
    | property ':' CALC expre ')'
;


expre
    : term_numeral
    | expre '+' expre
    | expre '-' expre
    | expre '*' expre
    | expre '/' expre
    | expre '^' expre
    | '(' expre ')'
;

prio 
    : IMPORTANT_SYM 
;

expr
    : term
    {
        $$ = $1;
    }
    | expr operator term 
    | expr term
;

term // : unary_operator?
     // [ NUMBER S* | PERCENTAGE S* | LENGTH S* | EMS S* | EXS S* | ANGLE S* | TIME S* | FREQ S* ]
     // | STRING S* | IDENT S* | URI S* | hexcolor | function ;
    : TO term
    | unary_operator term_numeral 
    | term_numeral 
    | STRING 
    {
        $$ = $1;
    }
    | IDENT 
    {
        $$ = $1;
    }
    | URI 
    {
        $$ = $1;
    }
    | hexcolor
    | function
;

term_numeral
    : NUMBER
    | VAR
    | PERCENTAGE
    | LENGTH
    | EMS
    | EXS
    | ANGLE
    | TIME
    | FREQ
    | DIMENSION
;      

function // : FUNCTION S* expr ')' S* ;
    :  FUNCTION expr ')'
;

hexcolor // : HASH S* ;
    : HASH 
;


%%

main(int argc, char** argv)
{
    const char* usage = "usage: %s [infile [outfile]]\n";
    char* outfile;
    char* infile;
    extern FILE *yyin, *yyout;
    
    char* progname = argv[0];
    
    if(argc > 3)
    {
        fprintf(stderr, usage, progname);
        return 0;
    }
    
    if(argc > 1)
    {
        infile = argv[1];
        yyin = fopen(infile, "r");
        
        if(yyin == NULL)
        {
            fprintf(stderr, "%s: cannot open %s\n", progname, infile);
            return 1;
        }
    }
    
    
    if (!yyparse())
    {
        printf ("File is ok\n");
    }
    else
    {
         printf ("File isn't ok\n");
    }
    
    return 0;
}

