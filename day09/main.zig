const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 02|1: {d}\n", .{part1});
    const part2 = try solve(@embedFile("input.txt"), 2);
    std.debug.print("Day 01|2: {d}\n", .{part2});
}

fn solve(input: []const u8, comptime part: usize) !isize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenize(u8, input, "\r\n");

    var scanHistory = std.ArrayList(std.ArrayList(isize)).init(allocator);

    while (lines.next()) |line| {
        try scanHistory.append(std.ArrayList(isize).init(allocator));
        var scan = &scanHistory.items[scanHistory.items.len - 1];

        var values = std.mem.tokenizeScalar(u8, line, ' ');

        while (values.next()) |value| {
            try scan.append(try std.fmt.parseInt(isize, value, 10));
        }
    }

    var total: isize = 0;
    for (scanHistory.items) |item| {
        total += try PredictNextValue(item.items, comptime part);
    }

    return total;
}

fn AllZeros(values: *std.ArrayList(isize)) bool {
    for (values.items) |item| {
        if (item != 0) return false;
    }
    return true;
}

fn PredictNextValue(history: []const isize, comptime part: usize) !isize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var diffs = std.ArrayList(std.ArrayList(isize)).init(allocator);
    try diffs.append(std.ArrayList(isize).init(allocator));

    var tmp2 = &diffs.items[diffs.items.len - 1];
    try tmp2.appendSlice(history);

    var i: usize = 0;
    while (!AllZeros(&diffs.items[diffs.items.len - 1])) : (i += 1) {
        try diffs.append(std.ArrayList(isize).init(allocator));
        var tmp = &diffs.items[diffs.items.len - 1];

        const last = diffs.items[i];

        for (0..last.items.len - 1) |j| {
            try tmp.append(last.items[j + 1] - last.items[j]);
        }
    }

    var next: isize = 0;
    for (1..diffs.items.len) |j| {
        const rowPtr = &diffs.items[diffs.items.len - 1 - j];
        if (comptime part == 1) {
            next = next + rowPtr.getLast();
        } else {
            next = rowPtr.items[0] - next;
        }
    }

    return next;
}

test "test-part1" {
    const result = try solve(@embedFile("test.txt"), 1);
    try std.testing.expectEqual(result, 114);
}

test "test-part2" {
    const result = try solve(@embedFile("test.txt"), 2);
    try std.testing.expectEqual(result, 2);
}
