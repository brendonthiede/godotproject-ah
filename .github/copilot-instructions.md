# Copilot Instructions for This Repository

## Project Snapshot
- Engine: Godot 4.6 (see project.godot features).
- Primary scene: res://level.tscn.
- Active player scene: res://player_1.tscn (CharacterBody3D-based).
- There is a custom editor addon at res://addons/godot_mcp for MCP/WebSocket command handling.

## High-Value Working Rules
- Prefer targeted, minimal edits. Do not broadly reserialize .tscn files unless explicitly asked.
- Do not hand-edit massive PackedVector arrays or generated collision data in scene files.
- Keep gameplay logic in external .gd files when possible instead of embedding long script/source blocks inside .tscn.
- Preserve existing node names and paths unless a rename is required, because animations and scripts rely on fixed NodePath values.
- For addon changes, keep @tool compatibility and EditorPlugin lifecycle behavior intact.

## Input and Movement Conventions
- Existing InputMap includes custom actions: w, a, s, d, shift, jump, f.
- Some scripts also reference legacy/default actions (ui_left, ui_right, move_forward, turn_left, turn_right).
- When adding or changing controls, update project.godot InputMap and all affected scripts together.
- Prefer physics-safe movement patterns (velocity + move_and_slide/apply forces) over direct transform/position changes during physics unless intentionally arcade-like.

## Addon Architecture Notes
- Entry point: res://addons/godot_mcp/mcp_server.gd (EditorPlugin + TCP/WebSocket handling).
- Command dispatch: res://addons/godot_mcp/command_handler.gd.
- Command processors derive from res://addons/godot_mcp/commands/base_command_processor.gd.
- Keep command responses consistent with current JSON shape:
  - Success: {"status":"success","result":...}
  - Error: {"status":"error","message":...}
- Keep commandId passthrough behavior for request/response correlation.

## Scene Editing Guidance
- If a scene has embedded scripts, prefer extracting to dedicated .gd files when making substantial logic changes.
- Avoid moving nodes that are referenced by AnimationPlayer track paths unless you also update those paths.
- When creating nodes via code/editor automation, ensure owner is set to the edited scene root so nodes serialize correctly.

## Code Style
- Use typed GDScript where practical (typed params/returns for public and physics methods).
- Keep functions focused; avoid monolithic _physics_process logic when adding new features.
- Use clear constants for tunable gameplay values.
- Limit noisy debug print statements in runtime gameplay loops.

## Validation Checklist After Changes
- Open the project in Godot and ensure scenes load without parser errors.
- Verify edited scripts attach correctly and no missing resource paths were introduced.
- Test player movement, jump behavior, and camera behavior in the main level.
- If addon code changed, verify plugin still initializes and command responses are emitted.
- Re-check InputMap actions if any control-related code was touched.

## Suggested Refactor Priorities (When Requested)
- Normalize action names to one input scheme and remove stale action references.
- Move large embedded scripts from .tscn files into versionable .gd files.
- Add lightweight smoke tests/check scripts for plugin command processor behavior.
