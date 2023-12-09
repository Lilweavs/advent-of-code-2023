const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 02|1: {d}\n", .{part1});
    const part2 = try solve(@embedFile("input.txt"), 2);
    std.debug.print("Day 01|2: {d}\n", .{part2});
}

fn solve(input: []const u8, comptime part: usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var gameRecords = std.ArrayList([2]usize).init(allocator);

    var lines = std.mem.tokenize(u8, input, "\r\n");

    var timePtr = std.mem.tokenizeScalar(u8, lines.next().?, ' ');
    _ = timePtr.next();
    var distPtr = std.mem.tokenizeScalar(u8, lines.next().?, ' ');
    _ = distPtr.next();

    if (comptime part == 1) {
        while (timePtr.next()) |time| {
            try gameRecords.append(.{ try std.fmt.parseInt(usize, time, 10), try std.fmt.parseInt(usize, distPtr.next().?, 10) });
        }
    } else {
        var tmp1 = std.ArrayList(u8).init(allocator);
        var tmp2 = std.ArrayList(u8).init(allocator);
        while (timePtr.next()) |text| {
            try tmp1.appendSlice(text);
            try tmp2.appendSlice(distPtr.next().?);
        }
        try gameRecords.append(.{ try std.fmt.parseInt(usize, tmp1.items, 10), try std.fmt.parseInt(usize, tmp2.items, 10) });
    }

    var total: usize = 1;
    for (gameRecords.items) |record| {
        const out = FindPossibiliesToWin(@floatFromInt(record[0]), @floatFromInt(record[1]));
        const min: usize = @intFromFloat(@ceil(out[0]));
        const max: usize = @intFromFloat(@floor(out[1]));
        total *= (max - min + 1);
    }

    return total;
}

fn FindPossibiliesToWin(b: f64, c: f64) [2]f64 {
    return .{ 0.5 * (b - @sqrt(b * b - 4 * (c + 1))), 0.5 * (b + @sqrt(b * b - 4 * (c + 1))) };
}

test "test-part1" {
    const result = try solve(@embedFile("test.txt"), 1);
    try std.testing.expectEqual(result, 288);
}

test "test-part2" {
    const result = try solve(@embedFile("test.txt"), 2);
    try std.testing.expectEqual(result, 71503);
}
