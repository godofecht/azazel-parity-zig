// Azazel builds a consumer of the Zig compiler's own tokenizer
// (lib/std/zig/tokenizer.zig, ~1770 lines), declared as a CUE model. The lexer
// is staged by ./fetch.sh with its one relative std import rewritten to
// @import("std") so it builds standalone. Lane 0.16.
package build

toolchain: zig: {
	lanes: ["0.16"]
	preferred: "0.16"
}

tokenizer: #Module & {
	kind: "module"
	root: "vendor/tokenizer.zig"
}

consumer: #Module & {
	kind: "exe"
	root: "src/consumer.zig"
	deps: ["tokenizer"]
}
