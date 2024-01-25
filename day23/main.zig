const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("test.txt"), 1);
    std.debug.print("Day 23|1: {d}\n", .{part1});
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
    const end = Point{ .x = map.items[0].len - 2, .y = map.items.len - 1 };

    std.debug.print("End: {d},{d}\n", .{ end.y, end.x });

    var path = std.ArrayList(Point).init(allocator);
    try path.append(start);
    try path.append(Point{ .x = start.x, .y = start.y + 1 });

    // every time we find a split store it
    var pathSplits = std.ArrayList(Split).init(allocator);

    // try pathSplits.append(Split{ .idx = 0, .c = 'v' });
    var pathLengths = std.ArrayList(usize).init(allocator);
    var numPaths: usize = 0;
    while (numPaths == 0 or pathSplits.items.len != 0) : (numPaths += 1) {
        var curr = path.getLast();

        // std.debug.print("q: {d}\n", .{pathSplits.items.len});

        if (pathSplits.popOrNull()) |split| {
            // std.debug.print("Split: {c},{d}\n", .{ split.c, split.idx });

            try path.resize(split.idx);
            curr = path.getLast();

            // std.debug.print("Path.len: {d}\n", .{path.items.len});

            switch (split.c) {
                'v' => try path.append(.{ .x = curr.x, .y = curr.y + 1 }),
                '>' => try path.append(.{ .x = curr.x + 1, .y = curr.y }),
                '<' => try path.append(.{ .x = curr.x - 1, .y = curr.y }),
                '^' => try path.append(.{ .x = curr.x, .y = curr.y - 1 }),
                else => unreachable,
            }
        }

        curr = path.getLast();
        // std.debug.print("New Split: {d},{d}\n", .{ curr.y, curr.x });

        outer: while (true) {

            // down is not in path
            if (path.items[path.items.len - 2].y != curr.y + 1 and map.items[curr.y + 1][curr.x] != '#') {
                for (curr.y + 1..map.items.len) |j| {
                    if (j == end.y and curr.x == end.x) {
                        // std.debug.print("PathLength: {d}\n", .{path.items.len});
                        break :outer;
                    }

                    if (isInPath(Point{ .x = curr.x, .y = j }, path.items)) break :outer;

                    const pt = map.items[j][curr.x];
                    if (pt == '.' or pt == 'v') {
                        // std.debug.print("D: {c},{d},{d}\n", .{ pt, j, curr.x });
                        try path.append(Point{ .x = curr.x, .y = j });
                    } else {
                        curr.y = j - 1;
                        break;
                    }

                    curr = path.getLast();
                    if (map.items[j - 1][curr.x] == 'v' and map.items[j + 1][curr.x] == 'v') {
                        if (map.items[j][curr.x + 1] == '>') {
                            // std.debug.print(">: {d},{d}\n", .{ curr.y, curr.x });
                            try pathSplits.append(.{ .idx = path.items.len, .c = '>' });
                        }
                        if (map.items[j][curr.x - 1] == '>') {
                            // std.debug.print(">: {d},{d}\n", .{ curr.y, curr.x });
                            try pathSplits.append(.{ .idx = path.items.len, .c = '<' });
                        }
                    }
                }
            }
            curr = path.getLast();

            // right is not in path
            if (path.items[path.items.len - 1].x != curr.x + 1 and map.items[curr.y][curr.x + 1] != '#') {
                for (curr.x + 1..map.items[0].len) |i| {
                    const pt = map.items[curr.y][i];
                    if (isInPath(Point{ .x = i, .y = curr.y }, path.items)) break :outer;
                    if (pt == '.' or pt == '>') {
                        // std.debug.print("R: {c},{d},{d}\n", .{ pt, curr.y, i });
                        try path.append(Point{ .x = i, .y = curr.y });
                    } else {
                        curr.x = i - 1;
                        break;
                    }

                    if (map.items[curr.y][i - 1] == '>' and map.items[curr.y][i + 1] == '>') {
                        if (map.items[curr.y + 1][i] == 'v') {
                            // std.debug.print("v: {d},{d}\n", .{ curr.y, curr.x });
                            try pathSplits.append(.{ .idx = path.items.len, .c = 'v' });
                        }
                        if (map.items[curr.y - 1][i] == 'v') {
                            // std.debug.print("v: {d},{d}\n", .{ curr.y, curr.x });
                            try pathSplits.append(.{ .idx = path.items.len, .c = '^' });
                        }
                    }
                }
            }
            curr = path.getLast();
            // left is not in path
            if (path.items[path.items.len - 2].x != curr.x - 1 and map.items[curr.y][curr.x - 1] != '#') {
                for (1..curr.x) |i| {
                    const pt = map.items[curr.y][curr.x - i];
                    if (isInPath(Point{ .x = curr.x - i, .y = curr.y }, path.items)) break :outer;
                    if (pt == '.' or pt == '>') {
                        // std.debug.print("L: {c},{d},{d}\n", .{ pt, curr.y, curr.x - i });
                        try path.append(Point{ .x = curr.x - i, .y = curr.y });
                    } else {
                        curr.x = curr.x - i + 1;
                        break;
                    }
                    if (map.items[curr.y][i - 1] == '>' and map.items[curr.y][i + 1] == '>') {
                        if (map.items[curr.y + 1][i] == 'v') {
                            // std.debug.print("v: {d},{d}\n", .{ curr.y, curr.x });
                            try pathSplits.append(.{ .idx = path.items.len, .c = 'v' });
                        }
                        if (map.items[curr.y - 1][i] == 'v') {
                            // std.debug.print("v: {d},{d}\n", .{ curr.y, curr.x });
                            try pathSplits.append(.{ .idx = path.items.len, .c = '^' });
                        }
                    }
                }
            }

            curr = path.getLast();
            // left is not in path
            if (path.items[path.items.len - 2].y != curr.y - 1 and map.items[curr.y - 1][curr.x] != '#') {
                for (1..curr.y) |j| {
                    const pt = map.items[curr.y - j][curr.x];
                    if (isInPath(Point{ .x = curr.x, .y = curr.y - j }, path.items)) break :outer;
                    if (pt == '.' or pt == 'v') {
                        // std.debug.print("U: {c},{d},{d}\n", .{ pt, curr.y - j, curr.x });
                        try path.append(Point{ .x = curr.x, .y = curr.y - j });
                    } else {
                        curr.y = curr.y - j + 1;
                        break;
                    }
                    if (map.items[j - 1][curr.x] == 'v' and map.items[j + 1][curr.x] == 'v') {
                        if (map.items[j][curr.x + 1] == '>') {
                            // std.debug.print(">: {d},{d}\n", .{ curr.y, curr.x });
                            try pathSplits.append(.{ .idx = path.items.len, .c = '>' });
                        }
                        if (map.items[j][curr.x - 1] == '>') {
                            // std.debug.print(">: {d},{d}\n", .{ curr.y, curr.x });
                            try pathSplits.append(.{ .idx = path.items.len, .c = '<' });
                        }
                    }
                }
            }
        }
        try pathLengths.append(path.items.len);
    }
    var maxPath: usize = 0;
    for (pathLengths.items) |len| {
        maxPath = @max(maxPath, len);
        std.debug.print("{d} ", .{len});
    } else std.debug.print("\n", .{});

    return maxPath;
}

fn isInPath(needle: Point, haystack: []Point) bool {
    for (haystack) |p| {
        if (needle.x == p.x and needle.y == p.y) return true;
    } else return false;
}
