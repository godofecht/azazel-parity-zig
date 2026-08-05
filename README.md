# azazel-parity-zig

The [Zig compiler](https://github.com/ziglang/zig)'s own tokenizer
(`lib/std/zig/tokenizer.zig`, ~1770 lines — the lexer for the Zig language)
built two ways, to prove [azazel](https://github.com/godofecht/azazel) and
[zaza](https://github.com/godofecht/zaza) on the largest Zig codebase there is.

Both build a consumer that tokenizes a snippet of Zig and counts the tokens.
Neither vendors the source; each stages the single file at a pinned commit with
its own `fetch.sh`, rewriting the one relative `@import("../std.zig")` to the
normal `@import("std")` so the lexer builds standalone (otherwise unchanged).

## Pinned upstream

| | |
|---|---|
| Repository | https://github.com/ziglang/zig |
| Commit | `738d2be9d6b6ef3ff3559130c05159ef53336224` |
| File | `lib/std/zig/tokenizer.zig` |
| Zig | 0.16.0 |

## Build it

```sh
cd azazel && ./fetch.sh && sh gen_build_spec.sh && zig build && ./zig-out/bin/consumer
cd zaza  && ./fetch.sh && zig build run
```

Both print `zig tokenizer: 29 tokens`.

## Comparison

| Build | What it does | Config |
|-------|--------------|--------|
| azazel | imports the tokenizer module + a consumer, as CUE data | `project.cue`, 14 lines |
| zaza | imports the tokenizer module via the Zig build graph | `build.zig`,       13 lines |

The point of this one is coverage: azazel and zaza both build a real, substantial
component (the Zig language lexer) straight from the compiler's source tree.
