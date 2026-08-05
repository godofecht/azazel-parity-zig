#!/bin/sh
# Stage the Zig compiler's own tokenizer (lib/std/zig/tokenizer.zig) at a pinned
# commit into vendor/ (git-ignored). The one relative std import is rewritten to
# the normal @import("std") so the file builds standalone; the lexer is otherwise
# unchanged. Single file, no clone of the Zig repo.
set -eu
ZIG_COMMIT=738d2be9d6b6ef3ff3559130c05159ef53336224
DIR=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$DIR/vendor"
if [ -f "$DIR/vendor/tokenizer.zig" ]; then echo "already staged"; exit 0; fi
curl -sL "https://raw.githubusercontent.com/ziglang/zig/$ZIG_COMMIT/lib/std/zig/tokenizer.zig" \
  | sed 's|@import("../std.zig")|@import("std")|' > "$DIR/vendor/tokenizer.zig"
echo "tokenizer.zig staged"
