load test_helper

@test "_detect-env-additions detects added aliases, functions, and variables from sourced files" {
  shy _detect-env-additions source "$FIXTURES_DIR/plugin1.sh"
  assert_equal "plugin1_alias1:plugin1_alias2;plugin1_func1:plugin1_func2;PLUGIN1_VAR1:PLUGIN1_VAR2" "$SHY_TMP_DATA"

  shy _detect-env-additions source "$FIXTURES_DIR/plugin2.sh"
  assert_equal "plugin2_alias1;plugin2_func1;" "$SHY_TMP_DATA"
}

@test "_write_cache writes plugin cache for plugin file path" {
  local plugin_file='/Users/aaron/.shell.d/plugin2.sh'
  local plugin_content='plugin2_alias1;plugin2_func1;'
  local cached_plugin_file="$SHY_CACHE_DIR/plugin2"
  [ -d "$SHY_CACHE_DIR" ] && rmdir "$SHY_CACHE_DIR"

  run shy _write_cache $plugin_file "$plugin_content"
  assert_success
  [ -d "$SHY_CACHE_DIR" ]

  assert_equal $plugin_content "$(cat $cached_plugin_file)"
}

@test "_read_cache reads plugin cache for plugin file path, if fresh" {
  local plugin_file="$BATS_TMPDIR/plugin2.sh"
  cat "$FIXTURES_DIR/plugin1.sh" > $plugin_file
  local plugin_content='plugin2_alias1;plugin2_func1;'
  local cached_plugin_file="$SHY_CACHE_DIR/plugin2"
  echo $plugin_content > "$cached_plugin_file"

  make_modified_in_past $plugin_file
  touch $cached_plugin_file

  run shy _read_cache $plugin_file
  assert_success
  assert_output $plugin_content
}

@test "_read_cache does not read plugin cache for plugin file path, if stale" {
  local plugin_file="$BATS_TMPDIR/plugin2.sh"
  cat "$FIXTURES_DIR/plugin1.sh" > $plugin_file
  local plugin_content='plugin2_alias1;plugin2_func1;'
  local cached_plugin_file="$SHY_CACHE_DIR/plugin2"
  echo $plugin_content > "$cached_plugin_file"

  touch $plugin_file
  make_modified_in_past $cached_plugin_file

  run shy _read_cache $plugin_file
  assert_failure
  assert_output ""
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

@test "load reads data from cache if it exists and is fresh" {
  local plugin_file="$FIXTURES_DIR/plugin1.sh"
  local cached_plugin_content='cached_alias1;cached_func1;'
  local cached_plugin_file="$SHY_CACHE_DIR/plugin1"
  echo $cached_plugin_content > "$cached_plugin_file"

  make_modified_in_past $plugin_file
  touch $cached_plugin_file

  shy load $plugin_file
  assert_equal "plugin1;$plugin_file;$cached_plugin_content" "$SHY_PLUGIN_DATA"
}

@test "load does not read data from cache if it exists and is stale" {
  local plugin_file="$FIXTURES_DIR/plugin1.sh"
  local cached_plugin_content='cached_alias1;cached_func1;'
  local cached_plugin_file="$SHY_CACHE_DIR/plugin1"
  echo $cached_plugin_content > "$cached_plugin_file"

  make_modified_in_past $cached_plugin_file
  touch $plugin_file

  shy load $plugin_file
  assert_equal "plugin1;$plugin_file;plugin1_alias1:plugin1_alias2;plugin1_func1:plugin1_func2;PLUGIN1_VAR1:PLUGIN1_VAR2" "$SHY_PLUGIN_DATA"
}

@test "load writes to cache if not reading from cache" {
  local plugin_file="$FIXTURES_DIR/plugin1.sh"
  local cached_plugin_file="$SHY_CACHE_DIR/plugin1"
  rmdir "$SHY_CACHE_DIR"
  shy load $plugin_file
  [ -d "$SHY_CACHE_DIR" ]
  [ -f "$cached_plugin_file" ]
  assert_equal "plugin1_alias1:plugin1_alias2;plugin1_func1:plugin1_func2;PLUGIN1_VAR1:PLUGIN1_VAR2" "$(cat $cached_plugin_file)"
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
  assert_output "shy: Unknown plugin name: bogus_plugin"
}

@test "edit opens editor for plugin" {
  load_plugins plugin1 plugin2 plugin3
  # echo the file path to make sure we get the right one in the output
  export SHY_EDITOR=echo
  run shy edit plugin1
  assert_success
  assert_output "$FIXTURES_DIR/plugin1.sh"
}

@test "edit opens editor with plugin containing a function" {
  load_plugins plugin1 plugin2 plugin3
  export SHY_EDITOR=echo
  run shy edit plugin1_func1
  assert_success
  assert_output "$FIXTURES_DIR/plugin1.sh"
}

@test "edit opens editor with plugin containing an alias" {
  load_plugins plugin1 plugin2 plugin3
  export SHY_EDITOR=echo
  run shy edit plugin2_alias1
  assert_success
  assert_output "$FIXTURES_DIR/plugin2.sh"
}

@test "edit opens editor with plugin containing a variable" {
  load_plugins plugin1 plugin2 plugin3
  export SHY_EDITOR=echo
  run shy edit PLUGIN3_VAR1
  assert_success
  assert_output "$FIXTURES_DIR/plugin3.sh"
}

@test "edit returns failure status for nonexistent plugin or item" {
  load_plugins plugin1 plugin2 plugin3
  export SHY_EDITOR=echo
  run shy edit bogus_plugin
  assert_failure
  assert_output "shy: Unknown plugin, function, alias, or variable: bogus_plugin"
}

@test "which finds where an alias is defined" {
  load_plugins plugin1 plugin2 plugin3
  run shy which plugin3_alias1
  assert_success
  assert_output "plugin3_alias1 is an alias in the plugin plugin3"
}

@test "which finds where an function is defined" {
  load_plugins plugin1 plugin2 plugin3
  run shy which plugin2_func1
  assert_success
  assert_output "plugin2_func1 is a function in the plugin plugin2"
}

@test "which finds where a variable is defined" {
  load_plugins plugin1 plugin2 plugin3
  run shy which PLUGIN1_VAR1
  assert_success
  assert_output "PLUGIN1_VAR1 is a variable in the plugin plugin1"
}

@test "which returns failure status and error message when nothing is found" {
  load_plugins plugin1 plugin2 plugin3
  run shy which bogus_something_or_other
  assert_failure
  assert_output "(bogus_something_or_other not found in any plugin)"
}
