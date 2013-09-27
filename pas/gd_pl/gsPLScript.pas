unit gsPLScript;

interface

uses
  Windows, Classes, SysUtils
  , swiprolog
  ;

type
  TgsPL = class(TObject)
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TgsPLScript = class(TgsPL)
  private
    FInput: String;
    FOutput: String;
    FReturnValue: String;
    procedure SetInput(const AInput: String);
    function GetInput(): String;
    function GetOutput(): String;
    function GetReturnValue(): String;
    argc: Integer;
    argv: array of PChar;
  public
    constructor Create;
    destructor Destroy; override;
    function Call(): Boolean;
    property Input: String read GetInput write SetInput;
    property Output: String read GetOutput;
    property ReturnValue: String read GetReturnValue;
  end;

  EgsPLScriptException = class(Exception);

implementation

constructor TgsPL.Create;
var
  PL: Integer;

begin
  inherited;

  argc := 10;
  SetLength(argv, argc+1);

  argv[0] := PChar('libswipl.dll');
  argv[1] := PChar('--quiet');
  argv[2] := PChar('--nodebug');
  argv[3] := PChar('--nosignals');
  argv[4] := PChar('-x');
  argv[5] := PChar('gd_pl_state');
  argv[6] := PChar('-g');
  argv[7] := PChar('true');
  argv[8] := PChar('-t');
  argv[9] := PChar('true');
  argv[10] := nil;

  PL := PL_is_initialised(argc, argv);
  if PL <> 0 then
    Exit;

  PL := PL_initialise(argc, argv);
  if PL = 0 then
    raise EgsPLScriptException.Create('SWI-Prolog initialisation failed!');
end;

destructor TgsPL.Destroy;
var
  PL: Integer;

begin
  PL := PL_cleanup(0);

  if PL = 0 then
    raise EgsPLScriptException.Create('SWI-Prolog cleanup failed!');

  inherited;
end;

constructor TgsPLScript.Create;
begin
  inherited;
end;

destructor TgsPLScript.Destroy;
begin
  inherited;
end;

function TgsPLScript.Call(): Boolean;
var
  a1, a2, a3, e: term_t;
  p: predicate_t;
  q: qid_t;

  S2, S3: PChar;
  L2, L3: Cardinal;

begin
  FOutput := ''; FReturnValue := '';
  
  a1 := PL_new_term_refs(3);
  a2 := a1 + 1; a3 := a1 + 2;

  PL_put_string_chars(a1, PChar(FInput));
  p := PL_predicate(PChar('pl_run'), 3, PChar('user'));
  q := PL_open_query(PChar('user'), PL_Q_CATCH_EXCEPTION, p, a1);

  if q <> 0 then
    begin
      if PL_next_solution(q) <> 0 then
        begin
          if PL_get_string(a2, S2, L2) <> 0 then
            begin
              SetLength(FOutput, L2);
              FOutput := String(S2);
            end;
          if PL_get_string(a3, S3, L3) <> 0 then
            begin
              SetLength(FReturnValue, L3);
              FReturnValue := String(S3);
            end;
        end
      else
        begin
          e := PL_exception(q);
          if Integer(e) = 0 then
            FReturnValue := 'call failed'
          else
            if PL_get_atom_chars(e, S3) <> 0 then
              begin
                FReturnValue := String(S3);
              end
            else
              FReturnValue := 'call exception failed'
        end;
    end
  else
    begin
      raise EgsPLScriptException.Create('Not enough space on the environment stack!')
    end;

  Result := FReturnValue = 'true'  
end;

procedure TgsPLScript.SetInput(const AInput: String);
begin
  if FInput <> AInput then
    FInput := AInput;
end;

function TgsPLScript.GetInput(): String;
begin
  Result := FInput;
end;

function TgsPLScript.GetOutput(): String;
begin
  Result := FOutput;
end;

function TgsPLScript.GetReturnValue(): String;
begin
  Result := FReturnValue;
end;

end.
