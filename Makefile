# Build static binary with a single `make` invocation.
#
# Require Free Pascal Compiler `fpc`.
#
# Debian/Ubuntu: `sudo apt install fpc`.
# Mac OS X: `brew install fpc`.

all: test

cipher: $(wildcard *.pas)
	fpc -ocipher -Xs -XS -XX Cipher.pas

test: cipher
	@./bin/test ./cipher

clean:
	rm -f Cipher cipher *.o *.ppu
