#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=rapp.ico
#AutoIt3Wrapper_Outfile_x64=rapp.exe
#AutoIt3Wrapper_Res_Fileversion=0.0.3.0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <TrayConstants.au3>
#include <WinAPI.au3>

; Options:
; 1 - do not show default AutoIt menu
; 2 - items will not automatically check/uncheck when clicked
Opt("TrayMenuMode", 1 + 2)
Opt("TrayOnEventMode", 1)

Dim $showProcesses[1][2]
Dim $ignoreProcesses = ProcessList()

main()

Func main()
	Dim $en[10]
	Dim $ru[10]

	$en[0] = "Exit"
	$ru[0] = "Выход"
	$en[1] = "Recent apps"
	$ru[1] = "Недавние приложения"

	Local $loc
	If @OSLang == "0419" Then
		$loc = $ru
	Else
		$loc = $en
	EndIf

    TrayCreateItem($loc[0])
	TrayItemSetOnEvent(-1, "close")
    TrayCreateItem("")

    TraySetState($TRAY_ICONSTATE_SHOW)

	TraySetToolTip($loc[1])

	Local $procFilename

    While 1
		Sleep(2000)

		Local $currentProcesses = ProcessList()
		For $curProc = 1 to $currentProcesses[0][0]
			For $ignProc = 1 to $ignoreProcesses[0][0]
				If $currentProcesses[$curProc][0] == $ignoreProcesses[$ignProc][0] Then
					ContinueLoop 2
				EndIf
			Next

			For $showProc = 1 to UBound($showProcesses) - 1
				If $currentProcesses[$curProc][0] == $showProcesses[$showProc][0] Then
					ContinueLoop 2
				EndIf
			Next

			$procFilename = _WinAPI_GetProcessFileName($currentProcesses[$curProc][1])

			If _
				$procFilename == "" Or _										; ignore empty process filenames
				StringMid($procFilename, 2, 19) == ":\Windows\System32\" Then	; ignore executables from folder "?:\Windows\System32\"
					ReDim $ignoreProcesses[UBound($ignoreProcesses) + 1][2]
					$ignoreProcesses[UBound($ignoreProcesses) - 1][0] = $currentProcesses[$curProc][0]
					$ignoreProcesses[0][0] += 1
					ContinueLoop
			EndIf

			ReDim $showProcesses[UBound($showProcesses) + 1][2]
			$showProcesses[UBound($showProcesses) - 1][0] = $currentProcesses[$curProc][0]
			$showProcesses[UBound($showProcesses) - 1][1] = $procFilename

			If StringRight($currentProcesses[$curProc][0], 4) == '.exe' Or StringRight($currentProcesses[$curProc][0], 4) == '.EXE' Then
				$procName = StringTrimRight($currentProcesses[$curProc][0], 4)
			Else
				$procName = $currentProcesses[$curProc][0]
			EndIf

			TrayCreateItem($procName)
			TrayItemSetOnEvent(-1, "go")
		Next
    WEnd
EndFunc

Func go()
	If @TRAY_ID > 8 Then
		Run($showProcesses[@TRAY_ID - 8][1])
	EndIf
EndFunc

Func close()
	Exit
EndFunc
