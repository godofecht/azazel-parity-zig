const std = @import("std");
// The Zig compiler's tokenizer consumed through the standard Zig build graph
// Zaza is built on. std-only, so Zaza's C/C++ target DSL does not apply.
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const tokenizer = b.createModule(.{ .root_source_file = b.path("vendor/tokenizer.zig"), .target = target, .optimize = optimize });
    const exe = b.addExecutable(.{ .name = "tokenizer_consumer", .root_module = b.createModule(.{ .root_source_file = b.path("src/main.zig"), .target = target, .optimize = optimize }) });
    exe.root_module.addImport("tokenizer", tokenizer);
    b.installArtifact(exe);
    const run = b.addRunArtifact(exe);
    b.step("run", "Build and run the tokenizer consumer").dependOn(&run.step);
}
