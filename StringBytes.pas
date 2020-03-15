(*
 Convert String to ByteArray to Unsigned Integer Array, and back.

 Ignore platform endianness to support portability of round-trip conversion.
*)

UNIT StringBytes;

INTERFACE

TYPE
   ByteArray = ARRAY OF BYTE;
   UInt32 = LONGWORD;
   UInt32Array = ARRAY OF UInt32;

FUNCTION StringToByteArray(CONST str: AnsiString): ByteArray;
FUNCTION ByteArrayToString(CONST bytes: ByteArray): AnsiString;
PROCEDURE EnsureByteArrayAligns32(VAR bytes: ByteArray);
PROCEDURE TrimNullTail(VAR bytes: ByteArray);
FUNCTION StringToUInt32Array(CONST str: AnsiString): UInt32Array;
FUNCTION UInt32ArrayToString(CONST arr: UInt32Array): AnsiString;

IMPLEMENTATION

FUNCTION StringToByteArray(CONST str: AnsiString): ByteArray;
(* Copy 1-indexed AnsiString to new 0-indexed ByteArray element by element. *)
VAR
   bytes: ByteArray;
   i: UInt32;
   n: UInt32;
BEGIN
   n := Length(str);
   SetLength(bytes, n);

   i := 0;

   REPEAT
      bytes[i] := Byte(str[i+1]);
      Inc(i, 1);
   UNTIL i = n;

   StringToByteArray := bytes;
END;

FUNCTION ByteArrayToString(CONST bytes: ByteArray): AnsiString;
(* Copy 0-indexed ByteArray to new 1-indexed AnsiString element by element. *)
VAR
   str: AnsiString;
   i: UInt32;
   n: UInt32;
BEGIN
   n := Length(bytes);
   SetLength(str, n);

   i := 0;

   REPEAT
      Inc(i, 1);
      str[i] := Char(bytes[i-1]);
   UNTIL i = n;

   ByteArrayToString := str;
END;

PROCEDURE EnsureByteArrayAligns32(VAR bytes: ByteArray);
(* Ensure byte array size is multiple of 4: 32-bit = 4 * 8-bit byte. Pad 0. *)
VAR
   n: UInt32;
BEGIN
   n := Length(bytes);
   IF n mod 4 <> 0 THEN
      SetLength(bytes, n + (4 - (n mod 4)));
END;

PROCEDURE TrimNullTail(VAR bytes: ByteArray);
(* Truncate byte array tail, trimming null values. Inverse of align 32. *)
VAR
   i: UInt32;
BEGIN
   i := Length(bytes);

   REPEAT
      Dec(i, 1);
   UNTIL bytes[i] <> $00;

   SetLength(bytes, i+1);
END;

FUNCTION StringToUInt32Array(CONST str: AnsiString): UInt32Array;
(* Convert string to 32-bit unsigned integer array. *)
VAR
   bytes: ByteArray;
   arr: UInt32Array;
   i: UInt32;
   n: UInt32;
BEGIN
   bytes := StringToByteArray(str);
   EnsureByteArrayAligns32(bytes);
   n := Length(bytes);

   SetLength(arr, n div 4);

   i := 0;

   REPEAT
      arr[i div 4] := (((bytes[i]   and $000000ff) << 24) or
                       ((bytes[i+1] and $000000ff) << 16) or
                       ((bytes[i+2] and $000000ff) <<  8) or
                       ((bytes[i+3] and $000000ff)));
      i := i + 4;
   UNTIL i = n;

   StringToUInt32Array := arr;
END;

FUNCTION UInt32ArrayToString(CONST arr: UInt32Array): AnsiString;
(* Convert 32-bit unsigned integer array to string. *)
VAR
   bytes: ByteArray;
   val: UInt32;
   i: UInt32;
   n: UInt32;
BEGIN
   n := Length(arr) * 4;
   SetLength(bytes, n);
   EnsureByteArrayAligns32(bytes);

   i := 0;

   REPEAT
      val := arr[i div 4];
      bytes[i]   := ((val >> 24) and $ff);
      bytes[i+1] := ((val >> 16) and $ff);
      bytes[i+2] := ((val >>  8) and $ff);
      bytes[i+3] := ((val)       and $ff);
      i := i + 4;
   UNTIL i = n;

   TrimNullTail(bytes);

   UInt32ArrayToString := ByteArrayToString(bytes);
END;

END.
