#!/bin/bash
# Install the pre-commit check for damaged numbers in TSV/CSV files (check_tsv_numbers.py)
# into one or several git repositories.
#
# usage: install_hooks.sh REPO [REPO ...]
#
# The script is copied into .git/hooks of each repository, so the hook keeps working if this
# folder moves. An existing pre-commit hook is kept and called first.
set -e
src="$(cd "$(dirname "$0")" && pwd)/check_tsv_numbers.py"
for repo in "$@"; do
  hooks="$(git -C "$repo" rev-parse --git-path hooks)"
  case "$hooks" in /*) ;; *) hooks="$repo/$hooks" ;; esac
  mkdir -p "$hooks"
  cp "$src" "$hooks/check_tsv_numbers.py"
  hook="$hooks/pre-commit"
  if [ -e "$hook" ] && ! grep -q check_tsv_numbers "$hook"; then
    mv "$hook" "$hooks/pre-commit.before-tsv-check"
  fi
  cat > "$hook" <<'EOF'
#!/bin/bash
# pre-commit: check staged TSV/CSV files for numbers damaged by spreadsheet programs
# (installed by sbtab/tools/git-hooks/install_hooks.sh)
hooks="$(dirname "$0")"
if [ -x "$hooks/pre-commit.before-tsv-check" ]; then
  "$hooks/pre-commit.before-tsv-check" || exit 1
fi
exec python3 "$hooks/check_tsv_numbers.py"
EOF
  chmod +x "$hook" "$hooks/check_tsv_numbers.py"
  echo "installed: $repo"
done
