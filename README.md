# shy - minimal shell "plugins"

Shy is a small tool for managing shell (bash/zsh) confiuration that is split into several files. A "plugin" is merely a file with plain old shell aliases, functions, variables, or anything else - they work the same whether or not Shy is installed.

Using Shy allows you to do the following:

 * Find where the heck that alias is defined
 * Pop open your editor to make a quick change to that function
 * Figure out where you configured something with an environment variable and tweak it
 * And (not much) more!

## Installation

1. Download the shy file and place it somewhere on your PATH
1. Add the following configuration in .bashrc/.zshrc, somewhere after configuring your PATH

```
eval "$(shy init)"
```

If you don't know what a PATH is then Shy is probably not for you. But you can look at [dotfiles that others have set up](http://dotfiles.github.io/) and get some inspiration for learning more about using your shell.

## Usage

Once you're installed then you can used ```shy load``` to load plugin files. You will usually do this in your .bashrc/.zshrc or other files that are run when your shell loads.

```
shy load ~/path/to/plugin.sh
```
Or maybe something like

```
for plugin in ~/.shell_plugins/* do
  shy load $plugin
done
```

Shy will source the files as normal, but also record all of the aliases, functions, and variables first defined in the file.

Now you can view a list of your plugins. The name of a plugin is the base file name with any extension removed.

![Shy printing loaded plugins](https://raw2.github.com/aaronroyer/shy/master/doc/list.png)

You can examine the details of a plugin.

![Shy printing the contents of a plugin](https://raw2.github.com/aaronroyer/shy/master/doc/show.png)

Use ```which``` if you want to know where something is defined.

```
 $ shy which glb
 glb is a function in the plugin git
 $ shy which gd
 gs is an alias in the plugin git
```

You can open a plugin (or anything else) in your EDITOR.

```
 $ shy edit git
 # (opens the git plugin source file in your editor)

 $ shy edit gs
 # (opens the git plugin source file, where the alias gs is defined)
```

## Why Use This?

You should try Shy if you like to maintain your own shell config, want things into separate files, want to be able to keep track of it all, and don't want something heavy to do it.

If you want lots of crazy/awesome power-user features you might like something like [composure](https://github.com/erichs/composure) instead. If you use zsh and just want to dump a ton of functionality that someone else wrote into your shell then use [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh).

I prefer to keep a set of often-used tools that I've put together myself (with little bits I've stolen) and manage them with simple tools.

## Command Reference

TODO: WRITE ME

## Advanced Configuration

If you want everything to work even if Shy is not installed (like if you sync your dotfiles but don't sync Shy along with it) then you can add a fallback that just loads.

```
if which shy &> /dev/null; then
  eval "$(shy init)"
else
  shy() { [ "$1" = 'load' ] && source "$2"; }
fi
```
