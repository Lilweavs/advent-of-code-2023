const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 13|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("test.txt"), 2);
    // std.debug.print("Day 13|2: {d}\n", .{part2});
}

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

    for (1..platform.items.len) |j| {
        for (0..platform.items[0].len) |i| {
            const c = platform.items[j][i];
            if (c == 'O') {
                for (0..j) |k| {
                    // print(&platform);
                    if (platform.items[j - k - 1][i] == '.') {
                        std.mem.swap(u8, &platform.items[j - k][i], &platform.items[j - k - 1][i]);
                    } else break;
                }
            }
        }
    }
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
