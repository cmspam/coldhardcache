# Custom shell functions.
#
# `rebuild` — format + nixos-rebuild switch for this host. Purely local.
# `pushnix` — regenerate the sanitized mirror in /etc/nixos/cache/config
#             from /etc/nixos/config (excluding private/), strip any
#             `private` imports, commit + force-push /etc/nixos/cache to
#             github. Triggers CI to rebuild the binary cache.
{ ... }:

{
  environment.interactiveShellInit = ''
    rebuild() {
      pushd /etc/nixos/config > /dev/null || return 1
      HOST=$(hostname)

      echo "Formatting..."
      nixfmt . 2>/dev/null || true

      echo "Building NixOS for $HOST..."
      if sudo nixos-rebuild switch --flake "/etc/nixos/config#$HOST"; then
        echo "--- Success! ---"
      else
        echo "--- Build failed! ---"
      fi

      popd > /dev/null
    }

    pushnix() {
      local CACHE_DIR=/etc/nixos/cache
      local SRC_DIR=/etc/nixos/config
      local STAGED_CONFIG="$CACHE_DIR/config"

      if [ ! -d "$CACHE_DIR" ]; then
        echo "pushnix: $CACHE_DIR does not exist"
        return 1
      fi

      echo "Formatting source..."
      (cd "$SRC_DIR" && nixfmt . 2>/dev/null) || true

      echo "Refreshing sanitized mirror at $STAGED_CONFIG..."
      rm -rf "$STAGED_CONFIG"
      rsync -a \
        --exclude='/private/' \
        --exclude='/.git/' \
        --exclude='result' \
        --exclude='result-*' \
        "$SRC_DIR/" "$STAGED_CONFIG/"

      echo "Stripping private imports..."
      python3 "$CACHE_DIR/lib/strip-private.py" "$STAGED_CONFIG" || {
        echo "pushnix: strip-private.py failed"
        return 1
      }

      echo "Committing + pushing to github..."
      pushd "$CACHE_DIR" > /dev/null || return 1
      git add -A
      if git diff --cached --quiet; then
        echo "Nothing new to commit."
      else
        git commit -m "publish: $(date -Iseconds)"
      fi
      if git push --force origin main; then
        echo "--- Pushed. CI will build + cache in the background. ---"
      else
        echo "--- Push failed! ---"
        popd > /dev/null
        return 1
      fi
      popd > /dev/null
    }
  '';
}
