default: test

install: trim_whitespace
	cp trim_whitespace /usr/local/bin/trim_whitespace

trim_whitespace:
	flex -o trim_whitespace.c trim_whitespace.fl && gcc -o trim_whitespace -Os trim_whitespace.c -lfl

test: trim_whitespace
	@ ./tests/run.sh
