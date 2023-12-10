const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("test.txt"), 1);
    std.debug.print("Day 02|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("test.txt"), 2);
    // std.debug.print("Day 01|2: {d}\n", .{part2});
}

fn CardStrength(in: u8) usize {
    return switch (in) {
        '2'...'9' => in - '0',
        'T' => 10,
        'J' => 11,
        'Q' => 12,
        'K' => 13,
        'A' => 14,
        else => unreachable,
    };
}

const Hand = struct { hand: [5]u8, bid: usize };

fn solve(input: []const u8, comptime part: usize) !usize {
    _ = part;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var gameRecords = std.ArrayList(Hand).init(allocator);
    _ = gameRecords;

    var lines = std.mem.tokenize(u8, input, "\r\n");

    while (lines.next()) |line| {
        var ptr = std.mem.tokenizeScalar(u8, line, ' ');
    }

    return 0;
}
