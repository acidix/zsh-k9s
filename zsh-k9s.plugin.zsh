# Interactive kubeconfig selector for k9s
k9s() {
    # If arguments are passed, pass them directly to k9s
    if [[ "$#" -gt 0 ]]; then
        command k9s "$@"
        return
    fi

    local dir="$HOME/.kube"
    if [[ ! -d "$dir" ]]; then
        echo "Directory not found: $dir"
        return 1
    fi

    # Find candidate kubeconfig files (depth 2)
    # Using find to replicate the exact behavior of the Fish script
    local candidates=()
    while IFS= read -r -d '' file; do
        candidates+=("$file")
    done < <(find "$dir" -maxdepth 2 -type f \( -name config -o -name kubeconfig -o -name '*.yaml' -o -name '*.yml' -o -name '*.json' \) -print0 2>/dev/null)

    if [[ ${#candidates[@]} -eq 0 ]]; then
        echo "No kubeconfig files found under $dir"
        return 1
    fi

    local selected=""
    
    # If only one candidate, select it automatically
    if [[ ${#candidates[@]} -eq 1 ]]; then
        selected="${candidates[1]}"
    else
        # Try using fzf if available
        if command -v fzf >/dev/null 2>&1; then
            local fzf_opts=(
                --prompt="Select kubeconfig(s) > "
                --multi
                --height=80% --reverse --exit-0
                --preview 'kubectl --kubeconfig "{}" config get-contexts 2>/dev/null || echo "(no preview)"'
                --preview-window=right:60%:wrap
            )
            
            # Use printf to separate by newline for fzf input
            selected=$(printf "%s\n" "${candidates[@]}" | fzf "${fzf_opts[@]}")
        fi

        # Fallback to text menu if fzf is not available or cancelled (selected is empty)
        if [[ -z "$selected" ]]; then
            echo "Select kubeconfig file:"
            local i=1
            for c in "${candidates[@]}"; do
                echo "$i) $(basename "$c") ($(dirname "$c"))"
                ((i++))
            done
            
            read "choice?Enter number: "
            
            if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#candidates[@]} )); then
                selected="${candidates[choice]}"
            fi
        fi
    fi

    if [[ -z "$selected" ]]; then
        echo "No selection made"
        return 1
    fi

    # Handle multiple selections (newlines to colon separated)
    local kval=$(echo "$selected" | tr '\n' ':')
    # Remove trailing colon if exists
    kval=${kval%:}

    echo "Using KUBECONFIG=$kval"
    export KUBECONFIG="$kval"
    command k9s
}
