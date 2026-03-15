param(
	[string]$GodotPath = "",
	[string]$ProjectPath = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
	$ProjectPath = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
}

function Resolve-GodotPath {
	param(
		[string]$RootPath,
		[string]$CliGodotPath
	)

	if (-not [string]::IsNullOrWhiteSpace($CliGodotPath)) {
		return $CliGodotPath
	}

	if ($env:GODOT4_EDITOR_PATH) {
		return $env:GODOT4_EDITOR_PATH
	}

	$settingsPath = Join-Path $RootPath ".vscode/settings.json"
	if (Test-Path $settingsPath) {
		$settingsRaw = Get-Content -Path $settingsPath -Raw
		$settingMatch = [regex]::Match($settingsRaw, '"godotTools\.editorPath\.godot4"\s*:\s*"([^"]+)"')
		if ($settingMatch.Success) {
			$settingValue = $settingMatch.Groups[1].Value
			$envMatch = [regex]::Match($settingValue, '^\$\{env:([^}]+)\}$')
			if ($envMatch.Success) {
				$envVarName = $envMatch.Groups[1].Value
				$envValue = [Environment]::GetEnvironmentVariable($envVarName)
				if (-not [string]::IsNullOrWhiteSpace($envValue)) {
					return $envValue
				}
			} elseif (-not [string]::IsNullOrWhiteSpace($settingValue)) {
				return $settingValue
			}
		}
	}

	$cmd = Get-Command godot4, godot -ErrorAction SilentlyContinue | Select-Object -First 1
	if ($cmd) {
		return $cmd.Source
	}

	return ""
}

$resolvedGodotPath = Resolve-GodotPath -RootPath $ProjectPath -CliGodotPath $GodotPath
if ([string]::IsNullOrWhiteSpace($resolvedGodotPath)) {
	Write-Error "Could not resolve Godot executable. Set GODOT4_EDITOR_PATH, pass -GodotPath, or configure .vscode/settings.json."
}

$logPath = Join-Path $ProjectPath "tests/test_run.log"
if (Test-Path $logPath) {
	Remove-Item $logPath
}

$process = Start-Process `
	-FilePath $resolvedGodotPath `
	-ArgumentList @("--headless", "--path", $ProjectPath, "--script", "res://tests/test_runner.gd", "--log-file", $logPath) `
	-Wait `
	-PassThru

if (Test-Path $logPath) {
	Get-Content $logPath
}

exit $process.ExitCode