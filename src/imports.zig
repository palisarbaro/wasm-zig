const std = @import("std");

extern fn console_log_ex(message: [*]u8, length: usize) void;
pub fn log(message: [*:0]u8) void {
    var m = std.mem.span(message);
    console_log_ex(m, m.len);
}
pub fn logfmt(comptime fmt: []const u8, args: anytype) void {
    var buff: [100]u8 = undefined;
    var res = std.fmt.bufPrintZ(&buff, fmt, args) catch unreachable;
    console_log_ex(@ptrCast([*]u8, res), res.len);
}
