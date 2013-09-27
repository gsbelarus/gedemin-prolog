unit testSWIProlog;

interface

uses
  Classes, TestFrameWork, gsTestFrameWork, gsPLClient, dbclient, DB,
  Sysutils{, swiprolog}, PLIntf, PLHeader, ActiveX;

type
   PCharArray =  ^TCharArray;
   TCharArray = array[0..1024] of Char;
   
   Test_SWIProlog = class(TgsDBTestCase)

   published
     procedure TestSWIProlog;
   end;

implementation

procedure Test_SWIProlog.TestSWIProlog;
var   
  obj: TgsPLClient;
  cds: TClientDataSet;
  ss: String; 
begin
  Obj := TgsPLClient.Create;
  try
  Obj.Initialise(VarArrayOf(['libswipl.dll', '-x', 'gd_pl_state']));
    Obj.Call('true');
    Obj.MakePredicatesOfObject('TgdcCurr', '', 'ByID', VarArrayOf([200010]), nil, 'ID,ISNCU,NAME', FTr, 'Gd_curr', 'gd_curr');
    Obj.MakePredicatesOfSQLSelect('select first 5 c.id, c.name from gd_curr c', FTr, 'Test1', 'Test1');

    CDS := TClientDataSet.Create(nil);
    try
      CDS.FieldDefs.Add('Field1', ftInteger, 0, False);
      //CDS.FieldDefs.Add('Field2', ftInteger, 0, False);
      CDS.FieldDefs.Add('Field3', ftString, 255, False);
      CDS.CreateDataSet;
      CDS.Open;
      Obj.ExtractData(CDS, 'Test1', 2);
      CDS.First;
      while not cds.eof do
      begin
        ss := CDS.FieldByName('Field3').AsString;
        CDS.Next;
      end;
    finally
      CDS.Free;
    end;

  finally
    Obj.Free;
  end;
end;

initialization
  RegisterTest('Apps', Test_SWIProlog.Suite);

end.
