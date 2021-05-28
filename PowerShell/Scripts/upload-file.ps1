﻿<#
.SYNTAX       upload-file.ps1 [<file>] [<URL>] [<username>] [<password>]
.DESCRIPTION  uploads the local file to the given FTP server
.LINK         https://github.com/fleschutz/PowerShell
.NOTES        Author: Markus Fleschutz / License: CC0
#>

param($File = "", $URL = "", $Username = "", $Password = "")

if ($File -eq "") { $File = read-host "Enter local file to upload" }
if ($URL -eq "") { $URL = read-host "Enter URL of FTP server" }
if ($Username -eq "") { $Username = read-host "Enter username for login" }
if ($Password -eq "") { $Password = read-host "Enter password for login" }
[bool]$EnableSSL = $true
[bool]$UseBinary = $true
[bool]$UsePassive = $true
[bool]$KeepAlive = $true
[bool]$IgnoreCert = $true

try {
	$StopWatch = [system.diagnostics.stopwatch]::startNew()

	# check local file:
	$FullPath = Resolve-Path "$File"
	if (-not(test-path "$FullPath" -pathType leaf)) { throw "Can't access file: $FullPath" }
	$Filename = (Get-Item $FullPath).Name
	$FileSize = (Get-Item $FullPath).Length
	"⏳ Uploading 📄$Filename ($FileSize bytes) to $URL ..."

	# prepare request:
	$Request = [Net.WebRequest]::Create("$URL/$Filename")
	$Request.Credentials = New-Object System.Net.NetworkCredential("$Username", "$Password")
	$Request.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile 
	$Request.EnableSSL = $EnableSSL
	$Request.UseBinary = $UseBinary
	$Request.UsePassive = $UsePassive
	$Request.KeepAlive = $KeepAlive
	[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$IgnoreCert}

	$fileStream = [System.IO.File]::OpenRead("$FullPath")
	$ftpStream = $Request.GetRequestStream()

	$Buf = New-Object Byte[] 32KB
	while (($DataRead = $fileStream.Read($Buf, 0, $Buf.Length)) -gt 0)
	{
	    $ftpStream.Write($Buf, 0, $DataRead)
	    $pct = ($fileStream.Position / $fileStream.Length)
	    Write-Progress -Activity "Uploading" -Status ("{0:P0} complete:" -f $pct) -PercentComplete ($pct * 100)
	}

	# cleanup:
	$ftpStream.Dispose()
	$fileStream.Dispose()

	[int]$Elapsed = $StopWatch.Elapsed.TotalSeconds
	"✔️ uploaded 📄$Filename to $URL in $Elapsed sec."
	exit 0
} catch {
	[int]$Elapsed = $StopWatch.Elapsed.TotalSeconds
	write-error "⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0]) after $Elapsed sec."
	exit 1
}
