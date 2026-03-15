# godotproject

## Run Tests

The project includes a lightweight test runner at `res://tests/test_runner.gd`.

### 1) Windows helper script (PowerShell)

```powershell
pwsh -ExecutionPolicy Bypass -File .\tests\run_tests_windows.ps1
```

Optional: pass an explicit executable path.

```powershell
pwsh -ExecutionPolicy Bypass -File .\tests\run_tests_windows.ps1 -GodotPath "C:\Path\To\godot.exe"
```

### 2) Mac helper script (bash)

```bash
bash ./tests/run_tests_mac.sh
```

Optional: pass an explicit executable path as the first argument.

```bash
bash ./tests/run_tests_mac.sh "/Applications/Godot.app/Contents/MacOS/Godot"
```

### 3) Direct Godot CLI

```bash
godot4 --headless --path . --script res://tests/test_runner.gd
```

If `godot4` is not available, use your Godot executable path.

### Godot executable resolution used by helper scripts

The helper scripts try these sources in order:

1. Explicit script argument (`-GodotPath` on Windows, first arg on Mac)
2. `GODOT4_EDITOR_PATH` environment variable
3. `.vscode/settings.json` value for `godotTools.editorPath.godot4` (including `${env:...}`)
4. `godot4` / `godot` from `PATH`
