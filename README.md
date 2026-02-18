# zsh-k9s

A Zsh plugin for [k9s](https://k9scli.io/) that provides an interactive kubeconfig selector.

## Features

- Detects kubeconfig files in `~/.kube` (max depth 2)
- Uses `fzf` for selection if available, with preview of contexts
- Falls back to a numbered text menu if `fzf` is not installed or cancelled
- Supports multiple selections (multi-select in `fzf` with TAB)
- Sets `KUBECONFIG` environment variable for the `k9s` session

## Installation with Zap

Add the following to your `.zshrc`:

```zsh
plug "acidix/zsh-k9s"
```

## Usage

Simply run `k9s` in your terminal.
If multiple kubeconfig files are found, you will be prompted to select one.
If you pass arguments (e.g., `k9s -n my-namespace`), they are passed through to the underlying `k9s` command.
