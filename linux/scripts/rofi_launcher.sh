#!/bin/bash
# Command launcher: type a command and choose how to run it.
#   Enter:       run silently in the background (fire and forget)
#   Shift+Enter: open a wezterm terminal to see output
# Uses dmenu with no input so rofi accepts the literal typed command.
# _ROFI_WZ_CMD is namespaced; promptline.sh evals it after fastfetch on first precmd.
cmd=$(rofi -no-config -no-lazy-grab \
    -dmenu \
    -lines 0 \
    -p "$ " \
    -theme ~/.config/rofi/launcher.rasi \
    -theme-str 'listview { enabled: false; } window { height: 0; } inputbar { margin: 8px; }' \
    -kb-accept-custom "" \
    -kb-accept-alt "" \
    -kb-custom-1 "Shift+Return" \
    < /dev/null)
exit_code=$?

[[ -z "$cmd" ]] && exit 0

if [[ $exit_code -eq 10 ]]; then
  wezterm start -- env _ROFI_WZ_CMD="$cmd" zsh -i
else
  nohup bash -c "$cmd" >/dev/null 2>&1 &
fi
