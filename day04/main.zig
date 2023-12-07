const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"));
    std.debug.print("Day 02|1: {d}\n", .{part1});
    // const part2 = solvePart2(@embedFile("input.txt"));
    // std.debug.print("Day 01|2: {d}\n", .{part2});
}

fn solve(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenize(u8, input, "\r\n");

    var your = std.ArrayList(std.ArrayList(u8)).init(allocator);
    var mine = std.ArrayList(std.ArrayList(u8)).init(allocator);

    while (lines.next()) |line| {
        const sidx = std.mem.indexOfScalar(u8, line, ':').?;

        var numberList = std.mem.tokenizeScalar(u8, line[sidx + 1 ..], '|');

        var nums = std.mem.tokenizeScalar(u8, numberList.next().?, ' ');

        try your.append(std.ArrayList(u8).init(allocator));
        var card = &your.items[your.items.len - 1];

        while (nums.next()) |num| {
            try card.append(try std.fmt.parseInt(u8, num, 10));
            std.debug.print("{d} ", .{card.getLast()});
        }
        std.debug.print("|", .{});

        nums = std.mem.tokenizeScalar(u8, numberList.next().?, ' ');

        try mine.append(std.ArrayList(u8).init(allocator));
        while (nums.next()) |num| {
            card = &mine.items[your.items.len - 1];
            try card.append(try std.fmt.parseInt(u8, num, 10));
            std.debug.print("{d} ", .{card.getLast()});
        }
        std.debug.print("\n", .{});
    }

    // part1
    // var total: usize = 0;
    // for (your.items, mine.items) |winNums, posNums| {
    //     var points: usize = 0;
    //     for (winNums.items) |num| {
    //         if (std.mem.indexOfScalar(u8, posNums.items, num)) |_| {
    //             if (points == 0) points += 1 else points *= 2;
    //         }
    //     }
    //     // std.debug.print("points: {d}\n", .{points});
    //     total += points;
    // }

    // part2
    var total: usize = 0;

    var cardTotals = std.ArrayList(usize).init(allocator);
    try cardTotals.appendNTimes(1, your.items.len);

    for (cardTotals.items, 0..) |card, i| {
        var matches: usize = 0;
        for (your.items[i].items) |num| {
            if (std.mem.indexOfScalar(u8, mine.items[i].items, num)) |_| matches += 1;
        }

        std.debug.print("matches: {d}\n", .{matches});
        for (0..matches) |j| {
            cardTotals.items[i + 1 + j] += card;
        }
        total += card;
    }

    // for (your.items, mine.items) |winNums, posNums| {
    //     var points: usize = 0;
    //     for (winNums.items) |num| {
    //         if (std.mem.indexOfScalar(u8, posNums.items, num)) |_| {
    //             if (points == 0) points += 1 else points *= 2;
    //         }
    //     }
    //     // std.debug.print("points: {d}\n", .{points});
    //     total += points;
    // }

    return total;
}
