(*
 XXTEA - Corrected Block Tiny Encryption Algorithm (TEA)

 Original XXTEA algorithm by David J. Wheeler & Roger M. Needham, Oct 1998.
*)

UNIT XXTEA;

INTERFACE

TYPE
   UInt32 = LONGWORD;
   UInt32Array = ARRAY OF UInt32;

CONST
   delta: UInt32 = $9e3779b9;

PROCEDURE Encrypt(VAR v: UInt32Array; CONST k: UInt32Array);
PROCEDURE Decrypt(VAR v: UInt32Array; CONST k: UInt32Array);

IMPLEMENTATION

FUNCTION MX(sum, y, z, p, e: UInt32; CONST k: UInt32Array): UInt32;
(* XXTEA's MX C-macro as function, shift data in each round of encryption. *)
BEGIN
   MX := ((((z >> 5) xor (y << 2)) + ((y >> 3) xor (z << 4)))
          xor
          ((sum xor y) + (k[p and 3 xor e] xor z)));
END;

PROCEDURE Encrypt(VAR v: UInt32Array; CONST k: UInt32Array);
(* Encrypt with XXTEA, the "Coding Part" of the original algorithm. *)
VAR
   n, y, z, sum, q: UInt32;
   p, e: UInt32;
BEGIN
   n := Length(v);

   IF n > 0 THEN
   BEGIN
      y := v[0];
      z := v[n-1];
      sum := 0;
      q := 6 + 52 div n;

      REPEAT
         Inc(sum, delta);
         e := (sum >> 2) and 3;
         FOR p := 0 TO (n-1) - 1 DO
         BEGIN
            y := v[p+1];
            Inc(v[p], MX(sum, y, z, p, e, k));
            z := v[p];
         END;
         p := n-1;
         y := v[0];
         Inc(v[p], MX(sum, y, z, p, e, k));
         z := v[p];
         Dec(q);
      UNTIL q = 0;
   END;
END;

PROCEDURE Decrypt(VAR v: UInt32Array; CONST k: UInt32Array);
(* Decrypt with XXTEA, the "Decoding Part" of the original algorithm. *)
VAR
   n, y, z, sum, q: UInt32;
   p, e: UInt32;
BEGIN
   n := Length(v);

   IF n > 0 THEN
   BEGIN
      y := v[0];
      q := 6 + 52 div n;
      sum := q * delta;

      REPEAT
         e := (sum >> 2) and 3;
         FOR p := n-1 DOWNTO 1 DO
         BEGIN
            z := v[p-1];
            Dec(v[p], MX(sum, y, z, p, e, k));
            y := v[p];
         END;
         p := 0;
         z := v[n-1];
         Dec(v[p], MX(sum, y, z, p, e, k));
         y := v[p];
         Dec(sum, delta);
      UNTIL sum = 0;
   END;
END;

END.
