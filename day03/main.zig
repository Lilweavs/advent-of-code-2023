const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"));
    std.debug.print("Day 02|1: {d}\n", .{part1});
    // const part2 = solvePart2(@embedFile("input.txt"));
    // std.debug.print("Day 01|2: {d}\n", .{part2});
}

fn parseNumber(str: *std.ArrayList(u8), idx: usize) usize {
    if (!std.ascii.isDigit(str.items[idx])) return 0;
    var left: usize = idx;
    var right: usize = idx;
    while (right < str.items.len and std.ascii.isDigit(str.items[right])) {
        right += 1;
    }
    while (left != 0 and std.ascii.isDigit(str.items[left - 1])) {
        left -= 1;
    }

    var retval = std.fmt.parseInt(usize, str.items[left..right], 10) catch 0;

    for (left..right) |i| {
        str.items[i] = '.';
    }

    std.debug.print("{d}\n", .{retval});
    return retval;
}

fn print(grid: *std.ArrayList(std.ArrayList(u8))) void {
    std.debug.print("\n", .{});
    for (grid.items) |line| {
        std.debug.print("{s}\n", .{line.items});
    }
}

fn solve(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenize(u8, input, "\r\n");

    var schematic = std.ArrayList(std.ArrayList(u8)).init(allocator);

    while (lines.next()) |line| {
        try schematic.append(std.ArrayList(u8).init(allocator));
        try schematic.items[schematic.items.len - 1].appendSlice(line);
    }

    var total: usize = 0;
    // std.debug.print("\n{d}\n", .{total});
    for (0..schematic.items.len) |i| {
        for (0..schematic.items[i].items.len) |j| {
            const c = schematic.items[i].items[j];
            if (c == '.' or std.ascii.isAlphanumeric(c)) continue;
            if (j > 0) {
                total += parseNumber(&schematic.items[i], j - 1);
            } // left

            if (j < schematic.items[i].items.len - 1) {
                total += parseNumber(&schematic.items[i], j + 1);
            } // right

            if (i > 0) {
                total += parseNumber(&schematic.items[i - 1], j);
            } // up

            if (i < schematic.items.len - 1) {
                total += parseNumber(&schematic.items[i + 1], j);
            } // down

            if (j > 0 and i > 0) {
                total += parseNumber(&schematic.items[i - 1], j - 1);
            } // left up

            if ((j < schematic.items[i].items.len - 1) and i > 0) {
                total += parseNumber(&schematic.items[i - 1], j + 1);
            } // right up

            if (j > 0 and i < (schematic.items.len - 1)) {
                total += parseNumber(&schematic.items[i + 1], j - 1);
            } // left down

            if ((j < schematic.items[i].items.len - 1) and i < (schematic.items.len - 1)) {
                total += parseNumber(&schematic.items[i + 1], j + 1);
            } // right down
        }
        // print(&schematic);

    }
    return total;
}

test "test-part1" {
    const result = try solve(@embedFile("test.txt"));
    try std.testing.expectEqual(result, 4361);
}
