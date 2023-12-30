const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 11|1: {d}\n", .{part1});
    const part2 = try solve(@embedFile("input.txt"), 2);
    std.debug.print("Day 11|2: {d}\n", .{part2});
}

const Coordinate = struct { x: isize, y: isize };

fn solve(input: []const u8, comptime part: usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenize(u8, input, "\r\n");

    var space = std.ArrayList(std.ArrayList(u8)).init(allocator);

    while (lines.next()) |line| {
        try space.append(std.ArrayList(u8).init(allocator));
        var row = &space.items[space.items.len - 1];
        try row.appendSlice(line);
    }

    // get galaxy locations
    var galaxies = std.ArrayList(Coordinate).init(allocator);
    for (space.items, 0..) |row, i| {
        for (row.items, 0..) |col, j| {
            if (col == '#') try galaxies.append(.{ .x = @intCast(i), .y = @intCast(j) });
        }
    }

    var vertical = std.ArrayList(isize).init(allocator);
    for (0..space.items[0].items.len) |i| {
        for (0..space.items.len) |j| {
            if (space.items[j].items[i] == '#') break;
        } else try vertical.append(@intCast(i));
    }

    var horizontal = std.ArrayList(isize).init(allocator);
    for (space.items, 0..) |row, j| {
        if (std.mem.indexOfScalar(u8, row.items, '#')) |_| {} else {
            try horizontal.append(@intCast(j));
        }
    }

    var sum: usize = 0;
    for (0..galaxies.items.len - 1) |i| {
        for (i..galaxies.items.len) |j| {
            const l = galaxies.items[i];
            const r = galaxies.items[j];

            var distance = try std.math.absInt(l.x - r.x) + try std.math.absInt(l.y - r.y);

            distance += AddGaps(horizontal.items, @min(l.x, r.x), @max(l.x, r.x), part);
            distance += AddGaps(vertical.items, @min(l.y, r.y), @max(l.y, r.y), part);

            sum += @intCast(distance);
        }
    }

    return sum;
}

fn AddGaps(gaps: []isize, l: isize, r: isize, comptime part: usize) isize {
    const c = if (comptime part == 1) 1 else 1000000 - 1;
    var sum: isize = 0;
    for (gaps) |gap| {
        if (l < gap and r > gap) sum += c;
    }
    return sum;
}
