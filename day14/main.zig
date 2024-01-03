const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("test.txt"), 1);
    std.debug.print("Day 13|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("test.txt"), 2);
    // std.debug.print("Day 13|2: {d}\n", .{part2});
}

const Direction = enum { North, South, East, West };

fn solve(input: []const u8, comptime part: usize) !usize {
    _ = part;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.splitSequence(u8, input, "\r\n");

    var platform = std.ArrayList([]u8).init(allocator);

    while (lines.next()) |line| {
        try platform.append(try allocator.dupe(u8, line));
    }

    var load: usize = 0;

    print(&platform);

    // for (1..platform.items.len) |j| {
    //     for (0..platform.items[0].len) |i| {
    //         const c = if (direction == Direction.North) platform.items[j][i] else platform.items[platform.items.len - 1 - j][i];

    //         if (c != 'O') continue;

    //         for (0..j) |k| { // North tilt
    //             if (platform.items[j - k - 1][i] == '.') {
    //                 std.mem.swap(u8, &platform.items[j - k][i], &platform.items[j - k - 1][i]);
    //             } else break;
    //         }

    //         for (0..j) |k| { // South tilt
    //             if (platform.items[platform.items.len - j + k][i] == '.') {
    //                 std.mem.swap(u8, &platform.items[platform.items.len - 1 - j + k][i], &platform.items[platform.items.len - j + k][i]);
    //             } else break;
    //         }
    //     }
    // }

    // for (0..platform.items.len) |j| {
    //     for (1..platform.items[0].len) |i| {
    //         // const c = platform.items[j][i];

    //         const c = if (direction == Direction.West) platform.items[j][i] else platform.items[j][platform.items[j].len - 1 - i];

    //         if (c != 'O') continue;

    //         // for (0..i) |k| { // West tilt
    //         //     if (platform.items[j][i - k - 1] == '.') {
    //         //         std.mem.swap(u8, &platform.items[j][i - k], &platform.items[j][i - k - 1]);
    //         //     } else break;
    //         // }

    //         for (0..i) |k| { // East tilt
    //             if (platform.items[j][platform.items[j].len - i + k] == '.') {
    //                 std.mem.swap(u8, &platform.items[j][platform.items[j].len - 1 - i + k], &platform.items[j][platform.items[j].len - i + k]);
    //             } else break;
    //         }
    //     }
    // }
    const dir = Direction.North;
    Cycle(dir, &platform);

    print(&platform);

    for (platform.items, 0..) |line, i| {
        for (line) |c| {
            if (c == 'O') load += (platform.items.len - i);
        }
    }

    return load;
}

fn print(array: *std.ArrayList([]u8)) void {
    for (array.items) |line| std.debug.print("{s}\n", .{line});
    std.debug.print("\n", .{});
}

fn Cycle(direction: Direction, platform: *std.ArrayList([]u8)) void {
    const sj = if (direction == Direction.North or direction == Direction.South) 1 else 0;
    const si = if (direction == Direction.West or direction == Direction.East) 1 else 0;

    for (sj..platform.items.len) |j| {
        for (si..platform.items[0].len) |i| {
            const c = switch (direction) {
                Direction.North, Direction.West => platform.items[j][i],
                Direction.South => platform.items[platform.items.len - 1 - j][i],
                Direction.East => platform.items[j][platform.items[j].len - 1 - i],
            };

            if (c != 'O') continue;

            switch (direction) {
                Direction.North => {
                    for (0..j) |k| { // North tilt
                        if (platform.items[j - k - 1][i] == '.') {
                            std.mem.swap(u8, &platform.items[j - k][i], &platform.items[j - k - 1][i]);
                        } else break;
                    }
                },
                Direction.South => {
                    for (0..j) |k| { // South tilt
                        if (platform.items[platform.items.len - j + k][i] == '.') {
                            std.mem.swap(u8, &platform.items[platform.items.len - 1 - j + k][i], &platform.items[platform.items.len - j + k][i]);
                        } else break;
                    }
                },
                Direction.West => {
                    for (0..i) |k| { // West tilt
                        if (platform.items[j][i - k - 1] == '.') {
                            std.mem.swap(u8, &platform.items[j][i - k], &platform.items[j][i - k - 1]);
                        } else break;
                    }
                },
                Direction.East => {
                    for (0..i) |k| { // East tilt
                        if (platform.items[j][platform.items[j].len - i + k] == '.') {
                            std.mem.swap(u8, &platform.items[j][platform.items[j].len - 1 - i + k], &platform.items[j][platform.items[j].len - i + k]);
                        } else break;
                    }
                },
            }
        }
    }
}
