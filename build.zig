const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();
    const target = std.zig.CrossTarget.parse(.{ .arch_os_abi = "wasm32-freestanding" }) catch unreachable;
    const lib = b.addSharedLibrary("lib", "src/main.zig", std.build.LibExeObjStep.SharedLibKind.unversioned);
    lib.setBuildMode(mode);
    lib.setTarget(target);
    lib.install();

    const main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    var command_strs = [_][]const u8{ "mv", "zig-out/lib/lib.wasm", "web" };
    const command = b.addSystemCommand(&command_strs);
    const example_step = b.step("example", "install wasm into web dir");
    example_step.dependOn(b.getInstallStep());
    example_step.dependOn(&command.step);
}
