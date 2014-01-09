
# Guard against bats executing this twice
if [ -z "$TEST_PATH_INITIALIZED" ]; then
  export TEST_PATH_INITIALIZED=true

  PATH=/usr/bin:/bin:/usr/sbin:/sbin
  PATH="$(dirname $BATS_TEST_DIRNAME):$PATH"

  export FIXTURES_DIR="$BATS_TEST_DIRNAME/fixtures"
  export SHY_CACHE_DIR="$BATS_TMPDIR/.shy_plugin_cache"
fi

eval "$(shy init)"

setup() {
  unset SHY_PLUGIN_DATA
  unset SHY_TMP_DATA

  if [ -d "$SHY_CACHE_DIR" ]; then
    find "$SHY_CACHE_DIR" -type f -exec rm {} \;
  else
    mkdir "$SHY_CACHE_DIR"
  fi
}

flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed "s:${BATS_TEST_DIRNAME}:TEST_DIR:g" >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    flunk "command failed with exit status $status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    flunk "expected failed exit status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_output() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
  else expected="$1"
  fi
  assert_equal "$expected" "$output"
}

load_plugins() {
  for arg in "$@"; do
    shy load "$FIXTURES_DIR/$arg.sh"
  done
}

load_plugin() {
  load_plugins "$@"
}

make_modified_in_past() {
  local current_timestamp=$(date +%Y%m%d%H%M)
  local past_timestamp=$(expr $current_timestamp - 10)
  touch -t $past_timestamp "$1"
}
