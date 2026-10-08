$ErrorActionPreference = "Stop"


# PureBasic versions used for unit tests 
$Compilers = [ordered]@{
	"x86" = @(
		@{ Name = "5.73"; Path = "C:\Program Files (x86)\PureBasic_573"; Backends = @("ASM") },
		@{ Name = "6.21"; Path = "C:\Program Files (x86)\PureBasic_621"; Backends = @("ASM", "C") },
		@{ Name = "6.40"; Path = "C:\Program Files (x86)\PureBasic_640"; Backends = @("ASM", "C") }
	)
	"x64" = @(
		@{ Name = "5.73"; Path = "C:\Program Files\PureBasic_573"; Backends = @("ASM") },
		@{ Name = "6.21"; Path = "C:\Program Files\PureBasic_621"; Backends = @("ASM", "C") },
		@{ Name = "6.40"; Path = "C:\Program Files\PureBasic_640"; Backends = @("ASM", "C") }
	)
	"arm64" = @()
}

# Standard compiler executables.
$CompilerExecutables = @{
	"ASM" = "pbcompiler.exe"
	"C"   = "pbcompilerc.exe"
}


# Prompts for a choice and used `&` for the hotkey.
function Select-Choice([string]$Title, [string[]]$Labels) {
	$Choices = $Labels | ForEach-Object { New-Object System.Management.Automation.Host.ChoiceDescription $_ }
	$Index = $Host.UI.PromptForChoice($Title, "", $Choices, 0)
	return $Labels[$Index].Replace("&", "")
}


$Architecture = Select-Choice "Architecture" @("x&86", "x&64", "&arm64")
$Backend = Select-Choice "Backend" @("&ASM", "&C")

$SelectedCompilers = @($Compilers[$Architecture] | Where-Object { $_.Backends -contains $Backend })
if ($SelectedCompilers.Count -eq 0) {
	throw "No compilers configured for $Architecture with the $Backend backend."
}

$UnitTests = Get-ChildItem -Path (Join-Path $PSScriptRoot "UnitTests") -Recurse -Filter "*.pb"

$BuildDir = Join-Path ([System.IO.Path]::GetTempPath()) "PB-Endianness"
New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

foreach ($Compiler in $SelectedCompilers) {
	$CompilerExe = Join-Path $Compiler.Path "Compilers\$($CompilerExecutables[$Backend])"
	if (-not (Test-Path $CompilerExe)) {
		throw "Compiler not found: $CompilerExe"
	}

	Write-Host "`n=== PureBasic $($Compiler.Name) - $Architecture - $Backend ===" -ForegroundColor Cyan

	foreach ($UnitTest in $UnitTests) {
		$Exe = Join-Path $BuildDir "$($UnitTest.BaseName).exe"
		
		$CompilerOutput = & $CompilerExe $UnitTest.FullName /CONSOLE /EXE $Exe | Out-String
		if ($LASTEXITCODE -ne 0) {
			throw "Compilation failed: $($UnitTest.Name) with PureBasic $($Compiler.Name)`n$CompilerOutput"
		}

		Write-Host "> $($UnitTest.Name)"
		& $Exe
		if ($LASTEXITCODE -ne 0) {
			Write-Host "FAILED (exit code $LASTEXITCODE)" -ForegroundColor Red
		} else {
			Write-Host "PASSED" -ForegroundColor Green
		}
	}
}

Write-Host ""
Pause
