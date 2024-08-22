# Making Kitty the Default Terminal on Linux

You can normally run:
```shell
sudo update-alternatives --config x-terminal-emulator
```
...to be presented with a CLI for choosing an alternative terminal.

Unfortunately this doesn't work for kitty via the default install
method (as of 2024).

First you need to update the alternatives. Either point it at
kitty's bin or use `which`. Then you can run the original command
to choose kitty via the CLI.

```shell
sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator `which kitty` 50
sudo update-alternatives --config x-terminal-emulator
```
