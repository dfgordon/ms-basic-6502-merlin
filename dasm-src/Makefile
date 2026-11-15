clean:
	echo "Cleaning up ..."
	rm -f *.hex *.lst *.out

tools:
	gcc -o hexdump hexdump.c
	chmod 500 hexdump

tests:
	rm -f *.diff
	./testrun 1 kim  2000 4260 2000
	./testrun 2 osi  A000 BEE1 A000
	./testrun 3 pet1 C000 E1E0 C000
	./testrun 4 apl  D000 FFFF D000
