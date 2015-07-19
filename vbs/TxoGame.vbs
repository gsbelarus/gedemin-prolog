Option Explicit

Private Const xoMinSize = 3
Private Const xoMaxSize = 20
Private Const xoMinWinLength = 3
Private Const xoMaxWinLength = 5
Private Const xoMinLevel = 0
Private Const xoMaxLevel = 9
Public Const xoCompMark = "x"
Public Const xoUserMark = "o"
Public Const xoFreeMark = "n"
Public Const xoNormal = "normal"
Public Const xoEcho = "echo"

Class TxoGame
'
  Private FIsInitialised
  Private FPlayCoor(1), FRule
  Private FWinMode, FWinMark
  Private FWinCells()
  '
  Private FPosBegin, FPosEnd, FWinLength, FLevel, FCompMark, FUserMark
  Private FMode, FCurrentMove, FCurrentStep
  '
  Private FPL, FP, FTv, FQ

  Private Sub Class_Initialize
    Set FPL = Designer.CreateObject(nil, "TgsPLClient", "")
    '
    If Not FPL.IsInitialised Then
      FIsInitialised = FPL.Initialise("")
    End If
    
    If FIsInitialised Then
      FIsInitialised = FPL.LoadScriptByName("xo_game")
      Call GetParams
      '
    End If
  End Sub

  ' GetParams
  Private Function GetParams
    FP = "xo_get_params"
    Set FTv = Designer.CreateObject(6, "TgsPLTermv", "")
    '
    GetParams = FPL.Call(FP, FTv)
    If GetParams Then
      Me.PosBegin = FTv.ReadInteger(0)
      Me.PosEnd = FTv.ReadInteger(1)
      Me.WinLength = FTv.ReadInteger(2)
      Me.Level = FTv.ReadInteger(3)
      Me.CompMark = FTv.ReadAtom(4)
      Me.UserMark = FTv.ReadAtom(5)
    Else
      Me.PosBegin = FPosBegin
      Me.PosEnd = FPosEnd
      Me.WinLength = FWinLength
      Me.Level = FLevel
      Me.CompMark = FCompMark
      Me.UserMark = FUserMark
    End If
    '
    Redim FWinCells(FWinLength-1, 1)
    Me.Mode = FMode
    '
    FTv.DestroyObject
  End Function

  ' SetParams
  Private Function SetParams
    FP = "xo_set_params"
    Set FTv = Designer.CreateObject(6, "TgsPLTermv", "")
    '
    FTv.PutInteger 0, FPosBegin
    FTv.PutInteger 1, FPosEnd
    FTv.PutInteger 2, FWinLength
    FTv.PutInteger 3, FLevel
    FTv.PutAtom 4, FCompMark
    FTv.PutAtom 5, FUserMark
    '
    SetParams = FPL.Call(FP, FTv)
    '
    FTv.DestroyObject
  End Function
  
  ' NewGame
  Public Function NewGame
    NewGame = (SetParams And FPL.Call2("xo_init") And GetParams)
    FCurrentMove = Me.StartMove
    FCurrentStep = 1
  End Function

  ' DebugGame
  Public Function DebugGame
    Dim Ret
    FPL.Debug = True
    '
    FP = "xo_cell"
    Set FTv = Designer.CreateObject(2, "TgsPLTermv", "")
    Ret = FPL.SavePredicatesToFile(FP, FTv, FP)
    FP = "xo_solve"
    FTv.Reset
    DebugGame = (Ret And FPL.SavePredicatesToFile(FP, FTv, FP))
    FTv.DestroyObject
    '
    FPL.Debug = False
  End Function

  ' Win
  Public Function Win
    FP = "xo_win"
    Set FTv = Designer.CreateObject(4, "TgsPLTermv", "")
    Set FQ = Designer.CreateObject(nil, "TgsPLQuery", "")
    FQ.PredicateName = FP
    FQ.Termv = FTv
    '
    FQ.OpenQuery
    If Not FQ.EOF Then
      Dim I
      I = 0
      FWinMode = FTv.ReadAtom(0)
      FWinMark = FTv.ReadAtom(1)
      '
      While Not FQ.EOF
        FWinCells(I, 0) = FTv.ReadInteger(2)
        FWinCells(I, 1) = FTv.ReadInteger(3)
        I = I + 1
        FQ.NextSolution
      Wend
      FQ.Close
      '
      Win = True
    Else
      FWinMark = "n"
      '
      Win = False
    End If
    '
    FQ.DestroyObject
    FTv.DestroyObject
  End Function

  ' Tie
  Public Function Tie
    FP = "xo_tie"
    Set FTv = Designer.CreateObject(1, "TgsPLTermv", "")
    FTv.PutAtom 0, FMode
    Tie =  FPL.Call(FP, FTv)
    FTv.DestroyObject
  End Function

  ' Play
  Public Function Play
    FP = "xo_play"
    Set FTv = Designer.CreateObject(4, "TgsPLTermv", "")
    FTv.PutAtom 0, FMode
    Play =  FPL.Call(FP, FTv)
    '
    If Play Then
      FPlayCoor(0) = FTv.ReadInteger(1)
      FPlayCoor(1) = FTv.ReadInteger(2)
      FRule = FTv.ToString(3)
    End If
    '
    FTv.DestroyObject
  End Function

  ' MarkCell
  Public Function MarkCell(X, Y)
    Dim MarkMode
    If Me.CurrentMove = 1 Then
      MarkMode = xoEcho
    Else
      MarkMode = xoNormal
    End If
    '
    FP = "xo_mark_cell"
    Set FTv = Designer.CreateObject(3, "TgsPLTermv", "")
    FTv.PutAtom 0, MarkMode
    FTv.PutInteger 1, CInt(X)
    FTv.PutInteger 2, CInt(Y)
    MarkCell =  FPL.Call(FP, FTv)
    '
    FTv.DestroyObject
  End Function

  ' NextMove
  Public Sub NextMove
    If Me.CurrentMove = 0 Then
      FCurrentMove = 1
    Else
      FCurrentMove = 0
    End If
    '
    If Me.CurrentMove = Me.StartMove Then
       FCurrentStep = Me.CurrentStep + 1
    End If
  End Sub

  ' Rate
  Public Function Rate(Mark, X, Y, Cost)
    FP = "xo_rate"
    Set FTv = Designer.CreateObject(6, "TgsPLTermv", "")
    FTv.PutAtom 0, CStr(Mark)
    FTv.PutInteger 1, CInt(X)
    FTv.PutInteger 2, CInt(Y)
    FTv.PutInteger 3, CInt(Cost)
    '
    If FPL.Call(FP, FTv) Then
      Rate = Array(FTv.ReadInteger(4), FTv.ReadInteger(5))
    End If
    '
    FTv.DestroyObject
  End Function

  ' Review
  Public Function Review(Mark, X, Y, Cost)
    FP = "xo_review"
    Set FTv = Designer.CreateObject(7, "TgsPLTermv", "")
    Set FQ = Designer.CreateObject(nil, "TgsPLQuery", "")
    FQ.PredicateName = FP
    FQ.Termv = FTv
    '
    FTv.PutAtom 0, CStr(Mark)
    FTv.PutInteger 1, CInt(X)
    FTv.PutInteger 2, CInt(Y)
    FTv.PutInteger 3, CInt(Cost)
    '
    Review = ""
    FQ.OpenQuery
    If Not FQ.EOF Then
      '
      While Not FQ.EOF
        Review = Review & _
                 FTv.ReadAtom(4) & "," & _
                 FTv.ReadInteger(5) & "," & _
                 FTv.ReadInteger(6) & ";"
        FQ.NextSolution
      Wend
      FQ.Close
      '
    End If
    '
    FQ.DestroyObject
    FTv.DestroyObject
  End Function

  ' IsInitialised
  Public Property Get IsInitialised
    IsInitialised = FIsInitialised
  End Property

  ' PlayCoor
  Public Property Get PlayCoor
    PlayCoor = FPlayCoor
  End Property

  ' Rule
  Public Property Get Rule
    Rule = FRule
  End Property

  ' WinMode
  Public Property Get WinMode
    WinMode = FWinMode
  End Property

  ' WinMark
  Public Property Get WinMark
    WinMark = FWinMark
  End Property

  ' WinCells
  Public Property Get WinCells
    WinCells = FWinCells
  End Property

  Public Property Get PosBegin
    PosBegin = FPosBegin
  End Property
  ' PosBegin
  Public Property Let PosBegin(Value)
    If Not IsEmpty(Value) And IsNumeric(Value) Then
      Value = CInt(Value)
      If Not _
         ( Value < 0 Or Value > 1 Or _
           (FPosEnd - Value + 1) > xoMaxSize Or _
           (FPosEnd - Value + 1) < xoMinSize ) Then
        FPosBegin = Value
      Else
        FPosBegin = 0
        FPosEnd = xoMinSize - 1
      End If
    Else
      FPosBegin = 0
      FPosEnd = xoMinSize - 1
    End If
  End Property

  Public Property Get PosEnd
    PosEnd = FPosEnd
  End Property
  ' PosEnd
  Public Property Let PosEnd(Value)
    If Not IsEmpty(Value) And IsNumeric(Value) Then
      Value = CInt(Value)
      If Not _
         ( (Value - FPosBegin + 1) > xoMaxSize Or _
           (Value - FPosBegin + 1) < xoMinSize ) Then
        FPosEnd = Value
      Else
        FPosBegin = 0
        FPosEnd = xoMinSize - 1
      End If
    Else
      FPosBegin = 0
      FPosEnd = xoMinSize - 1
    End If
  End Property

  Public Property Get WinLength
    WinLength = FWinLength
  End Property
  ' WinLength
  Public Property Let WinLength(Value)
    If Not IsEmpty(Value) And IsNumeric(Value) Then
      Value = CInt(Value)
      If Not _
         ( Value < xoMinWinLength Or Value > xoMaxWinLength Or _
           (FPosEnd - FPosBegin + 1) < Value ) Then
        FWinLength = Value
      Else
        FWinLength = (FPosEnd - FPosBegin + 1)
      End If
    Else
      FWinLength = (FPosEnd - FPosBegin + 1)
    End If
  End Property

  Public Property Get Level
    Level = FLevel
  End Property
  ' Level
  Public Property Let Level(Value)
    If Not IsEmpty(Value) And IsNumeric(Value) Then
      Value = CInt(Value)
      If Not (Value > xoMaxLevel Or FLevel < xoMinLevel) Then
        FLevel = Value
      Else
        FLevel = xoMinLevel
      End If
    Else
      FLevel = xoMinLevel
    End If
  End Property

  Public Property Get CompMark
    CompMark = FCompMark
  End Property
  ' CompMark
  Public Property Let CompMark(Value)
    If Not IsEmpty(Value) Then
      Select Case Value
        Case xoCompMark, xoUserMark
          FCompMark = Value
        Case Else
          FCompMark = xoCompMark
      End Select
    Else
      FCompMark = xoCompMark
    End If
  End Property

  Public Property Get UserMark
    UserMark = FUserMark
  End Property
  ' UserMark
  Public Property Let UserMark(Value)
    If Not IsEmpty(Value) Then
      Select Case Value
        Case xoCompMark, xoUserMark
          FUserMark = Value
        Case Else
          FUserMark = xoUserMark
      End Select
    Else
      FUserMark = xoUserMark
    End If
  End Property

  Public Property Get StartMove
    If FUserMark = xoCompMark Then
      StartMove = 1
    Else
      StartMove = 0
    End If
  End Property
  ' StartMove
  Public Property Let StartMove(Value)
    If Not IsEmpty(Value) And IsNumeric(Value) Then
      Value = CInt(Value)
      If Value = 1 Then
        FUserMark = xoCompMark
        FCompMark = xoUserMark
      Else
        FCompMark = xoCompMark
        FUserMark = xoUserMark
      End If
    End If
  End Property

  ' CurrentMove
  Public Property Get CurrentMove
    If IsEmpty(FCurrentMove) Then
      FCurrentMove = Me.StartMove
    End If
    '
    CurrentMove = FCurrentMove
  End Property

  ' CurrentStep
  Public Property Get CurrentStep
    If IsEmpty(FCurrentStep) Then
      FCurrentStep = 1
    End If
    '
    CurrentStep = FCurrentStep
  End Property

  ' CurrentMark
  Public Property Get CurrentMark
    If Me.CurrentMove = Me.StartMove Then
      CurrentMark = xoCompMark
    Else
      CurrentMark = xoUserMark
    End If
  End Property

  Public Property Get Mode
    Mode = FMode
  End Property
  ' Mode
  Public Property Let Mode(Value)
    If Not IsEmpty(Value) Then
      Select Case Value
        Case xoNormal, xoEcho
          FMode = Value
        Case Else
          FMode = xoNormal
      End Select
    Else
      FMode = xoNormal
    End If
  End Property

  Private Sub Class_Terminate
    FPL.DestroyObject
  End Sub
'
End Class

