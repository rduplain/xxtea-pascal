# Build static binary with a single `make` invocation.
#
# Require Free Pascal Compiler `fpc`.
#
# Debian/Ubuntu: `sudo apt install fpc`.
# Mac OS X: `brew install fpc`.

all: cipher

cipher: $(wildcard *.pas)
	fpc -ocipher -Xs -XS -XX Cipher.pas

clean:
	rm -f Cipher cipher *.o *.ppu
