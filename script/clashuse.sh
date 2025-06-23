function _clash_set_env() {
  local auth=$(sudo "$BIN_YQ" '.authentication[0] // ""' "$CLASH_CONFIG_RUNTIME")
  [ -n "$auth" ] && auth=$auth@
  local http_proxy_addr="http://${auth}127.0.0.1:${MIXED_PORT}"
  local socks_proxy_addr="socks5h://${auth}127.0.0.1:${MIXED_PORT}"
  local no_proxy_addr="localhost,127.0.0.1,::1"

  export http_proxy=$http_proxy_addr
  export https_proxy=$http_proxy
  export HTTP_PROXY=$http_proxy
  export HTTPS_PROXY=$http_proxy

  export all_proxy=$socks_proxy_addr
  export ALL_PROXY=$all_proxy

  export no_proxy=$no_proxy_addr
  export NO_PROXY=$no_proxy
}
function _clash_unset_env() {
    unset http_proxy
    unset https_proxy
    unset HTTP_PROXY
    unset HTTPS_PROXY
    unset all_proxy
    unset ALL_PROXY
    unset no_proxy
    unset NO_PROXY
}
withclash() {
  # Proxy settings — adjust as needed
  # Check if a command was provided
  if [ "$#" -eq 0 ]; then
    echo "Usage: withclash <command> [args...]" >&2
    return 1
  fi

  # Set proxy environment variables
  _clash_set_env >&/dev/null

  # Run the command — stdin/stdout/stderr are passed through transparently
  "$@"

  # Capture exit code before unsetting
  local EXIT_CODE=$?

  # Unset proxy environment variables
  _clash_unset_env
 >&/dev/null
  return $EXIT_CODE
}
_get_proxy_port

