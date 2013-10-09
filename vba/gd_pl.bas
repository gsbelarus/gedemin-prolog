Option Explicit

Const PL_VARIABLE = 1
Const PL_ATOM = 2
Const PL_INTEGER = 3
Const PL_FLOAT = 4
Const PL_STRING = 5
Const PL_TERM = 6

Sub gd_test()
    Dim Gedemin, PL, Tv, Ret
    
    Set Gedemin = CreateObject("Gedemin.gsGedeminApplication")
    Set PL = Gedemin.Designer.CreateObject(Null, "TgsPLClient", "")
    
    Ret = PL.Initialise("")
    If Not Ret Then
        Debug.Print "Gedemin-Prolog: Initialise failed"
    End If
    
    Set Tv = Gedemin.Designer.CreateObject(2, "TgsPLTermv", "")
    
    Tv.PutAtom 0, "resource_database"
    Ret = PL.Call("current_prolog_flag", Tv)
        
    If Ret Then
        Ret = Tv.DataType(1)
        Select Case Ret
            Case PL_VARIABLE, PL_ATOM, PL_INTEGER, PL_FLOAT, PL_STRING, PL_TERM
                Debug.Print "Type " & Ret
            Case Else
                Debug.Print "Gedemin-Prolog: undefined type"
        End Select
        Ret = Tv.ToString(1)
        Debug.Print Ret
    Else
        Debug.Print "Gedemin-Prolog: Call failed"
    End If
    
    Gedemin.Designer.DestroyObject Tv
    Gedemin.Designer.DestroyObject PL
End Sub
