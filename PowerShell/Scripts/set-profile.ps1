﻿<#
.SYNTAX       set-profile.ps1
.DESCRIPTION  sets the PowerShell profile for the current user
.LINK         https://github.com/fleschutz/PowerShell
.NOTES        Author: Markus Fleschutz / License: CC0
#>

try {
	$PathToProfile = $PROFILE.CurrentUserCurrentHost
	$PathToRepo = "$PSScriptRoot/.."

	copy-item "$PathToRepo/Scripts/my-profile.ps1" "$PathToProfile" -force

	"✔️ updated PowerShell profile 'CurrentUserCurrentHost' by my-profile.ps1 - it gets active on next login"
	exit 0
} catch {
	write-error "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
}
