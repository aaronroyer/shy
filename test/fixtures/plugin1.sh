alias plugin1_alias1='echo "plugin1 alias1"'
alias plugin1_alias2='echo "plugin1 alias2"'

plugin1_func1() {
  echo 'plugin1 func1'
}

plugin1_func2() {
  echo 'plugin1 func2'
}

export PLUGIN1_VAR1='plugin1 var1'
export PLUGIN1_VAR2='plugin1 var2'
