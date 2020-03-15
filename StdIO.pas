(*
 Standard Input/Output.

 Assume single-byte strings on standard I/O.
*)

UNIT StdIO;

INTERFACE

FUNCTION stdin(): AnsiString;
PROCEDURE stdout(CONST str: AnsiString);
PROCEDURE stderr(CONST str: AnsiString);

IMPLEMENTATION

USES Classes, SysUtils;

FUNCTION stdin(): AnsiString;
(* Read from standard input stream until end of file. *)
VAR
   fd: TextFile;
   str: AnsiString;
   c: CHAR;
   n: UInt32;
BEGIN
   Assign(fd, ''); (* Input *)
   Reset(fd);

   SetLength(str, 0);
   n := 0;

   WHILE NOT EOF(fd) DO
   BEGIN
      Read(fd, c);
      Inc(n, 1);
      SetLength(str, n);
      str[n] := c;
   END;

   Close(fd);

   stdin := str;
END;

PROCEDURE WriteString(VAR fd: TextFile; CONST str: AnsiString);
(* Write 1-indexed string to Output or ErrOutput fd. *)
VAR
   stream: THandleStream;
BEGIN
   stream := THandleStream.Create(GetFileHandle(fd));
   stream.Write(str[1], Length(str));
   stream.Free();
END;

PROCEDURE stdout(CONST str: AnsiString);
(* Write string to standard output stream. *)
BEGIN
   WriteString(Output, str);
END;

PROCEDURE stderr(CONST str: AnsiString);
(* Write string to standard error stream. *)
BEGIN
   WriteString(ErrOutput, str);
END;

END.
