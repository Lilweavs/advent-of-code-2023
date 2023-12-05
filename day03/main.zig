const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("test.txt"));
    std.debug.print("Day 02|1: {d}\n", .{part1});
    // const part2 = solvePart2(@embedFile("input.txt"));
    // std.debug.print("Day 01|2: {d}\n", .{part2});
}

fn solve(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenize(u8, input, "\r\n");

    // var schematic = std.ArrayList(u8).init(allocator);

    var schematic = std.ArrayList(std.ArrayList(u8)).init(allocator);

    // var rows: usize = 0;
    while (lines.next()) |line| {
        try schematic.append(std.ArrayList(u8).init(allocator));
        var tmp = schematic.getLast();
        try tmp.appendSlice(line);
        // rows = line.len;
        // try schematic.appendSlice(line);
    }

    for (schematic.items) |line| {
        std.debug.print("{s}\n", .{line.items});
    }

    // std.debug.print("{s}\n", .{schematic.items});

    // var total: usize = 0;
    // for (1..schematic.len-1) |c, i| {
    //     if (c != '.' and (c < 48 and c > 57)) {

    //         // \|/ - . - /|\

    //         // up-left
    //         if ((i - rows - 1)) {

    //         }
    //         // Up

    //         // up-right

    //         if std.ascii.isDigit();

    //     }
    // }

    // while (lines.next()) |line| {
    //     _ = line;
    // }

    return 0;
}
