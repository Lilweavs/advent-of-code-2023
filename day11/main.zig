const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 10|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("input.txt"), 2);
    // std.debug.print("Day 10|2: {d}\n", .{part2});
}

const Coordinate = struct { x: isize, y: isize };

const Combination = struct { l: usize, r: usize, d: usize };

fn solve(input: []const u8, comptime part: usize) !usize {
    _ = part;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenize(u8, input, "\r\n");

    var space = std.ArrayList(std.ArrayList(u8)).init(allocator);

    while (lines.next()) |line| {
        try space.append(std.ArrayList(u8).init(allocator));
        var row = &space.items[space.items.len - 1];
        try row.appendSlice(line);
    }

    print(&space);

    // add space rows
    var k: usize = 0;
    while (k < space.items.len) : (k += 1) {
        const row = space.items[k];
        if (std.mem.indexOfScalar(u8, row.items, '#')) |_| {} else {
            try space.insert(k, std.ArrayList(u8).init(allocator));
            var newRow = &space.items[k];
            try newRow.appendNTimes('.', row.items.len);
            k += 1;
        }
    }

    print(&space);
    // add space vertically
    k = 0;
    while (k < space.items[0].items.len) : (k += 1) {
        for (space.items) |row| {
            if (row.items[k] == '#') break;
        } else {
            for (0..space.items.len) |i| {
                try space.items[i].insert(k, '.');
            }
            k += 1;
        }
    }

    print(&space);
    // get galaxy locations
    var galaxies = std.ArrayList(Coordinate).init(allocator);
    for (space.items, 0..) |row, i| {
        for (row.items, 0..) |col, j| {
            if (col == '#') try galaxies.append(.{ .x = @intCast(i), .y = @intCast(j) });
        }
    }

    // var combinations = std.ArrayList(Combination).init(allocator);
    var sum: usize = 0;
    for (0..galaxies.items.len - 1) |i| {
        // var minDist: usize = std.math.maxInt(usize);
        for (i..galaxies.items.len) |j| {
            const l = galaxies.items[i];
            const r = galaxies.items[j];

            const distance = try std.math.absInt(l.x - r.x) + try std.math.absInt(l.y - r.y);
            // minDist = @min(minDist, @as(usize, @intCast(distance)));
            // try combinations.append(.{ .x = i, .y = j, .d});
            sum += @intCast(distance);
        }
    }

    return sum;
}

fn print(space: *std.ArrayList(std.ArrayList(u8))) void {
    for (space.items) |row| {
        std.debug.print("{s}\n", .{row.items});
    }
}
