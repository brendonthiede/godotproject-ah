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

### Troubleshooting

1. `Could not resolve Godot executable`
    - Set `GODOT4_EDITOR_PATH` to your Godot binary path.
    - Or pass the executable explicitly (`-GodotPath` on Windows, first arg on Mac).
    - Or set `godotTools.editorPath.godot4` in `.vscode/settings.json`.
2. Script runs but tests do not start
    - Make sure you run from the project root so `--path .` resolves correctly.
    - Verify `tests/test_runner.gd` exists.
3. macOS permission denied on script
    - Run with `bash ./tests/run_tests_mac.sh`.
    - Or make it executable: `chmod +x ./tests/run_tests_mac.sh`.
4. `godot4` command not found
    - Install Godot CLI or add Godot to `PATH`.
    - Use full executable path as a fallback.

### CI usage

For CI runners, call the platform helper script directly.

Windows runner:

```powershell
pwsh -ExecutionPolicy Bypass -File .\tests\run_tests_windows.ps1
```

macOS runner:

```bash
bash ./tests/run_tests_mac.sh
```

Both scripts return the Godot process exit code, so CI will fail automatically when tests fail.
