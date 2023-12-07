const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 02|1: {d}\n", .{part1});
    const part2 = try solve(@embedFile("input.txt"), 2);
    std.debug.print("Day 01|2: {d}\n", .{part2});
}

const ScratchCards = std.ArrayList(std.ArrayList(u8));

fn solve(input: []const u8, comptime whatPart: u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenize(u8, input, "\r\n");

    var scratchCards = [_]ScratchCards{ ScratchCards.init(allocator), ScratchCards.init(allocator) };

    var numCards: usize = 0;
    while (lines.next()) |line| : (numCards += 1) {
        const sidx = std.mem.indexOfScalar(u8, line, ':').?;

        var numberList = std.mem.tokenizeScalar(u8, line[sidx + 1 ..], '|');
        var i: usize = 0;
        while (numberList.next()) |numbers| : (i += 1) {
            var nums = std.mem.tokenizeScalar(u8, numbers, ' ');

            var cardPtr = &scratchCards[i];
            try cardPtr.append(std.ArrayList(u8).init(allocator));
            var card = &cardPtr.items[cardPtr.items.len - 1];

            while (nums.next()) |num| {
                try card.append(try std.fmt.parseInt(u8, num, 10));
            }
        }
    }

    var total: usize = 0;
    if (comptime whatPart == 1) {
        for (scratchCards[0].items, scratchCards[1].items) |winNums, posNums| {
            var points: usize = 0;
            for (winNums.items) |num| {
                if (std.mem.indexOfScalar(u8, posNums.items, num)) |_| {
                    if (points == 0) points += 1 else points *= 2;
                }
            }
            total += points;
        }
    } else {
        var cardTotals = std.ArrayList(usize).init(allocator);
        try cardTotals.appendNTimes(1, numCards);

        for (cardTotals.items, 0..) |card, i| {
            var matches: usize = 0;
            for (scratchCards[0].items[i].items) |num| {
                if (std.mem.indexOfScalar(u8, scratchCards[1].items[i].items, num)) |_| matches += 1;
            }

            for (0..matches) |j| {
                cardTotals.items[i + 1 + j] += card;
            }
            total += card;
        }
    }

    return total;
}

test "test-part1" {
    const result = try solve(@embedFile("test.txt"), 1);
    try std.testing.expectEqual(result, 13);
}

test "test-part2" {
    const result = try solve(@embedFile("test.txt"), 2);
    try std.testing.expectEqual(result, 30);
}
