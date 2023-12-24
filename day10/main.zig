const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 10|1: {d}\n", .{part1});
}

const Grid = struct { x: isize = undefined, y: isize = undefined };

const Direction = enum { North, South, East, West, Stop };

const Starts = struct { pipe: u8, dir: Direction };

const startPipes = [_]u8{ '|', '-', 'L', 'J', '7', 'F' };
const startDir = [_]Direction{ Direction.North, Direction.West, Direction.North, Direction.North, Direction.South, Direction.South };

fn FollowPipe(loc: Grid, dir: Direction) Grid {
    return switch (dir) {
        Direction.North => return .{ .x = loc.x, .y = loc.y - 1 },
        Direction.South => return .{ .x = loc.x, .y = loc.y + 1 },
        Direction.East => return .{ .x = loc.x + 1, .y = loc.y },
        Direction.West => return .{ .x = loc.x - 1, .y = loc.y },
        else => unreachable,
    };
}

fn GetNextDirection(nextp: u8, direction: Direction) ?Direction {
    // from direction
    switch (direction) {
        Direction.North => {
            return switch (nextp) {
                '|' => Direction.North,
                '7' => Direction.West,
                'F' => Direction.East,
                else => null,
            };
        },
        Direction.South => {
            return switch (nextp) {
                '|' => Direction.South,
                'L' => Direction.East,
                'J' => Direction.West,
                else => null,
            };
        },
        Direction.East => {
            return switch (nextp) {
                '-' => Direction.East,
                'J' => Direction.North,
                '7' => Direction.South,
                else => null,
            };
        },
        Direction.West => {
            return switch (nextp) {
                '-' => Direction.West,
                'F' => Direction.South,
                'L' => Direction.North,
                else => null,
            };
        },
        else => unreachable,
    }
}

fn solve(input: []const u8, comptime part: usize) !isize {
    _ = part;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenize(u8, input, "\r\n");

    var map = std.AutoHashMap(Grid, u8).init(allocator);

    var start = Grid{ .x = undefined, .y = undefined };

    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        for (line, 0..) |c, j| {
            if (c == 'S') start = Grid{ .x = @intCast(j), .y = @intCast(i) };

            try map.put(.{ .x = @intCast(j), .y = @intCast(i) }, c);

            // if (c != '.') try map.put(.{ .x = @intCast(j), .y = @intCast(i) }, c);
        }
    }

    var maxDis: isize = 0;
    for (startPipes, startDir) |sp, sd| {
        const tmp = try FindPath(&map, start, sd, sp, allocator) orelse continue;
        maxDis = @max(maxDis, tmp);
        // std.debug.print("{c},{},{}\n", .{ sp, sd, tmp });
    }

    return maxDis;
}

fn FindPath(map: *std.AutoHashMap(Grid, u8), start: Grid, sd: Direction, sp: u8, allocator: std.mem.Allocator) !?isize {
    var direction = sd; // current direction
    var pipe = sp;
    var curr = start;

    var path = std.ArrayList(Grid).init(allocator);

    try map.put(start, pipe);

    var k: usize = 0;
    while (true) : (k += 1) {
        curr = FollowPipe(curr, direction);

        pipe = map.get(curr) orelse return null;

        direction = GetNextDirection(pipe, direction) orelse return null;

        try path.append(curr);
        // std.debug.print("{d},{c}\n", .{ k, pipe });
        if (start.x == curr.x and start.y == curr.y) break;
    }

    // std.debug.print("length: {d}\n", .{path.items.len});
    return @intCast(path.items.len / 2);
}
