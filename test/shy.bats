load test_helper

@test "_detect-env-additions detects added aliases, functions, and variables from sourced files" {
  shy _detect-env-additions source "$FIXTURES_DIR/plugin1.sh"
  assert_equal "plugin1_alias1:plugin1_alias2;plugin1_func1:plugin1_func2;PLUGIN1_VAR1:PLUGIN1_VAR2" "$SHY_TMP_DATA"

  shy _detect-env-additions source "$FIXTURES_DIR/plugin2.sh"
  assert_equal "plugin2_alias1;plugin2_func1;" "$SHY_TMP_DATA"
}

@test "load saves plugin information for first plugin" {
  local plugin_file="$FIXTURES_DIR/plugin1.sh"
  shy load $plugin_file
  assert_equal "plugin1;$plugin_file;plugin1_alias1:plugin1_alias2;plugin1_func1:plugin1_func2;PLUGIN1_VAR1:PLUGIN1_VAR2" "$SHY_PLUGIN_DATA"
}

@test "load saves plugin information for additional plugins" {
  load_plugin plugin1
  local plugin_file="$FIXTURES_DIR/plugin2.sh"
  local new_plugin_data="$SHY_PLUGIN_DATA|plugin2;$plugin_file;plugin2_alias1;plugin2_func1;"

  shy load $plugin_file
  assert_equal "$new_plugin_data" "$SHY_PLUGIN_DATA"

  plugin_file="$FIXTURES_DIR/plugin3.sh"
  new_plugin_data="$SHY_PLUGIN_DATA|plugin3;$plugin_file;plugin3_alias1;;PLUGIN3_VAR1"

  shy load $plugin_file
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

@test "list lists all loaded plugin names" {
  load_plugins plugin1 plugin2 plugin3

  run shy list
  assert_success
  assert_output "plugin1
plugin2
plugin3"
}

@test "show prints info for a plugin" {
  load_plugins plugin1 plugin2 plugin3
  run shy show plugin1
  assert_success
  assert_output "Plugin name: plugin1
Source file: $FIXTURES_DIR/plugin1.sh

== Aliases ==
plugin1_alias1
plugin1_alias2

== Functions ==
plugin1_func1
plugin1_func2

== Variables ==
PLUGIN1_VAR1
PLUGIN1_VAR2"
}

@test "show returns failure status for nonexistent plugin" {
  load_plugins plugin1 plugin2 plugin3
  run shy show bogus_plugin
  assert_failure
  assert_output "Unknown plugin name: bogus_plugin"
}
