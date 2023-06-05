const std = @import("std");
const imports = @import("imports.zig");
const Board = @import("board.zig").Board;

var alloc_buff: [1024 * 1024 * 30]u8 = undefined;

var fba = std.heap.FixedBufferAllocator.init(alloc_buff[0..]);
const allocator = fba.allocator();

const Cell = struct {
    x: f64 = 0,
    speed: f64 = 0,
    acc: f64 = 0,
    rev_mass: f64 = 1,
};

const dt = 0.5;
const T = Cell;
var board: Board(T) = undefined;

fn rgb(r: u8, g: u8, b: u8) u32 {
    return 0xFF000000 + @as(u32, b) * 0x00010000 + @as(u32, g) * 0x00000100 + @as(u32, r);
}

export fn render() void {
    var i: usize = 0;
    while (i < board.size.area()) : (i += 1) {
        const max_val: f64 = board.max_val / 2;
        const abs: f64 = std.math.fabs(board.data[i].x);
        // std.log.warn("{s}", .{@typeName(@TypeOf(abs))});
        var normalized: f64 = abs / max_val * 255;
        var clamped: f64 = std.math.clamp(normalized, 0.0, 255.0);
        var val: u8 = @floatToInt(u8, clamped);
        board.screen[i] = if (board.data[i].x > 0) rgb(0, 0, val) else rgb(val, 0, 0);
    }
}
fn tickOne(a: *Cell, b: Cell) void {
    a.*.acc += (b.x - a.x) * dt;
}
export fn tick() void {
    board.max_val = 0;
    var i: usize = 0;
    while (i < board.size.area()) : (i += 1) {
        // board.data[i].acc = (0 - board.data[i].x) * dt;
        board.data[i].acc = 0;
        var js: [9]?usize = undefined;
        board.size.around(i, js[0..]);
        var ch = [1]u8{'0'};
        for (js) |j| {
            ch[0] += 1;
            if (j == null) {
                break;
            }
            tickOne(&board.data[i], board.data[j.?]);
        }
    }
    i = 0;
    var max_i: usize = 0;
    while (i < board.size.area()) : (i += 1) {
        // imports.logfmt("{}", .{board.data[i].rev_mass});
        board.data[i].speed += board.data[i].rev_mass * board.data[i].acc * dt;
        board.data[i].x += board.data[i].speed * dt;

        board.max_val = std.math.max(std.math.fabs(board.max_val), std.math.fabs(board.data[i].x));
        if (board.max_val <= std.math.fabs(board.data[i].x)) max_i = i;
    }
    // imports.logfmt("{} {d:.3}", .{ max_i, board.data[max_i].x });
}

fn range(len: usize) []const void {
    return @as([*]void, undefined)[0..len];
}

fn setMass(x: usize, y: usize, w: usize, h: usize, rev_mass: f64) void {
    for (range(w)) |_, dx| {
        for (range(h)) |_, dy| {
            imports.logfmt("{} {}", .{ x + dx, y + dy });
            board.atP(x + dx, y + dy).*.rev_mass = 0;
            board.atP(x + dx, y + dy).*.speed = 0;
            board.atP(x + dx, y + dy).*.x = 0;
            board.atP(x + dx, y + dy).*.rev_mass = rev_mass;
        }
    }
}
export fn initBoard(x: usize, y: usize) *u32 {
    var rnd = std.rand.DefaultPrng.init(0);
    board = Board(T).new(allocator, x, y);
    var i: usize = 0;
    while (i < board.size.area()) : (i += 1) {
        board.data[i].x = (rnd.random().float(f64) - 0.5) * 0;
        board.data[i].rev_mass = 2;
    }
    // i = 0;
    // while (i < board.size.y) : (i += 1) {
    //     board.atP(0, i).*.x = 30;
    // }
    for (range(30)) |_, z| {
        board.atP(board.size.x / 2, board.size.y / 2).*.x = @intToFloat(f64, z);
    }

    setMass(20, 20, 10, board.size.y / 2, 0.9);
    setMass(60, 20, 10, board.size.y / 2, 0.9);
    // fixRect(20, board.size.y / 3 + 5, 10, 5);
    // fixRect(20, board.size.y / 2 + 5, 10, board.size.y - (board.size.y / 2 + 5));
    // fixRect(0, 0, board.size.x, 1);
    // fixRect(0, board.size.y - 1, board.size.x, 1);
    // board.atP(board.size.x / 2, board.size.y / 2).*.x = 30;
    return &board.screen[0];
}

test "testBuf" {
    _ = initBoard(3, 4);
}
