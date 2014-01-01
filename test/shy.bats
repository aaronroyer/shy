load test_helper

@test "_detect-env-additions detects added aliases, functions, and variables from sourced files" {
  shy _detect-env-additions source "$FIXTURES_DIR/plugin1.sh"
  assert_equal "plugin1_alias1:plugin1_alias2;plugin1_func1:plugin1_func2;PLUGIN1_VAR1:PLUGIN1_VAR2" "$SHY_TMP_DATA"

  shy _detect-env-additions source "$FIXTURES_DIR/plugin2.sh"
  assert_equal "plugin2_alias1;plugin2_func1;" "$SHY_TMP_DATA"
}

@test "load saves plugin information for first plugin" {
  shy load "$FIXTURES_DIR/plugin1.sh"
  assert_equal "plugin1_alias1:plugin1_alias2;plugin1_func1:plugin1_func2;PLUGIN1_VAR1:PLUGIN1_VAR2" "$SHY_PLUGIN_DATA"
}

@test "load saves plugin information for additional plugins" {
  shy load "$FIXTURES_DIR/plugin1.sh"

  local new_plugin_data="$SHY_PLUGIN_DATA|||plugin2_alias1;plugin2_func1;"

  shy load "$FIXTURES_DIR/plugin2.sh"
  assert_equal "$new_plugin_data" "$SHY_PLUGIN_DATA"

  new_plugin_data="$SHY_PLUGIN_DATA|||plugin3_alias1;;PLUGIN3_VAR1"

  shy load "$FIXTURES_DIR/plugin3.sh"
  assert_equal "$new_plugin_data" "$SHY_PLUGIN_DATA"
}

@test "load returns failure status without a file name" {
  run shy load
  assert_failure "Usage: shy load PLUGIN_NAME"
}

@test "load returns failure status with nonexistent file" {
  local bogus_file="$FIXTURES_DIR/file_that_does_not_exist.sh"
  run shy load "$bogus_file"
  assert_failure "shy: file does not exist: $bogus_file"
}
