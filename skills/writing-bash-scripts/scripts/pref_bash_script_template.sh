#!/usr/bin/env bash
#
# ==============================================================================
# Universal Bash Script Template
# ==============================================================================
# Why: A consistent, defensive template reduces copy/paste bugs and makes scripts
#      easier to operate (clear flags, predictable exits, logging, cleanup).
#
# Copy this file for new scripts, then update the "Script metadata" section.
# ==============================================================================

# ==============================================================================
# Script metadata
# ==============================================================================
# Why: Keep these constants in one place so `--help/--version` stay correct.

readonly SCRIPT_VERSION="0.1.0"
readonly SCRIPT_AUTHOR="Your Name"
readonly SCRIPT_DESCRIPTION="Describe what this script does."

# Why: Prefer BASH_SOURCE for reliable path resolution across invocation modes.
readonly SCRIPT_PATH="${BASH_SOURCE[0]}"
readonly SCRIPT_NAME="${SCRIPT_PATH##*/}"

fct_get_script_dir() {
	# Why: Avoid external tools (dirname/realpath) for portability and speed.
	local source="${SCRIPT_PATH}"
	local dir="${source%/*}"
	if [[ "${dir}" == "${source}" ]]; then
		dir="."
	fi

	(cd "${dir}" >/dev/null 2>&1 && pwd -P)
}
SCRIPT_DIR="$(fct_get_script_dir)"
readonly SCRIPT_DIR

# ==============================================================================
# Runtime options (overridable via CLI flags)
# ==============================================================================
# Why: Defaults allow the template to run out-of-the-box without surprises.

VERBOSE=0
LOG_FILE=""              # When set, logs also append here (without ANSI color codes).
NO_COLOR="${NO_COLOR:-}" # Respect the NO_COLOR convention when already set.

# ==============================================================================
# Internal state (used by traps/cleanup)
# ==============================================================================
# Why: Predeclare variables so `set -u` won't crash cleanup on early exits.

TMP_DIR=""
TMP_PARENT_DIR=""
LOCK_DIR=""
POSITIONAL_ARGS=()

# ==============================================================================
# Execution mode helpers
# ==============================================================================
# Why: Sourcing a script should not change caller options or auto-run main().

IS_SOURCED=0
if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
	IS_SOURCED=1
fi
readonly IS_SOURCED

fct_exit() {
	# Why: Avoid exiting the parent shell when the script is sourced.
	local code="${1:-0}"

	if [[ "${IS_SOURCED}" -eq 1 ]]; then
		return "${code}"
	fi
	exit "${code}"
}

# ==============================================================================
# Logging
# ==============================================================================
# Why: Consistent logs make scripts debuggable in CI and on laptops. Logs go to
#      stderr so stdout can be reserved for machine-readable output.

fct_log() {
	local level="${1}"
	local plain=""
	shift

	plain="$(date '+%Y-%m-%d %H:%M:%S%z') [${SCRIPT_NAME}] ${level}: $*"
	local color_code=""

	case "${level}" in
	DEBUG) color_code='36' ;;
	INFO) color_code='32' ;;
	WARN) color_code='33' ;;
	ERROR) color_code='31' ;;
	*) color_code='' ;;
	esac

	if [[ -n "${color_code}" && -t 2 && -z "${NO_COLOR}" ]]; then
		printf '\033[%sm%s\033[0m\n' "${color_code}" "${plain}" >&2
	else
		printf '%s\n' "${plain}" >&2
	fi

	if [[ -n "${LOG_FILE}" ]]; then
		printf '%s\n' "${plain}" >>"${LOG_FILE}"
	fi
}

log_debug() {
	if [[ "${VERBOSE}" -eq 1 ]]; then
		fct_log "DEBUG" "$@"
	fi
}
log_info() { fct_log "INFO" "$@"; }
log_warn() { fct_log "WARN" "$@"; }
log_error() { fct_log "ERROR" "$@"; }

# ==============================================================================
# Error handling
# ==============================================================================
# Why: Centralize fatal exits for consistent messages and exit codes.

die() {
	local message="${1:-Unknown error}"
	local exit_code="${2:-1}"

	log_error "${message}"
	fct_exit "${exit_code}"
}

fct_prepare_log_file() {
	local path="${1:-}"

	if [[ -z "${path}" ]]; then
		log_error "Option --log-file requires a path."
		return 2
	fi
	if [[ -L "${path}" ]]; then
		log_error "Refusing symlink log file: ${path}"
		return 2
	fi

	if [[ -e "${path}" ]]; then
		if [[ ! -f "${path}" ]]; then
			log_error "Log file must be a regular file: ${path}"
			return 2
		fi
		if ! : >>"${path}"; then
			log_error "Cannot write to log file: ${path}"
			return 1
		fi
	else
		local parent_dir="${path%/*}"
		if [[ "${parent_dir}" == "${path}" ]]; then
			parent_dir="."
		fi
		if [[ ! -d "${parent_dir}" ]]; then
			log_error "Log directory not found: ${parent_dir}"
			return 2
		fi
		if ! (umask 077 && : >"${path}"); then
			log_error "Cannot create log file: ${path}"
			return 1
		fi
	fi

	LOG_FILE="${path}"
	return 0
}

# ==============================================================================
# Usage / version
# ==============================================================================
# Why: A good help block prevents misuse and reduces support/debug time.

usage() {
	cat <<EOF
${SCRIPT_NAME} v${SCRIPT_VERSION}
${SCRIPT_DESCRIPTION}
Author: ${SCRIPT_AUTHOR}

Usage:
  ${SCRIPT_NAME} [options] [--] [args...]

Options:
  -h, --help         Show this help and exit
  -V, --version      Show version and exit
  -v, --verbose      Enable debug logging
      --no-color     Disable colored output (also respects NO_COLOR)
      --log-file P   Append logs to file P (no color codes)

Examples:
  ${SCRIPT_NAME} --help
  ${SCRIPT_NAME} -v --log-file "/tmp/${SCRIPT_NAME}.log" -- arg1 arg2
EOF
}

show_version() {
	printf '%s\n' "${SCRIPT_NAME} v${SCRIPT_VERSION}"
}

# ==============================================================================
# Argument parsing
# ==============================================================================
# Why: Manual parsing keeps long options readable without extra dependencies.
# Returns: 0 to continue, 10 after printing help, 11 after printing version.

fct_parse_arguments() {
	local log_path=""
	local log_status=0

	POSITIONAL_ARGS=()

	while [[ $# -gt 0 ]]; do
		case "$1" in
		-h | --help)
			usage
			return 10
			;;
		-V | --version)
			show_version
			return 11
			;;
		-v | --verbose)
			VERBOSE=1
			shift
			;;
		--no-color)
			NO_COLOR="1"
			shift
			;;
		--log-file | --log-file=*)
			if [[ "$1" == "--log-file" ]]; then
				if [[ $# -lt 2 ]]; then
					log_error "Option --log-file requires a path."
					return 2
				fi
				if [[ "${2}" == -* ]]; then
					log_error "Option --log-file requires a path (got: ${2})."
					return 2
				fi
				log_path="${2}"
				shift 2
			else
				log_path="${1#*=}"
				shift
			fi
			fct_prepare_log_file "${log_path}"
			log_status=$?
			if [[ "${log_status}" -ne 0 ]]; then
				return "${log_status}"
			fi
			;;
		--)
			shift
			POSITIONAL_ARGS+=("$@")
			break
			;;
		-*)
			log_error "Unknown option: $1"
			return 2
			;;
		*)
			POSITIONAL_ARGS+=("$1")
			shift
			;;
		esac
	done

	return 0
}

# ==============================================================================
# Dependency checking
# ==============================================================================
# Why: Fail early with actionable errors when required tools are missing.

fct_require_command() {
	local cmd="${1}"
	local hint="${2:-}"

	if ! command -v "${cmd}" >/dev/null 2>&1; then
		if [[ -n "${hint}" ]]; then
			die "Missing required command: ${cmd}. ${hint}" 4
		fi
		die "Missing required command: ${cmd}." 4
	fi
}

fct_check_dependencies() {
	# Add commands your script needs (examples):
	# fct_require_command "jq" "Install: brew install jq (macOS) or apt-get install jq (Debian/Ubuntu)"
	:
}

# ==============================================================================
# Cleanup & traps
# ==============================================================================
# Why: Always release resources (temp dirs, locks) even on errors or Ctrl+C.

cleanup() {
	local resolved_tmp_dir=""

	# Ensure cleanup never masks the original exit status.
	set +e

	if [[ -n "${LOCK_DIR}" && -d "${LOCK_DIR}" ]]; then
		rmdir -- "${LOCK_DIR}" 2>/dev/null || true
	fi

	if [[ -n "${TMP_DIR}" && -e "${TMP_DIR}" ]]; then
		if [[ "${TMP_DIR}" == /* && -d "${TMP_DIR}" && ! -L "${TMP_DIR}" ]]; then
			resolved_tmp_dir="$(cd -- "${TMP_DIR}" >/dev/null 2>&1 && pwd -P)" || resolved_tmp_dir=""
		fi
		if [[ -n "${resolved_tmp_dir}" && "${resolved_tmp_dir}" == "${TMP_PARENT_DIR%/}/${SCRIPT_NAME}."* ]]; then
			rm -rf -- "${TMP_DIR}" 2>/dev/null || true
		else
			log_warn "Refusing to remove unsafe temp dir path: ${TMP_DIR}"
		fi
	fi

	return 0
}

fct_run_cleanup_on_exit() {
	local exit_status=$?

	trap - EXIT ERR
	cleanup
	exit "${exit_status}"
}

fct_on_error() {
	local exit_status=$?
	local line_no="${1:-?}"

	# Prevent recursive ERR trapping while handling an error.
	trap - ERR

	log_error "Command failed (exit ${exit_status}) at line ${line_no}."
	exit "${exit_status}"
}

fct_on_signal() {
	local signal="${1:-INT}"
	local exit_code=130

	case "${signal}" in
	INT) exit_code=130 ;;
	TERM) exit_code=143 ;;
	*) exit_code=1 ;;
	esac

	trap - INT TERM
	log_warn "Received ${signal}, exiting."
	exit "${exit_code}"
}

fct_setup_traps() {
	trap 'fct_run_cleanup_on_exit' EXIT
	trap 'fct_on_error "${LINENO}"' ERR
	trap 'fct_on_signal INT' INT
	trap 'fct_on_signal TERM' TERM
}

# ==============================================================================
# Main logic
# ==============================================================================
# Why: Keeping business logic in one function improves testability and reuse.

fct_execute_this() {
	# Replace this stub with your script's real work.
	log_info "TODO: implement script logic in fct_execute_this()"

	if [[ ${#POSITIONAL_ARGS[@]} -gt 0 ]]; then
		log_debug "Positional args: ${POSITIONAL_ARGS[*]}"
	fi
}

main() {
	if [[ "${IS_SOURCED}" -eq 1 ]]; then
		log_error "Refusing to run main() while sourced; execute the script instead."
		return 3
	fi

	local parse_status=0
	fct_parse_arguments "$@"
	parse_status=$?
	case "${parse_status}" in
	0)
		:
		;;
	10 | 11)
		return 0
		;;
	*)
		return "${parse_status}"
		;;
	esac

	# Why: Only enable strict mode/traps when executed, not when sourced.
	# -e: Exit on command failure (fail fast; handle expected failures explicitly).
	# -E: Make ERR traps inherit into functions and command substitutions.
	# -u: Error on unset variables (catch typos and missing env/args early).
	# -o pipefail: Pipelines fail if any command fails (not just the last one).
	set -Eeuo pipefail

	fct_setup_traps
	fct_check_dependencies

	TMP_PARENT_DIR="$(cd -- "${TMPDIR:-/tmp}" >/dev/null 2>&1 && pwd -P)" || die "Failed to resolve temp dir base: ${TMPDIR:-/tmp}" 1
	# Why: A temp workspace prevents clobbering user directories and is easy to
	#      tear down via cleanup() on all exit paths.
	TMP_DIR="$(mktemp -d "${TMP_PARENT_DIR}/${SCRIPT_NAME}.XXXXXXXX")" || die "Failed to create temp dir." 1

	log_debug "Script dir: ${SCRIPT_DIR}"
	log_debug "Temp dir: ${TMP_DIR}"
	if [[ -n "${LOG_FILE}" ]]; then
		log_debug "Logging to file: ${LOG_FILE}"
	fi

	fct_execute_this
	log_info "Done."
}

# Why: Avoid side effects when sourced; only auto-run when executed directly.
if [[ "${IS_SOURCED}" -eq 0 ]]; then
	main "$@"
fi
