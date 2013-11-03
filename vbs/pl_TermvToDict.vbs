Option Explicit

Sub pl_TermvToDict(ByRef Tv, ByVal Spec, ByRef Dict)
'
  Dim I, L
  Dim SpecSub, SpecType, SpecKey
  Dim TermType, TermValue, ForAssign

  L = CLng(Tv.Size) - 1
  If Not L = UBound(Spec) Then
    Err.Raise -1, "Размеры вектора термов и массива спецификации не совпадают!"
    Exit Sub
  End If

  For I = 0 To L
    '
    SpecType = ""
    SpecKey = ""
    SpecSub = Split(Spec(I), ":")
    '
    If UBound(SpecSub) = 0 Then
      SpecKey = Spec(I)
    ElseIf UBound(SpecSub) > 0 Then
      SpecType = SpecSub(0)
      SpecKey = SpecSub(1)
    End If
    '
    If Not (SpecType = "-" Or SpecKey = "") Then
      TermType = Tv.DataType(I)
      '
      Select Case TermType
        Case PL_VARIABLE
          ForAssign = False
          '
        Case PL_ATOM, PL_STRING
          If SpecType = "d" Or SpecType = "date" Then
            TermValue = Tv.ReadDate(I)
          Else
            TermValue = Tv.ReadString(I)
          End If
          ForAssign = True
          '
        Case PL_INTEGER
          TermValue = Tv.ReadInteger(I)
          ForAssign = True
          '
        Case PL_FLOAT
          TermValue = Tv.ReadFloat(I)
          ForAssign = True
          '
        Case PL_TERM
          TermValue = Tv.ToString(I)
          ForAssign = True
          '
        Case Else
          TermValue = Tv.ToString(I)
          ForAssign = True
          '
      End Select
      '
      If ForAssign Then
        If Dict.Exists(SpecKey) Then
          Dict(SpecKey) = TermValue
        Else
          Dict.Add SpecKey, TermValue
        End If
      End If
      '
    End If
    '
  Next
'
End Sub

