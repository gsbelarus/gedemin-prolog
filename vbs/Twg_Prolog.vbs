Option Explicit

Class Twg_Prolog
'
  Private VarSyncField
  
  Private Sub Class_Initialize
    VarSyncField = "PrologSyncField"
  End Sub

  Private Sub Class_Terminate
    Set wg_Prolog_ = Nothing
  End Sub
  
  Public Sub SyncField(ByRef Sender, ByVal Allow)
    If Not Sender.VariableExists(VarSyncField) Then
      Sender.AddVariableItem(VarSyncField)
      Sender.AddVariableItem(VarSyncField) = False
    End If
    '
    Sender.AddVariableItem(VarSyncField) = Allow
  End Sub
  
  Public Function SyncField_Name(ByRef Sender, ByVal FieldName)
    If Not Sender.VariableExists(VarSyncField) Then
      Sender.AddVariableItem(VarSyncField)
      Sender.AddVariableItem(VarSyncField) = False
    End If
    '
    If Sender.AddVariableItem(VarSyncField) = True Then
      SyncField_Name = ""
    Else
      SyncField_Name = FieldName
    End If
  End Function
'
End Class
