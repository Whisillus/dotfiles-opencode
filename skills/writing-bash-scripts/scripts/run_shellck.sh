#!/usr/bin/env bash
set -Eeuo pipefail

readonly TOOL_NAME="shellck"
readonly SCRIPT_PATH="${BASH_SOURCE[0]}"

fct_get_script_dir() {
	local source="${SCRIPT_PATH}"
	local dir="${source%/*}"

	if [[ "${dir}" == "${source}" ]]; then
		dir="."
	fi

	(cd -- "${dir}" >/dev/null 2>&1 && pwd -P)
}

SCRIPT_DIR="$(fct_get_script_dir)"
readonly SCRIPT_DIR

fct_print_error() {
	printf '%s: %s\n' "${TOOL_NAME}" "$*" >&2
}

fct_normalize_path() {
	local path="${1}"

	if [[ "${path}" == -* ]]; then
		printf './%s\n' "${path}"
	else
		printf '%s\n' "${path}"
	fi
}

fct_add_file_if_shell() {
	local path="${1}"
	local first_line=""

	case "${path}" in
	*.sh | *.bash | *.zsh | *.command)
		TARGETS+=("${path}")
		return 0
		;;
	*)
		;;
	esac

	[[ -f "${path}" ]] || return 0
	IFS= read -r first_line < "${path}" || true
	if [[ "${first_line}" =~ ^#!.*([[:space:]/]|env[[:space:]]+)(sh|bash|zsh)([[:space:]]|$) ]]; then
		TARGETS+=("${path}")
	fi
}

fct_add_target() {
	local path
	path="$(fct_normalize_path "${1}")"

	if [[ -d "${path}" ]]; then
		# shellcheck disable=SC2312
		while IFS= read -r -d '' file_path; do
			fct_add_file_if_shell "${file_path}"
		done < <(find "${path}" -type f -print0)
		return
	fi
	if [[ -f "${path}" ]]; then
		fct_add_file_if_shell "${path}"
		return
	fi

	fct_print_error "path not found: ${1}"
	exit 2
}

if ! command -v shellcheck >/dev/null 2>&1; then
	fct_print_error "shellcheck not found (install with brew install shellcheck)"
	exit 1
fi

TARGETS=()
if [[ $# -gt 0 ]]; then
	for arg in "$@"; do
		fct_add_target "${arg}"
	done
else
	fct_add_target "${SCRIPT_DIR}"
fi

if [[ ${#TARGETS[@]} -eq 0 ]]; then
	fct_print_error "no shell scripts found"
	exit 0
fi

shellcheck -x -o all -- "${TARGETS[@]}"
