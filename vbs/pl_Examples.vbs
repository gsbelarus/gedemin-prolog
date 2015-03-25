Option Explicit

Sub pl_Examples()
  Dim Title, Msg, Ret
  Title = "Гедымин - Пролог"
  Msg = _
        "/* Примеры использования PL-объектов */" & vbCrLf & vbCrLf & _
        "%%%%" & vbCrLf & _
        "%    pl_Examples" & vbCrLf & _
        "%      TgsPLClient: Initialise, IsInitialised"
  
  Dim PL
  Set PL = Designer.CreateObject(nil, "TgsPLClient", "")
  If Not PL.IsInitialised Then
    Dim SwiPath, InitStr
    SwiPath = "C:/golden/Gedemin/exe/"
    InitStr = _
              "[libswipl.dll]," & _
              "[-x],[" & SwiPath & "swipl/gd_pl_state.dat]," & _
              "[-p],[foreign=" & SwiPath & "swipl/lib]," & _
              "[-s],[" & SwiPath & "swipl/test/pl_Examples_Test.pl]," & _
              "[-g],[add_world]"
    InitStr = ""
    If Not PL.Initialise(InitStr) Then
      Msg = "Ошибка инициализации SWI-Prolog!"
      Call MsgBox(Msg, vbCritical + vbOkOnly, Title)
      PL.DestroyObject
      Exit Sub
    End If
    'InitStr = ""
  End If

  Dim FuncIndex, FuncName, FuncBegin, FuncEnd
  FuncName = "pl_Example"
  FuncBegin = 1
  FuncEnd = 8
  For FuncIndex = FuncBegin To FuncEnd
    Msg = Msg & vbCrLf & _
          Eval(FuncName & FuncIndex & "(PL, InitStr)")
  Next
  Msg = Msg & vbCrLf & "%%%%"
  PL.DestroyObject

  Dim frmMsg, Creator
  Set Creator = New TCreator
  Set frmMsg = Creator.GetObject(nil, "usrf_Msg", "")

  frmMsg.Caption = Title
  frmMsg.GetComponent("usrg_Msg").Lines.Text = Msg
  frmMsg.ShowModal
End Sub

Function pl_Example1(ByRef PL, ByVal InitStr)
  Dim Title, Msg
  Title = vbCrLf & _
          "%%" & vbCrLf & _
          "% 1. pl_Example1(PL, InitStr)" & vbCrLf & _
          "%      TgsPLClient: Call" & vbCrLf & _
          "%      TgsPLTermv: PutAtom, ToString"

  pl_Example1 = ""
  
  Dim PredicateName, Params
  PredicateName = "current_prolog_flag"
  Set Params = Designer.CreateObject(2, "TgsPLTermv", "")
  Params.PutAtom 0, "executable"

  Msg = _
    "% Запрос" & vbCrLf & _
    "?- " & PredicateName & "(" & Params.ToString(0) & ", AppPath)."

  If PL.Call(PredicateName, Params) Then
    Dim AppPath
    AppPath = Params.ToString(1)
    Msg = Msg & vbCrLf & _
      "AppPath = " & AppPath & "."
  Else
    Msg = Msg & vbCrLf & "false."
  End If
  

  pl_Example1 = Title & vbCrLf & Msg

  Params.DestroyObject
End Function

Function pl_Example2(ByRef PL, ByVal InitStr)
  Dim Title, Msg
  Title = vbCrLf & _
          "%%" & vbCrLf & _
          "% 2. pl_Example2(PL, InitStr)" & vbCrLf & _
          "%      TgsPLClient: Call2, Call" & vbCrLf & _
          "%      TgsPLTermv: PutAtom, ToString"

  pl_Example2 = ""

  Dim Code
  Code = "assertz( pl_Example(pl_Example2, 'Пример 2') )"
  Msg = _
    "% Выполнение кода" & vbCrLf & _
    "?- " & Code & "."

  If PL.Call2(Code) Then
    Msg = Msg & vbCrLf & "true."
  Else
    Msg = Msg & vbCrLf & "false."
  End If

  Dim PredicateName, Params
  PredicateName = "pl_Example"
  Set Params = Designer.CreateObject(2, "TgsPLTermv", "")
  Params.PutAtom 0, "pl_Example2"

  Msg = Msg & vbCrLf & _
    "% Запрос" & vbCrLf & _
    "?- " & PredicateName & "(" & Params.ToString(0) & ", Text)."

  If PL.Call(PredicateName, Params) Then
    Msg = Msg & vbCrLf & _
      "Text = " & Params.ToString(1) & "."
  Else
    Msg = Msg & vbCrLf & "false."
  End If

  pl_Example2 = Title & vbCrLf & Msg

  Params.DestroyObject
End Function

Function pl_Example3(ByRef PL, ByVal InitStr)
  Dim Title, Msg
  Title = vbCrLf & _
          "%%" & vbCrLf & _
          "% 3. pl_Example3(PL, InitStr)" & vbCrLf & _
          "%      TgsPLClient: Compound, Term, Call" & vbCrLf & _
          "%      TgsPLTermv: PutAtom, ToString"

  pl_Example3 = ""

  Dim Goal, Functor, Termv
  Set Goal = Designer.CreateObject(1, "TgsPLTermv", "")
  Functor = "pl_Example"
  Set Termv = Designer.CreateObject(2, "TgsPLTermv", "")
  Termv.PutAtom 0, "pl_Example3"
  Termv.PutAtom 1, "Пример 3"
  Call PL.Compound(Goal.Term(0), Functor, Termv)

  Dim Code
  Code = "assertz"
  Msg = _
    "% Выполнение кода" & vbCrLf & _
    "?- " & Code & "( " & Goal.ToString(0) & " )."

  If PL.Call(Code, Goal) Then
    Msg = Msg & vbCrLf & "true."
  Else
    Msg = Msg & vbCrLf & "false."
  End If

  Dim PredicateName, Params
  PredicateName = "pl_Example"
  Set Params = Designer.CreateObject(2, "TgsPLTermv", "")
  Params.PutAtom 0, "pl_Example3"

  If PL.Call(PredicateName, Params) Then
    Msg = Msg & vbCrLf & _
      "% Запрос" & vbCrLf & _
      "?- " & PredicateName & "(" & Params.ToString(0) & ", Text)." & vbCrLf & _
      "Text = " & Params.ToString(1) & "."
  Else
    Msg = Msg & vbCrLf & "false."
  End If

  pl_Example3 = Title & vbCrLf & Msg
  
  Termv.DestroyObject
  Goal.DestroyObject
  Params.DestroyObject
End Function

Function pl_Example4(ByRef PL, ByVal InitStr)
  Dim Title, Msg
  Title = vbCrLf & _
          "%%" & vbCrLf & _
          "% 4. pl_Example4(PL, InitStr)" & vbCrLf & _
          "%      TgsPLClient: LoadScriptByName, Call" & vbCrLf & _
          "%      TgsPLTermv: ToString"

  pl_Example4 = ""

  Dim ScriptName
  ScriptName = "pl_Examples_Script"
  If InitStr = "" Then
    If Not PL.LoadScriptByName(ScriptName) Then
      Exit Function
    End If
  End If

  Dim PredicateName, Params
  PredicateName = "hello_world"
  Set Params = Designer.CreateObject(1, "TgsPLTermv", "")

  Msg = _
    "% Запрос" & vbCrLf & _
    "?- " & PredicateName & "(Hello)."

  If PL.Call(PredicateName, Params) Then
    Msg = Msg & vbCrLf & _
      "Hello = " & Params.ToString(0) & "."
  Else
    Msg = Msg & vbCrLf & "false."
  End If

  pl_Example4 = Title & vbCrLf & Msg

  Params.DestroyObject
End Function

Function pl_Example5(ByRef PL, ByVal InitStr)
  Dim Title, Msg
  Title = vbCrLf & _
          "%%" & vbCrLf & _
          "% 5. pl_Example5(PL, InitStr)" & vbCrLf & _
          "%      TgsPLClient: Debug, LoadScriptByName" & vbCrLf & _
          "%      TgsPLTermv: ToString" & vbCrLf & _
          "%      TgsPLQuery: OpenQuery, EOF, NextSolution, Close, Cut"

  pl_Example5 = ""

  PL.Debug = True
  
  Dim ScriptName
  ScriptName = "pl_Examples_Script"
  If InitStr = "" Then
    If Not PL.LoadScriptByName(ScriptName) Then
      Exit Function
    End If
  End If
  
  Dim Params
  Set Params = Designer.CreateObject(1, "TgsPLTermv", "")
  Dim PredicateName, Query
  PredicateName = "hello_world"
  Set Query = Designer.CreateObject(nil, "TgsPLQuery", "")
  Query.PredicateName = PredicateName
  Query.Termv = Params
  Query.OpenQuery

  Msg = _
    "% Запрос" & vbCrLf & _
    "?- " & PredicateName & "(Hello)."

  If Not Query.EOF Then
    Do Until Query.EOF
      Msg = Msg & vbCrLf & _
        "Hello = " & Params.ToString(0)
      Query.NextSolution
      If Query.EOF Then
        Msg = Msg & "."
      Else
        Msg = Msg & " ;"
      End If
    Loop
  Else
    Msg = Msg & vbCrLf & "false."
  End If
  Query.Close

  Msg = Msg & vbCrLf & _
    "% Запрос" & vbCrLf & _
    "?- " & PredicateName & "(Hello), !."

  Query.OpenQuery

  If Not Query.EOF Then
    Do Until Query.EOF
      Msg = Msg & vbCrLf & _
        "Hello = " & Params.ToString(0)
      Query.Cut
      Query.NextSolution
      If Query.EOF Then
        Msg = Msg & "."
      Else
        Msg = Msg & " ;"
      End If
    Loop
  Else
    Msg = Msg & vbCrLf & "false."
  End If
  Query.Close

  pl_Example5 = Title & vbCrLf & Msg

  Query.DestroyObject
  Params.DestroyObject
End Function

Function pl_Example6(ByRef PL, ByVal InitStr)
  'TERM-TYPE CONSTANTS
  Const PL_VARIABLE = 1
  Const PL_ATOM = 2
  Const PL_INTEGER = 3
  Const PL_FLOAT = 4
  Const PL_STRING = 5
  Const PL_TERM = 6

  Dim Title, Msg
  Title = vbCrLf & _
          "%%" & vbCrLf & _
          "% 6. pl_Example6(PL, InitStr)" & vbCrLf & _
          "%      TgsPLClient: LoadScriptByName" & vbCrLf & _
          "%      TgsPLTermv: DataType, ReadInteger, ReadAtom, ReadDate, ReadString" & vbCrLf & _
          "%      TgsPLQuery: OpenQuery, EOF, NextSolution, Close"

  pl_Example6 = ""

  Dim ScriptName
  ScriptName = "pl_Examples_Script"
  If InitStr = "" Then
    If Not PL.LoadScriptByName(ScriptName) Then
      Exit Function
    End If
  End If

  Dim Params
  Set Params = Designer.CreateObject(2, "TgsPLTermv", "")

  Dim PredicateName, Query
  Dim Arg1, Arg2
  PredicateName = "some_fact"
  Set Query = Designer.CreateObject(nil, "TgsPLQuery", "")
  Query.PredicateName = PredicateName
  Query.Termv = Params
  Query.OpenQuery

  Msg = _
    "% Запрос" & vbCrLf & _
    "?- " & PredicateName & "(Arg1, Arg2)."

  Msg = Msg & vbCrLf & _
    "% Обработка фактов"
  If Not Query.EOF Then
    Do Until Query.EOF
      Select Case Params.DataType(0)
        Case PL_INTEGER
          Arg1 = Params.ReadInteger(0) & ": "
        Case PL_ATOM
          If IsDate(Params.ReadAtom(0)) Then
            Arg1 = Year(Params.ReadDate(0)) & " - "
          Else
            Arg1 = ""
          End If
        Case Else
          Arg1 = ""
      End Select
      If Not Arg1 = "" Then
        Select Case Params.DataType(1)
          Case PL_ATOM
            Arg2 = Params.ReadAtom(1)
          Case PL_STRING
            Arg2 = Params.ReadString(1)
          Case Else
            Arg2 = ""
        End Select
        Msg = Msg & vbCrLf & _
          "%   " & Arg1 & Arg2
      End If
      Query.NextSolution
    Loop
  Else
    Msg = Msg & vbCrLf & "false."
  End If
  Query.Close

  pl_Example6 = Title & vbCrLf & Msg

  Query.DestroyObject
  Params.DestroyObject
End Function

Function pl_Example7(ByRef PL, ByVal InitStr)
  Dim Title, Msg
  Title = vbCrLf & _
          "%%" & vbCrLf & _
          "% 7. pl_Example7(PL, InitStr)" & vbCrLf & _
          "%      TgsPLClient: LoadScriptByName, Debug, MakePredicatesOfSQLSelect" & vbCrLf & _
          "%      TgsPLTermv: PutAtom, ReadString, PutString" & vbCrLf & _
          "%      TgsPLQuery: OpenQuery, EOF, NextSolution, Close"

  pl_Example7 = ""

  PL.Debug = False

  Dim ScriptName
  ScriptName = "pl_Examples_Script"
  If InitStr = "" Then
    If Not PL.LoadScriptByName(ScriptName) Then
      Exit Function
    End If
  End If

  Dim P_sql, Tv_sql, Q_sql
  Dim FactName, SQL
  P_sql = "gd_sql"
  Set Tv_sql = Designer.CreateObject(2, "TgsPLTermv", "")
  Set Q_sql = Designer.CreateObject(nil, "TgsPLQuery", "")
  Q_sql.PredicateName = P_sql
  Q_sql.Termv = Tv_sql
  FactName = "gd_place"
  Tv_sql.PutAtom 0, FactName
  Q_sql.OpenQuery
  
  Msg = _
    "% Запрос" & vbCrLf & _
    "?- " & P_sql & "(" & FactName & ", SQL)."

  Dim Ret
  PL.Debug = True
  
  Msg = Msg & vbCrLf & _
    "% Обработка фактов, наполнение базы знаний"
  If Not Q_sql.EOF Then
    Do Until Q_sql.EOF
      SQL = Tv_sql.ReadString(1)
      Msg = Msg & vbCrLf & _
            "/*" & SQL & "*/" & vbCrLf
      Ret = PL.MakePredicatesOfSQLSelect( _
              SQL, _
              gdcBaseManager.ReadTransaction, _
              FactName, FactName, False)
      Msg = Msg & _
            "% Добавлено " & Ret & " фактов " & FactName
      Q_sql.NextSolution
    Loop
  Else
    Msg = Msg & vbCrLf & "false."
  End If
  Q_sql.Close
  Q_sql.DestroyObject
  Tv_sql.DestroyObject

  Dim P_info, Tv_info, Q_info
  Dim PlaceNameIn, PlaceNameOut, PlaceTypeOut
  P_info = "place_info"
  Set Tv_info = Designer.CreateObject(3, "TgsPLTermv", "")
  Set Q_info = Designer.CreateObject(nil, "TgsPLQuery", "")
  Q_info.PredicateName = P_info
  Q_info.Termv = Tv_info
  PlaceNameIn = "Минск"
  Tv_info.PutString 0, PlaceNameIn
  Q_info.OpenQuery

  Msg = Msg & vbCrLf & _
    "% Запрос" & vbCrLf & _
    "?- " & P_info & "(""" & PlaceNameIn & """, PlaceNameOut, PlaceTypeOut)."
  Msg = Msg & vbCrLf & _
    "% Поиск решений"
  If Not Q_info.EOF Then
    Do Until Q_info.EOF
      Msg = Msg & vbCrLf & _
            "%   " & Tv_info.ReadString(1) & " (" & Tv_info.ReadString(2) & ")"
      Q_info.NextSolution
    Loop
  Else
    Msg = Msg & vbCrLf & "false."
  End If
  Q_info.Close
  Q_info.DestroyObject
  Tv_info.DestroyObject

  pl_Example7 = Title & vbCrLf & Msg
End Function

Function pl_Example8(ByRef PL, ByVal InitStr)
  Dim Title, Msg
  Title = vbCrLf & _
          "%%" & vbCrLf & _
          "% 8. pl_Example8(PL, InitStr)" & vbCrLf & _
          "%      TgsPLClient: LoadScriptByName, ExtractData, MakePredicatesOfDataSet" & vbCrLf & _
          "%      TgsPLTermv: PutInteger, ReadInteger, ReadString" & vbCrLf & _
          "%      TgsPLQuery: OpenQuery, EOF, NextSolution, Close"

  pl_Example8 = ""

  Dim ScriptName
  ScriptName = "pl_Examples_Script"
  If InitStr = "" Then
    If Not PL.LoadScriptByName(ScriptName) Then
      Exit Function
    End If
  End If

  Dim P_rec, Tv_rec, RecNum
  P_rec = "generate_some_rec"
  Set Tv_rec = Designer.CreateObject(3, "TgsPLTermv", "")
  RecNum = 8
  Tv_rec.PutInteger 2, RecNum

  Msg = _
    "% Запрос" & vbCrLf & _
    "?- " & P_rec & "(ID, Name, " & RecNum & ")."

  Dim CDS
  Set CDS = Designer.CreateObject(nil, "TClientDataset", "")
  CDS.FieldDefs.Add "ID", ftInteger, 0, True
  CDS.FieldDefs.Add "Name", ftString, 20, True
  CDS.CreateDataSet
  CDS.Open
  
  Msg = Msg & vbCrLf & _
    "% Заполнение клиентского набора данных из Пролог-запроса"
  Call PL.ExtractData(CDS, P_rec, Tv_rec)
  Msg = Msg & vbCrLf & _
    "% Добавлено записей: " & CDS.RecordCount

  If Not CDS.RecordCount = 0 Then
    Msg = Msg & vbCrLf & _
      "% Считывание клиентского набора данных"
      Msg = Msg & vbCrLf & _
            "%   ID   Name"
    CDS.First
    Do Until CDS.Eof
      Msg = Msg & vbCrLf & _
            "%   " & CDS.FieldByName("ID").AsInteger & _
            "    " & CDS.FieldByName("Name").AsString
      CDS.Next
    Loop
  End If
  Tv_rec.DestroyObject
  
  Dim P_cds, Tv_cds, Q_cds
  P_cds = "gd_some_rec"
  Set Tv_cds = Designer.CreateObject(2, "TgsPLTermv", "")
  Set Q_cds = Designer.CreateObject(nil, "TgsPLQuery", "")
  Q_cds.PredicateName = P_cds
  Q_cds.Termv = Tv_cds

  Dim I, DelCount
  DelCount = 3
  CDS.First
  For I = 1 To DelCount
    CDS.Delete
  Next
  Msg = Msg & vbCrLf & _
    "% Удалено первых записей: " & DelCount

  Msg = Msg & vbCrLf & _
    "% Наполнение базы знаний из клиентского набора данных"
  Dim Ret
  Ret = PL.MakePredicatesOfDataSet(CDS, "ID,Name", P_cds, P_cds, False)

  Msg = Msg & vbCrLf & _
    "% Добавлено фактов " & P_cds & ": " & Ret

  CDS.Close
  CDS.DestroyObject

  Msg = Msg & vbCrLf & _
    "% Запрос" & vbCrLf & _
    "?- " & P_cds & "(ID, Name)"
  Q_cds.OpenQuery

  Msg = Msg & vbCrLf & _
    "% Обработка фактов"
  If Not Q_cds.EOF Then
    While Not Q_cds.EOF
      Msg = Msg & vbCrLf & _
            "%   " & Tv_cds.ReadInteger(0) & ": " & Tv_cds.ReadString(1)
      Q_cds.NextSolution
    Wend
  Else
    Msg = Msg & vbCrLf & "false."
  End If
  Q_cds.Close
  Q_cds.DestroyObject
  Tv_cds.DestroyObject

  pl_Example8 = Title & vbCrLf & Msg
End Function

