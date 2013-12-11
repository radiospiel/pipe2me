trim_whitespace:
	flex -o trim_whitespace.c trim_whitespace.fl && gcc -o trim_whitespace -Os trim_whitespace.c -lfl

install: trim_whitespace
	cp trim_whitespace /usr/local/bin/trim_whitespace

test: trim_whitespace
	@ ./trim_whitespace < trim_whitespace.test.in | diff trim_whitespace.test.out -
	@ echo "Test ok"