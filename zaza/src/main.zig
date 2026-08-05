//! Consumer of the Zig compiler's own tokenizer (std.zig.Tokenizer source),
//! built standalone: tokenizes a snippet of Zig and counts the tokens, forcing
//! the lexer to compile and run.
const std = @import("std");
const tok = @import("tokenizer");

pub fn main() void {
    const src: [:0]const u8 =
        \\const std = @import("std");
        \\pub fn main() void {
        \\    std.debug.print("hi", .{});
        \\}
    ;
    var t = tok.Tokenizer.init(src);
    var n: usize = 0;
    while (true) {
        const token = t.next();
        if (token.tag == .eof) break;
        n += 1;
    }
    std.debug.print("zig tokenizer: {d} tokens\n", .{n});
    if (n == 0) std.process.exit(1);
}
