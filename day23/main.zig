const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("test.txt"), 1);
    std.debug.print("Day 22|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("input.txt"), 2);
    // std.debug.print("Day 22|2: {d}\n", .{part2});
}

const Point = struct { x: usize = undefined, y: usize = undefined };
const Split = struct { idx: usize = undefined, c: u8 = undefined };

const Direction = enum { Up, Down, Left, Right };

fn solve(input: []const u8, comptime part: usize) !usize {
    _ = part;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.splitSequence(u8, input, "\r\n");

    var map = std.ArrayList([]const u8).init(allocator);

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        try map.append(line);
    }

    const start = Point{ .x = 1, .y = 0 };
    const end = Point{ .x = map.items[0].len - 1, .y = map.items.len - 2 };

    var path = std.ArrayList(Point).init(allocator);
    try path.append(start);

    // every time we find a split store it
    var pathSplits = std.ArrayList(Split).init(allocator);

    try pathSplits.append(Split{ .idx = 0, .c = 'v' });

    var curr = start;
    while (pathSplits.items.len != 0) {
        const split = pathSplits.pop();

        std.debug.print("Split: {c}\n", .{split.c});

        try path.resize(split.idx + 1);

        switch (split.c) {
            'v' => try path.append(.{ .x = curr.x, .y = curr.y + 1 }),
            '>' => try path.append(.{ .x = curr.x + 1, .y = curr.y }),
            else => unreachable,
        }

        curr = path.items[path.items.len - 1];

        outer: while (true) {
            if (map.items[curr.y + 1][curr.x] == '.' or map.items[curr.y + 1][curr.x] == 'v') {
                for (curr.y + 1..map.items.len) |j| {
                    if (curr.y == end.y and curr.x == end.x) {
                        std.debug.print("PathLength: {d}", .{path.items.len});
                        break :outer;
                    }

                    const pt = map.items[j][curr.x];
                    std.debug.print("D: {c},{d},{d}\n", .{ pt, j, curr.x });
                    if (pt == '.' or pt == 'v') {
                        try path.append(Point{ .x = curr.x, .y = j });
                    } else {
                        curr.y = j - 1;
                        break;
                    }

                    if (map.items[j - 1][curr.x] == 'v' and (map.items[j - 1][curr.x] == 'v' or map.items[j - 1][curr.x] == '#')) {
                        if (map.items[j + 1][curr.x] == 'v') {
                            try pathSplits.append(.{ .idx = path.items.len, .c = 'v' });
                        }
                        try pathSplits.append(.{ .idx = path.items.len, .c = '>' });
                        break :outer;
                    }
                }
            } else if (map.items[curr.y][curr.x + 1] == '.') {
                for (curr.x + 1..map.items[0].len) |i| {
                    const pt = map.items[curr.y][i];
                    std.debug.print("R: {c},{d},{d}\n", .{ pt, curr.y, i });
                    if (pt == '.' or pt == '>') {
                        try path.append(Point{ .x = i, .y = curr.y });
                    } else {
                        curr.x = i - 1;
                        break;
                    }

                    if (map.items[curr.y][i - 1] == '>' and (map.items[curr.y][i + 1] == '>' or map.items[curr.y][i + 1] == '#')) {
                        if (map.items[curr.y][i + 1] == '>') {
                            try pathSplits.append(.{ .idx = path.items.len, .c = '>' });
                        }
                        try pathSplits.append(.{ .idx = path.items.len, .c = 'v' });
                        break :outer;
                    }
                }
            } else if (map.items[curr.y][curr.x - 1] == '.') {
                for (1..curr.x) |i| {
                    const pt = map.items[curr.y][curr.x - i];
                    std.debug.print("L: {c},{d},{d}\n", .{ pt, curr.y, curr.x - i });
                    if (pt == '.' or pt == '>') {
                        try path.append(Point{ .x = curr.x - i, .y = curr.y });
                    } else {
                        curr.x = curr.x - i + 1;
                        break;
                    }
                }
            } else if (map.items[curr.y - 1][curr.x] == '.') {
                for (1..curr.y) |j| {
                    const pt = map.items[curr.y - j][curr.x];
                    std.debug.print("U: {c},{d},{d}\n", .{ pt, curr.y - j, curr.x });
                    if (pt == '.') {
                        try path.append(Point{ .x = curr.x, .y = curr.y - j });
                    } else {
                        curr.y = curr.y - j + 1;
                        break;
                    }
                }
            } else {
                unreachable;
            }
        }
    }

    return 0;
}
