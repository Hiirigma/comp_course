%{
#include "css.tab.h"
%}

%option case-insensitive
%option yylineno
%option noyywrap

h              [0-9a-f]
nonascii       [\240-\377]
unicode        \\{h}{1,6}(\r\n|[ \t\r\n\f])?
escape         {unicode}|\\[^\r\n\f0-9a-f]
nmstart        [_a-z]|{nonascii}|{escape}
nmchar         [_a-zA-Z0-9-]|{nonascii}|{escape}
string1        \"([^\n\r\f\\"]|\\{nl}|{escape})*\"
string2        \'([^\n\r\f\\']|\\{nl}|{escape})*\'
badstring1     \"([^\n\r\f\\"]|\\{nl}|{escape})*\\?
badstring2     \'([^\n\r\f\\']|\\{nl}|{escape})*\\?
badcomment1    \/\*[^*]*\*+([^/*][^*]*\*+)*
badcomment2    \/\*[^*]*(\*+[^/*][^*]*)*
baduri1        url\({w}([!#$%&*-\[\]-~]|{nonascii}|{escape})*{w}
baduri2        url\({w}{string}{w}
baduri3        url\({w}{badstring}
comment        \/\*[^*]*\*+([^/*][^*]*\*+)*\/
ident          -*{nmstart}{nmchar}*
name           {nmchar}+
num            [0-9]+|[0-9]*"."[0-9]+
string         {string1}|{string2}
badstring      {badstring1}|{badstring2}
badcomment     {badcomment1}|{badcomment2}
baduri         {baduri1}|{baduri2}|{baduri3}
url	           ([!#$%&*-~]|{nonascii}|{escape})*
s              [ \t\r\n\f]*
w              [{s}]?
nl             \n|\r\n|\r|\f
ntonly         "not"|"only"
logand         (and)*
inherit        (:not\()*
identsk         (:{ident}())*


A		a|\\0{0,4}(41|61)(\r\n|[ \t\r\n\f])?
B		b|\\0{0,4}(42|62)(\r\n|[ \t\r\n\f])?
C		c|\\0{0,4}(43|63)(\r\n|[ \t\r\n\f])?
D		d|\\0{0,4}(44|64)(\r\n|[ \t\r\n\f])?
E		e|\\0{0,4}(45|65)(\r\n|[ \t\r\n\f])?
G		g|\\0{0,4}(47|67)(\r\n|[ \t\r\n\f])?|\\g
H		h|\\0{0,4}(48|68)(\r\n|[ \t\r\n\f])?|\\h
I		i|\\0{0,4}(49|69)(\r\n|[ \t\r\n\f])?|\\i
F		f|\\0{0,4}(46|66)(\r\n|[ \t\r\n\f])?|\\f
K		k|\\0{0,4}(4b|6b)(\r\n|[ \t\r\n\f])?|\\k
L   l|\\0{0,4}(4c|6c)(\r\n|[ \t\r\n\f])?|\\l
M		m|\\0{0,4}(4d|6d)(\r\n|[ \t\r\n\f])?|\\m
N		n|\\0{0,4}(4e|6e)(\r\n|[ \t\r\n\f])?|\\n
O		o|\\0{0,4}(4f|6f)(\r\n|[ \t\r\n\f])?|\\o
P		p|\\0{0,4}(50|70)(\r\n|[ \t\r\n\f])?|\\p
R		r|\\0{0,4}(52|72)(\r\n|[ \t\r\n\f])?|\\r
S		s|\\0{0,4}(53|73)(\r\n|[ \t\r\n\f])?|\\s
T		t|\\0{0,4}(54|74)(\r\n|[ \t\r\n\f])?|\\t
U   u|\\0{0,4}(55|75)(\r\n|[ \t\r\n\f])?|\\u
Y   y|\\0{0,4}(59|79)(\r\n|[ \t\r\n\f])?|\\y
X		x|\\0{0,4}(58|78)(\r\n|[ \t\r\n\f])?|\\x
Z		z|\\0{0,4}(5a|7a)(\r\n|[ \t\r\n\f])?|\\z
W		w|\\0{0,4}(57|77)(\r\n|[ \t\r\n\f])?|\\w

%%

{s} {}

\/\*[^*]*\*+([^/*][^*]*\*+)*\/       /* ignore comments */
{badcomment}                         /* unclosed comment at EOF */

"<!--"                  {return CDO;}
"-->"                   {return CDC;}
"~="                    {return INCLUDES;}
"|="                    {return DASHMATCH;}
"*="                    {return CONTAINED;}
"::"                    {return DOUBLEPOINT;}
{ntonly}         {return NOTONLY;}
"and"{s}            {return LOGAND;}
":not("             {return INHERIT;}

"."{ident}           {return MULTI_CLASS;}
"to"{s}               {return TO;}
"from"{s}          {return FROM;}
"calc("               {return CALC;}
"var("{ident}")"        {return VAR;}
{string}               { yylval.string = strdup(yytext);
                          return STRING;
                        }
                        
{badstring}             {return BAD_STRING;}

{ident}	                { yylval.string = strdup(yytext);
                          return IDENT;}

"#"{name}               { yylval.string = strdup(yytext);
                          return HASH;}

@{ident} {return SYM;}


"!"({w}|{comment})*{I}{M}{P}{O}{R}{T}{A}{N}{T}          {return IMPORTANT_SYM;}

{num}{E}{M}	            {return EMS;}
{num}{E}{X}	            {return EXS;}
{num}{P}{X}	            {return LENGTH;}
{num}{C}{M}	            {return LENGTH;}
{num}{M}{M}	            {return LENGTH;}
{num}{I}{N}	            {return LENGTH;}
{num}{P}{T}	            {return LENGTH;}
{num}{P}{C}	            {return LENGTH;}
{num}{D}{E}{G}		    {return ANGLE;}
{num}{R}{A}{D}		    {return ANGLE;}
{num}{G}{R}{A}{D}	    {return ANGLE;}
{num}{M}{S}		        {return TIME;}
{num}{S}		        {return TIME;}
{num}{H}{Z}		        {return FREQ;}
{num}{K}{H}{Z}		    {return FREQ;}
{num}{ident}		    {return DIMENSION;}
{num}%			        {return PERCENTAGE;}
{num}			        {return NUMBER;}

"url("{w}{string}{w}")" {return URI;}
"url("{w}{url}{w}")"    {return URI;}
{baduri}                {return BAD_URI;}

{ident}"("		        {return FUNCTION;}

.			            {return *yytext;}

%%

