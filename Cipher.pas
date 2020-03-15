(* Encrypt/decrypt via the command line using XXTEA. *)

PROGRAM Cipher;

USES CustApp, StdIO, StringBytes, XXTEA;

TYPE
   ParsedOptions = RECORD
                      Command: STRING;
                      Key: STRING;
                      Usage: AnsiString;
                      Error: STRING;
                      Warning: STRING;
                   END;

CONST
   prog: STRING = 'cipher';

FUNCTION ParseArguments(): ParsedOptions;
VAR
   Application: TCustomApplication;
   options: ParsedOptions;
BEGIN
   Application := TCustomApplication.Create(NIL);

   WITH options DO
   BEGIN
      Usage :=
         'usage: ' + prog + ' -k KEY encrypt|decrypt' + LineEnding +
         LineEnding +
         '  -k, --key=KEY              128-bit encryption key.' + LineEnding +
         LineEnding +
         'Encrypt/decrypt with XXTEA. Read stdin, write stdout.' + LineEnding;

      Warning := '';

      IF Application.HasOption('h', 'help') THEN
         Command := 'help';

      Error := Application.CheckOptions('hk:', 'help key:');
      IF (Command = 'help') OR (ParamCount = 0) OR (ERROR <> '') THEN
      BEGIN
         Error := Usage;
      END
      ELSE
      BEGIN
         Command := ParamStr(ParamCount);
         IF (Command <> 'encrypt') AND (Command <> 'decrypt') THEN
            Error :=
            prog + ': ' +
               'error: specify encrypt or decrypt (as final argument).' +
               LineEnding + Error;

         IF NOT Application.HasOption('k', 'key') THEN
         BEGIN
            Error :=
               prog + ': ' +
               'error: encryption key is required.' +
               LineEnding + Error;
         END
         ELSE
         BEGIN
            Key := Application.GetOptionValue('k', 'key');

            IF Length(Key) > 16 THEN
               Warning :=
                  prog + ': ' +
                  'warning: truncating key to 128 bits (16 characters).' +
                  LineEnding + Warning;
         END;

      END;
   END;

   ParseArguments := options;
END;

VAR
   options: ParsedOptions;
   input: AnsiString;
   data: UInt32Array;
   key: UInt32Array;
BEGIN
   options := ParseArguments();

   IF options.Command = 'help' THEN
   BEGIN
      stdout(options.Usage);
      Halt();
   END;

   IF options.Error <> '' THEN
   BEGIN
      stderr(options.Error);
      Halt(2);
   END;

   IF options.Warning <> '' THEN
   BEGIN
      stderr(options.Warning);
   END;

   key := StringToUInt32Array(options.Key);
   SetLength(key, 4);

   input := stdin();

   IF input <> '' THEN
   BEGIN
      data := StringToUInt32Array(input);

      IF options.Command = 'encrypt' THEN
         Encrypt(data, key)
      ELSE
         Decrypt(data, key);

      stdout(UInt32ArrayToString(data));
   END;
END.
