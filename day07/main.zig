const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 02|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("test.txt"), 2);
    // std.debug.print("Day 01|2: {d}\n", .{part2});
}

// fn CardStrength(in: u8) u8 {
//     return switch (in) {
//         '2'...'9' => in - '0' - 2,
//         'T' => 8,
//         'J' => 9,
//         'Q' => 10,
//         'K' => 11,
//         'A' => 12,
//         else => unreachable,
//     };
// }

fn CardStrength(in: u8) u8 {
    return switch (in) {
        'J' => 0,
        '2'...'9' => in - '0' - 1,
        'T' => 9,
        'Q' => 10,
        'K' => 11,
        'A' => 12,
        else => unreachable,
    };
}

fn CompareHandStrength(_: void, lhs: Hand, rhs: Hand) bool {
    const lscore = GetHandScore(lhs.hand);
    const rscore = GetHandScore(rhs.hand);

    if (lscore == rscore) {
        var i: usize = 0;
        while (lhs.hand[i] == rhs.hand[i]) i += 1;
        return (CardStrength(lhs.hand[i]) < CardStrength(rhs.hand[i]));
    }
    return lscore < rscore;
}

fn GetHandScore(hand: [5]u8) usize {
    var cardNums = [_]u8{0} ** 13;
    for (hand) |card| {
        cardNums[CardStrength(card)] += 1;
    }

    const jokers: usize = cardNums[0];
    std.mem.sort(u8, &cardNums, {}, std.sort.desc(u8));

    // part 1
    // if (cardNums[0] == 5) return 6;
    // if (cardNums[0] == 4) return 5;
    // if (cardNums[0] == 3 and cardNums[1] == 2) return 4;
    // if (cardNums[0] == 3) return 3;
    // if (cardNums[0] == 2 and cardNums[1] == 2) return 2;
    // if (cardNums[0] == 2) return 1;
    // return 0;

    // part 2
    if (cardNums[0] == 5) return 6;
    if (cardNums[0] == 4) {
        if (jokers == 4 or jokers == 1) return 6;
        return 5;
    }
    if (cardNums[0] == 3 and cardNums[1] == 2) {
        return if (jokers != 0) 6 else 4;
    }
    if (cardNums[0] == 3) {
        if (jokers == 3 or jokers == 1) return 5;
        return 3;
    }
    if (cardNums[0] == 2 and cardNums[1] == 2) {
        if (jokers == 2) return 5;
        if (jokers == 1) return 4;
        return 2;
    }
    if (cardNums[0] == 2) {
        if (jokers == 2 or jokers == 1) return 3;
        return 1;
    }
    return if (jokers == 1) 1 else 0;
}

const Hand = struct { hand: [5]u8 = [_]u8{0} ** 5, bid: usize = 0 };

fn solve(input: []const u8, comptime part: usize) !usize {
    _ = part;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var records = std.ArrayList(Hand).init(allocator);

    var lines = std.mem.tokenize(u8, input, "\r\n");

    while (lines.next()) |line| {
        var ptr = std.mem.tokenizeScalar(u8, line, ' ');
        try records.append(Hand{});
        var handPtr = &records.items[records.items.len - 1];

        var hand = ptr.next().?;
        for (0..5) |_| {
            handPtr.hand = hand[0..5].*;
        }
        handPtr.bid = try std.fmt.parseInt(usize, ptr.next().?, 10);
    }

    std.mem.sort(Hand, records.items, {}, CompareHandStrength);

    var total: usize = 0;

    for (records.items, 1..) |hand, i| {
        total += hand.bid * i;
    }

    return total;
}
