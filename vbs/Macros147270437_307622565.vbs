'#include wg_pu1_Create
'#include wg_pu2_Create
'#include wg_pu3_Create_pl
'#include wg_pu6_Create
option explicit
sub Macros147270437_307622565(OwnerForm)
 ' Вызов формы для запроса параметров формирования данных
  dim F
  set F = Application.FindComponent("usrf_wg_EnterParametersDPU")
  if not Assigned(f) then
    set f = Designer.CreateObject(Application, "usrf_wg_EnterParametersDPU", "usrf_wg_EnterParametersDPU")
  end if

  dim TypeOfForm
  if F.ShowModal = mrOk then
    TypeOfForm = f.GetComponent("usrg_ComboBox1").ItemIndex
    select case TypeOfForm
      case 0 ' Заполнение данными форм ПУ - 1
        call wg_pu1_Create(f)
      case 1 ' Заполнение данными форм ПУ - 2
        call wg_pu2_Create(f)
      case 2 ' Заполнение данными форм ПУ - 3
        call wg_pu3_Create_pl(f)
      case 3 ' Заполнение данными форм ПУ - 6
        call wg_pu6_Create(f)
    end select
  end if
  Designer.DestroyObject(F)
end sub
