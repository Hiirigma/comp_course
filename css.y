
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
%token CDC CDO CHARSET_SYM
%token <string> DASHMATCH
%token DIMENSION
%token EMS EXS
%token SP
%token DOUBLEPOINT
%token LOGAND
%token <string> STRING
%token <string> FREQ
%token FUNCTION
%token <string> HASH
%token <string> IDENT
%token <string> INCLUDES
%token IMPORT_SYM IMPORTANT_SYM
%token <string> LENGTH
%token MEDIA_SYM
%token NAMESPACE_SYM
%token <string> NUMBER
%token PAGE_SYM
%token <string> PERCENTAGE 
%token <string> TIME
%token <string> URI

%type <string> type_selector
%type <string> id_selector
%type <string> class_selector

%type <string> attrib_eq
%type <string> attrib_value

%type <string> term
%type <string> property
%type <string> expr

%%

stylesheet // : [ CHARSET_SYM STRING ';' ]?
           //   [S|CDO|CDC]* [ import [ CDO S* | CDC S* ]* ]*
           //   [ [ ruleset | media | page ] [ CDO S* | CDC S* ]* ]* ;
    : charset comments namespace_block import_block body
;

charset
    :
    | CHARSET_SYM STRING ';'
    {
       
    }
;

comments
    :
    | comments SP
    | comments CDO
    | comments CDC
;

import_block
    :
    | import subcomments
;

namespace_block
    :
    | namespace subcomments
;

body
    :
    | body ruleset subcomments
    | body media subcomments
    | body page subcomments
;

subcomments
    :
    | subcomments CDO 
    | subcomments CDC 
;

import // : IMPORT_SYM S* [STRING|URI] S* media_list? ';' S* ;
    : IMPORT_SYM  STRING  media_list ';' 
    | IMPORT_SYM  URI  media_list ';' 
    | IMPORT_SYM  STRING  ';' 
    | IMPORT_SYM  URI  ';' 
;
    
namespace // : NAMESPACE_SYM S* [STRING|URI] S* media_list? ';' S* ;
    : NAMESPACE_SYM prefix URI ';' 
    | NAMESPACE_SYM prefix STRING ';'  
    | NAMESPACE_SYM prefix BAD_URI ';'
;
    
prefix 
    : IDENT  {printf("perix here 2\n");}
;

media // : MEDIA_SYM S* media_list '{' S* ruleset* '}' S* ;
    : MEDIA_SYM  media_list '{'  rulesets '}' 
;

rulesets
    :
    | rulesets ruleset
;

media_list // : medium [ COMMA S* medium]* ;
    : medium
    | media_list LOGAND medium
    | media_list ',' medium
;



medium // : IDENT S* ;
    : IDENT
;

page // : PAGE_SYM S* pseudo_page?
     //   '{' S* declaration? [ ';' S* declaration? ]* '}' S* ;
    : PAGE_SYM  pseudo_page '{' page_declarations '}' 
    | PAGE_SYM  '{' page_declarations '}' 
;

page_declarations
    :  declaration
    | 
    | page_declarations ';'  declaration
    | page_declarations ';' 
;

pseudo_page // : ':' IDENT S* ;
    : ':' IDENT 
;

operator // : '/' S* | ',' S* ;
    : '/' 
    | ',' 
;

combinator // : '+' S* | '>' S* ;
    : '+' 
    {

    }
    | '>' 
    {
        
    }
;

unary_operator // : '-' | '+' ;
    : '-'
    | '+'
;

property // : IDENT S* ;
    : IDENT 
    {
        $$ = $1;
        printf ("property -  %s\n",$1);
    }
;

ruleset // : selector [ ',' S* selector ]* '{' S* declaration? [ ';' S* declaration? ]* '}' S* ;
    : selector_list '{'  declarations '}' 
    | selector_list '{'  '}' 
;

selector_list
    : complex_selector
    | universal_selector
    | selector_list ','  complex_selector
    | selector_list ','  universal_selector
;

complex_selector // : simple_selector [ combinator selector | S+ [ combinator? selector ]? ]? ;
    : compound_selector
    | complex_selector combinator compound_selector
    | complex_selector  compound_selector 
    | complex_selector 
        /* for space symbols skipping */
;

universal_selector
    :
    | '*'
;

compound_selector // : element_name [ HASH | class | attrib | pseudo ]* | [ HASH | class | attrib | pseudo ]+ ;
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
    | pseudo_element
;

id_selector
    : HASH
    { }
;

class_selector // : '.' IDENT ;
    : '.' IDENT
    { }
;

type_selector // : IDENT | '*' ;
    : IDENT
    {  }
;

attribute_selector // : '[' S* IDENT S* [ [ '=' | INCLUDES | DASHMATCH ] S* [ IDENT | STRING ] S* ]? ']';
    : '['  IDENT  ']'
    {  }
    | '['  IDENT  attrib_eq  attrib_value  ']'
    {  }
;

attrib_eq
    : '='
    {   $$ = "=";    }
    | INCLUDES
    {   $$ = $1;    }
    | DASHMATCH
    {   $$ = $1;    }
;

attrib_value
    : IDENT
    {   $$ = $1;    }
    | STRING
    {   $$ = $1;    }
;

// add pseudo_element in the parser
pseudo_element 
    : DOUBLEPOINT pseudo_block
;


pseudo_class_selector // : ':' [ IDENT | FUNCTION S* [IDENT S*]? ')' ] ;
    : ':' pseudo_block
;

pseudo_block
    : IDENT
    | FUNCTION  pseudo_block_function_ident ')'
;

pseudo_block_function_ident
    :
    | IDENT 
;

declarations
    : declaration
    | declarations ';' declaration
    | declarations ';' 
;

declaration // : property ':' S* expr prio? ;
    : property ':' expr prio
    | property ':' expr
    
;

prio // : IMPORTANT_SYM S* ;
    : IMPORTANT_SYM 
;

expr //: term [ operator? term ]*;
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
    : unary_operator term_numeral 
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
    | PERCENTAGE
    | LENGTH
    | EMS
    | EXS
    | ANGLE
    | TIME
    | FREQ
;      

function // : FUNCTION S* expr ')' S* ;
    :  FUNCTION  expr ')' 
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

