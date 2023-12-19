const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 02|1: {d}\n", .{part1});
}

const Grid = struct { x: usize, y: usize };

fn FollowPipe(loc: Grid, dir: u8) [2]Grid {
    return switch (dir) { // +1 south, -1 north
        '|' => .{ Grid{ .x = loc.x, .y = loc.y + 1 }, Grid{ .x = loc.x, .y = loc.y - 1 } },
        '-' => .{ Grid{ .x = loc.x + 1, .y = loc.y }, Grid{ .x = loc.x - 1, .y = loc.y } },
        'L' => .{ Grid{ .x = loc.x, .y = loc.y - 1 }, Grid{ .x = loc.x + 1, .y = loc.y } },
        'J' => .{ Grid{ .x = loc.x, .y = loc.y - 1 }, Grid{ .x = loc.x - 1, .y = loc.y } },
        '7' => .{ Grid{ .x = loc.x, .y = loc.y + 1 }, Grid{ .x = loc.x - 1, .y = loc.y } },
        'F' => .{ Grid{ .x = loc.x, .y = loc.y + 1 }, Grid{ .x = loc.x + 1, .y = loc.y } },
        else => unreachable,
    };
}

fn solve(input: []const u8, comptime part: usize) !isize {
    _ = part;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenize(u8, input, "\r\n");

    var map = std.mem.AutoHashMap(Grid, u8).init(allocator);

    var start = Grid{};

    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        for (line, 0..) |c, j| {
            if (c == 'S') start = Grid{ .x = j, .y = i };
            if (c != '.') try map.put(.{ i, j }, c);
        }
    }

    var visited = std.mem.AutoHashMap(Grid, u8).init(allocator);
    var needToVisit = std.AutoHashMap(Grid, u8).init(allocator);
    _ = needToVisit;
    var curr = start;
    _ = curr;

    while (!visited.contains(start)) {}

    return 0;
}
