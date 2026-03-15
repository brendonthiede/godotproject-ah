#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

GODOT_PATH="${1:-${GODOT4_EDITOR_PATH:-}}"

resolve_from_settings() {
  local settings_file="${PROJECT_DIR}/.vscode/settings.json"
  if [[ ! -f "${settings_file}" ]]; then
    return 1
  fi

  local raw_setting
  raw_setting="$(grep -E '"godotTools\.editorPath\.godot4"\s*:' "${settings_file}" | sed -E 's/.*"godotTools\.editorPath\.godot4"\s*:\s*"([^"]+)".*/\1/' || true)"

  if [[ -z "${raw_setting}" ]]; then
    return 1
  fi

  if [[ "${raw_setting}" =~ ^\$\{env:([^}]+)\}$ ]]; then
    local env_name="${BASH_REMATCH[1]}"
    local env_value="${!env_name:-}"
    if [[ -n "${env_value}" ]]; then
      printf '%s' "${env_value}"
      return 0
    fi
    return 1
  fi

  printf '%s' "${raw_setting}"
}

if [[ -z "${GODOT_PATH}" ]]; then
  GODOT_PATH="$(resolve_from_settings || true)"
fi

if [[ -z "${GODOT_PATH}" ]]; then
  if command -v godot4 >/dev/null 2>&1; then
    GODOT_PATH="$(command -v godot4)"
  elif command -v godot >/dev/null 2>&1; then
    GODOT_PATH="$(command -v godot)"
  fi
fi

if [[ -z "${GODOT_PATH}" ]]; then
  echo "Could not resolve Godot executable. Set GODOT4_EDITOR_PATH, pass it as arg1, or configure .vscode/settings.json." >&2
  exit 1
fi

LOG_PATH="${PROJECT_DIR}/tests/test_run.log"
rm -f "${LOG_PATH}"

"${GODOT_PATH}" --headless --path "${PROJECT_DIR}" --script "res://tests/test_runner.gd" --log-file "${LOG_PATH}"

if [[ -f "${LOG_PATH}" ]]; then
  cat "${LOG_PATH}"
fi