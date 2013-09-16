unit Main;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Menus
  //
  , swiprolog, gsPLScript
  ;

type
  TMainForm = class(TForm)
    Memo1: TMemo;
    Memo2: TMemo;
    CheckBox1: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo3: TMemo;
    Button1: TButton;
    Button2: TButton;
    procedure CheckBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  end;

var
  MainForm: TMainForm;
  PLScript: TgsPLScript;

implementation

{$R *.DFM}

procedure TMainForm.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked then
    begin
      FreeAndNil(PLScript);
      PLScript := TgsPLScript.Create;
    end
  else
    FreeAndNil(PLScript);
  Button1.Enabled := CheckBox1.Checked;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  if PLScript <> nil then
    begin
      PLScript.Input := Memo1.Text;
      Memo2.Clear;
      Memo3.Clear;
      PLScript.Call;
      Memo2.Text := PLScript.Output;
      Memo3.Text := PLScript.ReturnValue;
    end;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  Memo1.Clear;
  Memo2.Clear;
  Memo3.Clear;
end;

end.
