all: clean lx ycc cpp

lx:
	flex css.l

ycc:
	bison -d css.y

cpp:
	gcc lex.yy.c css.tab.c -o app.out

check:
	./app.out ok.css
	./app.out ne_ok.css

clean:
	rm -f app.out
	rm -f lex.yy.c
	rm -f *.tab.c
	rm -f *.tab.h
