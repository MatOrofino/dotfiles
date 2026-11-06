set -l fzf_theme_opts "\
--color=bg+:#262130
--color=bg:#1d1a23
--color=spinner:#f2f2f3
--color=hl:#fd4663
--color=fg:#f2f2f3
--color=header:#fd4663
--color=info:#a086dc
--color=pointer:#f2f2f3
--color=marker:#b1afb6
--color=fg+:#f2f2f3
--color=prompt:#a086dc
--color=hl+:#fd4663
--color=selected-bg:#262130
--color=border:#262130
--color=label:#f2f2f3"

if set -q FZF_DEFAULT_OPTS[1]; and test -n "$FZF_DEFAULT_OPTS"
    set -Ux FZF_DEFAULT_OPTS "$FZF_DEFAULT_OPTS
$fzf_theme_opts"
else
    set -Ux FZF_DEFAULT_OPTS "$fzf_theme_opts"
end
