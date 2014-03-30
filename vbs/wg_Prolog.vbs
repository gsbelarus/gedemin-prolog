Option Explicit

Function wg_Prolog
  If Not Assigned(wg_Prolog_) Then
    Set wg_Prolog_ = New Twg_Prolog
  end if

  Set wg_Prolog = wg_Prolog_
End Function
