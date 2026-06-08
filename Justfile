set dotenv-load := true

default:
	@just --list

test: gdunit

gdunit:
	#!/usr/bin/env bash
	set -euo pipefail

	godot_bin="${GODOT_BIN:-}"
	if [ -z "$godot_bin" ]; then
		for candidate in godot4.7 godot4 godot; do
			if command -v "$candidate" >/dev/null 2>&1; then
				godot_bin="$(command -v "$candidate")"
				break
			fi
		done
	fi

	if [ -z "$godot_bin" ]; then
		echo "Godot binary not found. Set GODOT_BIN=/path/to/godot, or install godot4.7, godot4, or godot on PATH." >&2
		exit 1
	fi

	cd example/game
	./addons/gdUnit4/runtest.sh --godot_binary "$godot_bin" -a res://tests -c
