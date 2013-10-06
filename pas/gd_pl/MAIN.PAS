unit Main;

interface

uses
  SysUtils, Windows, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, Menus
  //
  //, gsPLScript
  , PLHeader, PLIntf, gsPLClient
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
    CheckBox2: TCheckBox;
    Button3: TButton;
    procedure CheckBox1Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure CheckBox2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  end;

var
  MainForm: TMainForm;
  //PLScript: TgsPLScript;
  PLClient: TgsPLClient;

implementation

{$R *.DFM}

procedure TMainForm.CheckBox1Click(Sender: TObject);
begin
{  if CheckBox1.Checked then
    begin
      FreeAndNil(PLScript);
      PLScript := TgsPLScript.Create;
    end
  else
    begin
    FreeAndNil(PLScript);
    end;
  Button1.Enabled := CheckBox1.Checked;
}end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
{  if PLScript <> nil then
    begin
      PLScript.Input := Memo1.Text;
      Memo2.Clear;
      Memo3.Clear;
      PLScript.Call;
      Memo2.Text := PLScript.Output;
      Memo3.Text := PLScript.ReturnValue;
    end;
}end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  Memo1.Clear;
  Memo2.Clear;
  Memo3.Clear;
  Memo1.SetFocus;
end;

procedure TMainForm.CheckBox2Click(Sender: TObject);
begin
  if CheckBox2.Checked then
    begin
      FreeAndNil(PLClient);
      PLClient := TgsPLClient.Create;
      PLClient.Initialise();
    end
  else
    begin
      FreeAndNil(PLClient);
    end;
  Button3.Enabled := CheckBox2.Checked;
end;

procedure TMainForm.Button3Click(Sender: TObject);
var
  Tv: TgsPLTermv;
begin
  if PLClient <> nil then
    begin
      Tv := TgsPLTermv.CreateTermv(3);
      Tv.PutString(0, Memo1.Text);
      if PLClient.Call('pl_run', Tv) then
        begin
          Memo2.Text :=  Tv.ReadString(1);
          Memo3.Text := Tv.ReadString(2);
        end
      else
        begin
          Memo2.Clear;
          Memo3.Text := 'false';
        end;
      FreeAndNil(Tv);
    end;
end;

end.
