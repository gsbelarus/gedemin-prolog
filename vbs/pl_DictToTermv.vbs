Option Explicit

Sub pl_DictToTermv(ByRef Dict, ByVal Spec, ByRef Tv)
'
  Dim I, L
  Dim SpecSub, SpecType, SpecKey

  L = CLng(Tv.Size) - 1
  If Not L = UBound(Spec) Then
    Err.Raise -1, "Размеры массива спецификации и вектора термов не совпадают!"
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
    If Not (SpecType = "-" Or SpecKey = "") _
        And Dict.Exists(SpecKey) _
          Then
      '
      Select Case SpecType
        Case "a", "atom"
          Tv.PutAtom I, CStr(Dict(SpecKey))
          '
        Case "d", "date"
          Tv.PutDate I, CDate(Dict(SpecKey))
          '
        Case "f", "float"
          Tv.PutFloat I, CDbl(Dict(SpecKey))
          '
        Case "i", "integer"
          Tv.PutInteger I, CLng(Dict(SpecKey))
          '
        Case "s", "string"
          Tv.PutString I, CStr(Dict(SpecKey))
          '
        Case "v", "variable"
          Tv.PutVariable I
          '
        Case Else
          '
      End Select
      '
    End If
    '
  Next
'
End Sub

