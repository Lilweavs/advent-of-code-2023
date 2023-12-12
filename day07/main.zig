const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 02|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("test.txt"), 2);
    // std.debug.print("Day 01|2: {d}\n", .{part2});
}

fn CardStrength(in: u8) u8 {
    return switch (in) {
        '2'...'9' => in - '0' - 2,
        'T' => 8,
        'J' => 9,
        'Q' => 10,
        'K' => 11,
        'A' => 12,
        else => unreachable,
    };
}

fn CompareHandStrength(_: void, lhs: Hand, rhs: Hand) bool {
    const lscore = GetHandScore(lhs.hand);
    const rscore = GetHandScore(rhs.hand);

    if (lscore < rscore) {
        return true;
    } else if (lscore > rscore) {
        return false;
    } else {
        var i: usize = 0;
        while (lhs.hand[i] == rhs.hand[i]) i += 1;
        return (CardStrength(lhs.hand[i]) < CardStrength(rhs.hand[i]));
    }
    return false;
}

fn GetHandScore(hand: [5]u8) usize {
    var cardNums = [_]u8{0} ** 13;
    for (hand) |card| {
        cardNums[CardStrength(card)] += 1;
    }

    if (std.mem.indexOfScalar(u8, &cardNums, 5)) |_| {
        return 6;
    } // 5 of a kind

    if (std.mem.indexOfScalar(u8, &cardNums, 4)) |_| {
        return 5;
    } // 4 of a kind

    if (std.mem.indexOfScalar(u8, &cardNums, 3)) |_| {
        if (std.mem.indexOfScalar(u8, &cardNums, 2)) |_| {
            return 4;
        } else {
            return 3;
        }
    }

    var twos: usize = 0;
    for (cardNums) |card| {
        if (card == 2) twos += 1;
    }
    if (twos == 2) return 2;

    if (std.mem.indexOfScalar(u8, &cardNums, 2)) |_| {
        return 1;
    } // full house

    return 0;

    // var handScore: usize = 0;
    // for (0..5) |i| {
    //     if (std.mem.lastIndexOfScalar(u8, &cardNums, @intCast(5 - i))) |idx| {
    //         const tmp = std.math.powi(usize, 13, cardNums[idx] - 1) catch 0;
    //         handScore += idx * tmp;
    //     }
    // }

    // // std.debug.print("score: {d}\n", .{handScore});
    // return handScore;
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
    PrintHands(records);

    var total: usize = 0;

    for (records.items, 1..) |hand, i| {
        total += hand.bid * i;
    }

    std.debug.print("score: {d}\n", .{GetHandScore(records.items[0].hand)});

    return total;
}

fn PrintHands(records: std.ArrayList(Hand)) void {
    for (records.items) |game| {
        std.debug.print("{s}\n", .{game.hand});
        // for (game.hand) |v| {
        //     std.debug.print("{d} ", .{v});
        // }
        // std.debug.print("\n", .{});
    }
}
