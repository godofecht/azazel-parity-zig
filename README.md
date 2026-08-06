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

## Build process & what can be optimized

Both build roots stage the pinned upstream with `fetch.sh` into a git-ignored
`vendor/` (a `curl` for single-file slices, a shallow clone for source trees) —
no upstream sources are committed. Then:

- **azazel**: `sh gen_build_spec.sh` runs CUE and emits `build_spec.zig` (the
  build declared as data), then `zig build` compiles it. The CUE step is
  memoized — it re-runs only when the model changes (~0.20s → ~0.01s otherwise).
- **zaza**: `zig build` drives the standard Zig build graph directly.

### What actually makes it faster

Measured across the corpus (clean vs warm builds):

| Lever | Speedup | Note |
|-------|---------|------|
| Content-addressed cache (rebuild) | **89×** | 14.2s → 0.16s; Zig has it, both inherit it |
| Incremental (edit one file) | **10.8×** | 14.2s → 1.32s; deps stay cached |
| CI dependency cache | **2×** | cold 13.3s → warm 6.6s; this repo's CI caches `~/.cache/zig` |
| Memoized CUE codegen | **20×** | azazel's only overhead, gone |
| Parallelism (many cores) | **1.1×** | marginal — shared `std` + startup dominate |
| GPU | none | compilation is branchy, sequential, dependency-ordered |

The instinct to parallelize like a C++ build doesn't transfer: Zig is one
mostly-single-threaded compile per artifact with a fast self-hosted backend and a
shared `std` that caches. **For Zig, caching is the lever, not parallelism.**

The real frontier is *residency*: a resident compile server that keeps the
InternPool hot and recompiles only changed declarations, plus in-place binary
patching (Zig's roadmap) and a shared content-addressed cache. azazel's
build-as-data is positioned for it — the build is a query, and the cache key is
computable from the pinned model without running the compiler. Full write-up and
the cross-repo comparison: the [corpus dashboard](https://claude.ai/code/artifact/8c37ee83-b358-4351-a1e0-eb02ec0aedd4).
