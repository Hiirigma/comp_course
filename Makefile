all: lx ycc cpp

lx:
	lex -d css.l

ycc:
	yacc -d css.y

cpp:
	gcc lex.yy.c y.tab.c -o app.out

check:
	./app.out ok.css
	./app.out ne_ok.css
