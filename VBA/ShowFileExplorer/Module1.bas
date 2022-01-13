Attribute VB_Name = "Module1"
Sub ShowFileExplorer()
    Call GetFile
End Sub

Public Function GetFile() As String

Dim tryAgain As Boolean, tempFile As String
Dim FD As Office.FileDialog
Set FD = Application.FileDialog(msoFileDialogFilePicker)

With FD
    .Title = "Please select a file to import."
    .AllowMultiSelect = False
    With .Filters
        .Clear
        .Add "Schedule File", "*.xlsx"
    End With
    .InitialFileName = "C:\Users\" & Environ$("UserName") & "\Desktop\"
   
    If .Show Then
        tempFile = .SelectedItems(1)
    End If
End With

'Returns "" if no file selected
GetFile = tempFile

Set FD = Nothing

End Function

Public Function ReadFile(File As String) As String

'Use late binding so reference doesn't need to be explicitly set in project
Dim FSO As Object, TS As Object

Set FSO = CreateObject("Scripting.FileSystemObject")
Set TS = FSO.GetFile(File).OpenAsTextStream(1, -2)

ReadFile = TS.ReadAll

TS.Close
Set TS = Nothing
Set FSO = Nothing

End Function

Public Function SaveCurrent()
    ActiveWorkbook.SaveAs ActiveWorkbook.FullName
End Function

