program gd_pl;

uses
  Forms,
  Main in 'MAIN.PAS' {MainForm},
  gsPLScript in 'gsPLScript.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Gedemin-Prolog';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
