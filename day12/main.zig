const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 11|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("input.txt"), 2);
    // std.debug.print("Day 11|2: {d}\n", .{part2});
}

const Record = struct { springs: []const u8 = undefined, record: []u8 = undefined };

fn solve(input: []const u8, comptime part: usize) !usize {
    _ = part;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenize(u8, input, "\r\n");

    var records = std.ArrayList(Record).init(allocator);

    while (lines.next()) |line| {
        try records.append(Record{});

        var record = &records.items[records.items.len - 1];

        var tokens = std.mem.tokenize(u8, line, " ,");

        record.springs = tokens.next().?;

        var array = std.ArrayList(u8).init(allocator);
        while (tokens.next()) |num| {
            try array.append(try std.fmt.parseInt(u8, num, 10));
        }

        record.record = try array.toOwnedSlice();
    }

    for (records.items) |record| {
        std.debug.print("{s}\n", .{record.springs});
    }

    // var rec = records.getLast();

    // var qcnt: usize = 0;
    // for (rec.springs) |c| {
    //     if (c == '?') qcnt += 1;
    // }

    // std.debug.print("{}\n", .{CheckSpringValidity(rec)});

    // get every permutation
    var validPermutations: usize = 0;

    for (records.items, 0..) |record, n| {
        var qcnt: usize = 0;
        var badCount: usize = 0;
        for (record.springs) |c| {
            if (c == '?') qcnt += 1;
            if (c == '#') badCount += 1;
        }

        var needed: usize = 0;
        for (record.record) |num| needed += num;

        const numPermutations = try std.math.powi(usize, 2, qcnt);
        for (0..numPermutations) |i| {
            var springs = try std.mem.Allocator.dupe(allocator, u8, record.springs);
            defer allocator.free(springs);

            var numSet: usize = 0;
            for (0..qcnt) |shift| {
                const idx = std.mem.indexOfScalar(u8, springs, '?').?;
                if ((i >> @as(u6, @intCast(shift)) & 1) == 1) {
                    numSet += 1;
                    springs[idx] = '#';
                } else {
                    springs[idx] = '.';
                }
            }

            if (numSet + badCount != needed) continue;

            if (CheckSpringValidity(springs, record.record)) {
                validPermutations += 1;
                // std.debug.print("{s} G\n", .{springs});
            } else {
                // std.debug.print("{s} B\n", .{springs});
            }
        }
        std.debug.print("{d}\n", .{n});
    }

    // for (rec.record) |num| {
    //     // get every permutation

    //     for (sidx..springs.len) |i| {
    //         if (springs[i] == '.') continue;

    //         if (num + i == springs.len) break; // not possible

    //         for (0..num) |j| {
    //             springs[i + j] = '#';
    //             std.debug.print("{s}\n", .{springs});
    //         } else {
    //             if (springs[i + num] == '?' or springs[i + num] == '.') {
    //                 springs[i + num] = '.';
    //             }
    //         }
    //     }
    // }

    return validPermutations;
}

fn CheckSpringValidity(springs: []u8, record: []u8) bool {
    var k: usize = 0;
    var sidx: usize = 0;
    while (std.mem.indexOfScalarPos(u8, springs, sidx, '#')) |i| : (k += 1) {
        if (k == record.len) return false;
        const num = record[k];
        // if (sidx + num > record.springs.len) return false;

        for (0..num) |j| {
            // std.debug.print("{d},{c}\n", .{ i, springs[i + j] });
            if (springs[i + j] != '#') return false;
        }
        if (i + num < springs.len and springs[i + num] == '#') return false;
        sidx = i + num;
    }
    return true;
}
