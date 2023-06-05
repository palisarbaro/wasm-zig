const std = @import("std");

const Size = struct {
    x: usize,
    y: usize,
    pub fn new(x: usize, y: usize) Size {
        return Size{ .x = x, .y = y };
    }
    pub fn area(self: Size) usize {
        return self.x * self.y;
    }
    pub fn index(self: Size, x: usize, y: usize) usize {
        return y * self.x + x;
    }
    pub fn coords(self: Size, idx: usize, x: *usize, y: *usize) void {
        x.* = idx % self.x;
        y.* = (idx - x.*) / self.x;
    }
    pub fn inRange(self: Size, x: isize, y: isize) bool {
        return x >= 0 and y >= 0 and x < self.x and y < self.y;
    }
    pub fn around(self: Size, idx: usize, dist: []?usize) void {
        var x: usize = undefined;
        var y: usize = undefined;
        self.coords(idx, &x, &y);
        var i: usize = 0;
        var dx: isize = -1;
        while (dx < 2) : (dx += 1) {
            var dy: isize = -1;
            while (dy < 2) : (dy += 1) {
                if (dx == 0 and dy == 0) continue;
                var X = @intCast(isize, x) + dx;
                var Y = @intCast(isize, y) + dy;
                if (self.inRange(X, Y)) {
                    dist[i] = self.index(@intCast(usize, X), @intCast(usize, Y));
                    i += 1;
                }
            }
        }
        dist[i] = null;
    }
};

pub fn Board(comptime T: type) type {
    return struct {
        size: Size,
        data: []T,
        screen: []u32,
        max_val: f64 = 0,
        pub fn atP(self: Board(T), x: usize, y: usize) *T {
            return &self.data[self.size.index(x, y)];
        }
        pub fn at(self: Board(T), x: usize, y: usize) T {
            return self.atP(x, y).*;
        }
        pub fn new(allocator: std.mem.Allocator, x: usize, y: usize) Board(T) {
            const size = Size.new(x, y);
            const data = allocator.alloc(T, size.area()) catch unreachable;
            const screen = allocator.alloc(u32, size.area()) catch unreachable;
            return Board(T){ .size = size, .data = data, .screen = screen };
        }
    };
}
