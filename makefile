test.o: test.cpp
	g++ -c test.cpp -o test.o -fsanitize=address -O3 -save-temps
test: test.o
	g++ test.o -o test -lasan

.PHONY: clean run
clean:
	rm -f *.o *.ii *.s
	rm -f test
run: test
	./test
