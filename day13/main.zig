const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 13|1: {d}\n", .{part1});
    const part2 = try solve(@embedFile("input.txt"), 2);
    std.debug.print("Day 13|2: {d}\n", .{part2});
}

fn solve(input: []const u8, comptime part: usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.splitSequence(u8, input, "\r\n");

    var patterns = std.ArrayList(std.ArrayList([]u8)).init(allocator);

    try patterns.append(std.ArrayList([]u8).init(allocator));

    var i: usize = 0;
    while (lines.next()) |line| : (i += 1) {
        var tmp = &patterns.items[patterns.items.len - 1];
        if (line.len == 0) {
            try patterns.append(std.ArrayList([]u8).init(allocator));
            continue;
        }

        try tmp.append(try allocator.dupe(u8, line));
    }

    var sum: usize = 0;
    if (comptime part == 1) {
        for (patterns.items) |*pattern| {
            sum += VerticalSymmetry(pattern, 0) orelse 0;
            sum += 100 * (HorizontalSymmetry(pattern, 0) orelse 0);
        }
    } else {
        outer: for (patterns.items) |*pattern| {
            const hline = HorizontalSymmetry(pattern, 0);
            const vline = VerticalSymmetry(pattern, 0);

            for (0..pattern.items.len) |j| {
                for (0..pattern.items[0].len) |k| {
                    const c = pattern.items[j][k];
                    pattern.items[j][k] = if (c == '.') '#' else '.';

                    if (hline) |val| {
                        if (HorizontalSymmetry(pattern, val)) |v| {
                            sum += 100 * v;
                            continue :outer;
                        }
                        if (VerticalSymmetry(pattern, 0)) |v| {
                            sum += v;
                            continue :outer;
                        }
                    }
                    if (vline) |val| {
                        if (VerticalSymmetry(pattern, val)) |v| {
                            sum += v;
                            continue :outer;
                        }
                        if (HorizontalSymmetry(pattern, 0)) |v| {
                            sum += 100 * v;
                            continue :outer;
                        }
                    }
                    pattern.items[j][k] = c;
                }
            }
        }
    }

    return sum;
}

fn VerticalSymmetry(pattern: *std.ArrayList([]u8), prev: usize) ?usize {
    for (1..pattern.items[0].len) |i| {
        if (prev == i) continue;
        const offset = @min(i, pattern.items[0].len - i);

        for (0..offset) |j| {
            const good = for (0..pattern.items.len) |k| {
                if (pattern.items[k][i + j] != pattern.items[k][i - j - 1]) break false;
            } else true;

            if (!good) break;
        } else return i;
    }
    return null;
}

fn HorizontalSymmetry(pattern: *std.ArrayList([]u8), prev: usize) ?usize {
    for (1..pattern.items.len) |i| {
        if (prev == i) continue;
        const offset = @min(i, pattern.items.len - i);

        for (0..offset) |j| {
            if (!std.mem.eql(u8, pattern.items[i + j], pattern.items[i - j - 1])) break;
        } else return i;
    }
    return null;
}
