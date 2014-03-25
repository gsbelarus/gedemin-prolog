Option Explicit

Sub Gedemin_Prolog_test()
  Dim C, PL, Tv, Ret, PL1

  Set C = New TCreator

  Set PL = C.GetObject(nil, "TgsPLClient", "")
  Ret = PL.Initialise("")
  Ret = PL.IsInitialised()
  
  Set PL1 = C.GetObject(nil, "TgsPLClient", "")
  Ret = PL1.Initialise("")
  Ret = PL1.IsInitialised()

  Set Tv = C.GetObject(2, "TgsPLTermv", "")
  Tv.PutAtom 0, "generate_debug_info"
  Ret = PL.Call("current_prolog_flag", Tv)
  Ret = Tv.ReadAtom(1)
  Set PL = Nothing

  Tv.Reset
  Tv.PutAtom 0, "dialect"
  Ret = PL1.Call("current_prolog_flag", Tv)
  Ret = Tv.ReadAtom(1)
  Ret = PL1.IsInitialised()

  Exit Sub
  
  Ret = PL.Call2( _
    "['d:/latunov/pl/twg_avg_wage1']," + _
    " avg_wage_in, avg_wage, avg_wage_kb, avg_wage," + _
    " avg_wage_out, avg_wage_clean.")
End Sub
