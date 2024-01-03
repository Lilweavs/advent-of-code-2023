const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 14|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("test.txt"), 2);
    // std.debug.print("Day 13|2: {d}\n", .{part2});
}

fn solve(input: []const u8, comptime part: usize) !usize {
    _ = part;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var platform = std.ArrayList([]u8).init(allocator);

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        try platform.append(try allocator.dupe(u8, line));
    }

    var load: usize = 0;

    var pcache = std.ArrayList(std.ArrayListUnmanaged([]u8)).init(allocator);

    var found: usize = 0;
    outer: for (0..1000) |_| {
        try pcache.append(try std.ArrayListUnmanaged([]u8).initCapacity(allocator, platform.items.len));
        var copy = &pcache.items[pcache.items.len - 1];
        for (platform.items) |src| {
            try copy.append(allocator, try allocator.dupe(u8, src));
        }

        for (0..4) |i| {
            Cycle(i, &platform);
        }

        for (pcache.items, 0..) |tmp, k| {
            if (PlatformEqual(platform.items, tmp.items)) {
                // print(pcache.items[pcache.items.len - 1].items);
                found = k;
                break :outer;
            }
        }
    }

    for (pcache.items, 0..) |*c, m| {
        std.debug.print("{d}, {d}\n", .{ m, ComputeLoad(c.items) });
        print(c.items);
    }

    const offset = (1000000000 - found) % (pcache.items.len - found);
    load = ComputeLoad(pcache.items[offset + found].items);

    return load;
}

fn ComputeLoad(platform: [][]u8) usize {
    var load: usize = 0;
    for (platform, 0..) |line, i| {
        for (line) |c| {
            if (c == 'O') load += (line.len - i);
        }
    }
    return load;
}

fn PlatformEqual(lhs: [][]u8, rhs: [][]u8) bool {
    for (lhs, rhs) |l, r| {
        if (!std.mem.eql(u8, l, r)) return false;
    }
    return true;
}

fn print(lines: [][]u8) void {
    for (lines) |line| std.debug.print("{s}\n", .{line});
    std.debug.print("\n", .{});
}

fn Cycle(direction: usize, platform: *std.ArrayList([]u8)) void {
    const sj: usize = if (direction == 0 or direction == 2) 1 else 0;
    const si: usize = if (direction == 1 or direction == 3) 1 else 0;

    for (sj..platform.items.len) |j| {
        for (si..platform.items[0].len) |i| {
            const c = switch (direction) {
                0, 1 => platform.items[j][i],
                2 => platform.items[platform.items.len - 1 - j][i],
                3 => platform.items[j][platform.items[j].len - 1 - i],
                else => unreachable,
            };

            if (c != 'O') continue;

            switch (direction) {
                0 => {
                    for (0..j) |k| { // North tilt
                        if (platform.items[j - k - 1][i] == '.') {
                            std.mem.swap(u8, &platform.items[j - k][i], &platform.items[j - k - 1][i]);
                        } else break;
                    }
                },
                1 => {
                    for (0..i) |k| { // West tilt
                        if (platform.items[j][i - k - 1] == '.') {
                            std.mem.swap(u8, &platform.items[j][i - k], &platform.items[j][i - k - 1]);
                        } else break;
                    }
                },
                2 => {
                    for (0..j) |k| { // South tilt
                        if (platform.items[platform.items.len - j + k][i] == '.') {
                            std.mem.swap(u8, &platform.items[platform.items.len - 1 - j + k][i], &platform.items[platform.items.len - j + k][i]);
                        } else break;
                    }
                },
                3 => {
                    for (0..i) |k| { // East tilt
                        if (platform.items[j][platform.items[j].len - i + k] == '.') {
                            std.mem.swap(u8, &platform.items[j][platform.items[j].len - 1 - i + k], &platform.items[j][platform.items[j].len - i + k]);
                        } else break;
                    }
                },
                else => unreachable,
            }
        }
    }
}
