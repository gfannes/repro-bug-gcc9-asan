doctest/doctest/doctest.h:
	git clone https://github.com/onqtam/doctest
test.o: test.cpp doctest/doctest/doctest.h
	g++ -c test.cpp -o test.o -I doctest/doctest -fsanitize=address -O3
test: test.o
	g++ test.o -o test -lasan

.PHONY: clean proper run
clean:
	rm -f *.o
	rm -f test
proper: clean
	rm -rf doctest
run: test
	./test
