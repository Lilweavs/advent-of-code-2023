const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("test.txt"), 1);
    std.debug.print("Day 12|1: {d}\n", .{part1});
    const part2 = try solve(@embedFile("test.txt"), 2);
    std.debug.print("Day 12|2: {d}\n", .{part2});
}

const Record = struct { springs: []const u8 = undefined, record: []u8 = undefined };

fn solve(input: []const u8, comptime part: usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenize(u8, input, "\r\n");

    var records = std.ArrayList(Record).init(allocator);

    while (lines.next()) |line| {
        try records.append(Record{});

        var record = &records.items[records.items.len - 1];

        var tokens = std.mem.tokenize(u8, line, " ,");
        const strPtr = tokens.next().?;

        var string = std.ArrayList(u8).init(allocator);

        try string.appendSlice(strPtr);

        var array = std.ArrayList(u8).init(allocator);
        while (tokens.next()) |num| {
            try array.append(try std.fmt.parseInt(u8, num, 10));
        }

        if (part == 2) {
            for (0..4) |_| {
                try string.append('?');
                try string.appendSlice(strPtr);
            }
            const tmp = try allocator.dupe(u8, array.items);
            for (0..4) |_| {
                try array.appendSlice(tmp);
            }
        }

        try string.appendSlice("..");
        try array.append(0);

        record.springs = try string.toOwnedSlice();
        record.record = try array.toOwnedSlice();
    }

    var sum: usize = 0;
    for (records.items) |r| {
        sum += try calculateSpringPermutations(r.springs, r.record, allocator);
    }

    return sum;
}

fn calculateSpringPermutations(spring: []const u8, record: []u8, allocator: std.mem.Allocator) !usize {
    var sum: usize = 0;

    var permutationGrid = std.ArrayList(std.ArrayList(usize)).init(allocator);

    try permutationGrid.append(try std.ArrayList(usize).initCapacity(allocator, spring.len));
    var tmp = &permutationGrid.items[permutationGrid.items.len - 1];
    tmp.appendNTimesAssumeCapacity(0, spring.len);
    for (0..spring.len) |i| {
        if (spring[spring.len - 1 - i] == '#') break else tmp.items[tmp.items.len - 1 - i] = 1;
    }

    try permutationGrid.append(try std.ArrayList(usize).initCapacity(allocator, spring.len));
    tmp = &permutationGrid.items[permutationGrid.items.len - 1];
    tmp.appendNTimesAssumeCapacity(0, spring.len);

    for (1..record.len) |i| {
        const prevRow = permutationGrid.items[(i - 1) % 2].items;
        const row = permutationGrid.items[i % 2].items;
        @memset(row, 0);

        const num = record[record.len - 1 - i];

        const sidx: usize = for (0..prevRow.len) |j| {
            if (prevRow[prevRow.len - 1 - j] != 0) break j + record[record.len - 1 - i] + 1;
        } else 2;

        // printTable(spring, permutationGrid, sidx);

        for (sidx..spring.len) |j| {
            const c = spring[spring.len - 1 - j];
            if (c == '?') {
                row[row.len - 1 - j] = row[row.len - j];
                if (validSpring(spring[(spring.len - 1 - j)..], num)) {
                    row[row.len - 1 - j] += prevRow[prevRow.len - 1 - j + num + 1];
                }
            } else if (c == '.') {
                row[row.len - 1 - j] = row[row.len - j];
            } else {
                if (validSpring(spring[(spring.len - 1 - j)..], num)) {
                    row[row.len - 1 - j] += prevRow[prevRow.len - 1 - j + num + 1];
                }
            }
        }
    }

    // printTable(spring, permutationGrid, sidx);

    sum += permutationGrid.items[(record.len - 1) % 2].items[0];
    return sum;
}

fn printTable(spring: []const u8, pg: std.ArrayList(std.ArrayList(usize)), sidx: usize) void {
    for (0..spring.len) |i| {
        if (i == spring.len - sidx - 1) std.debug.print("{c:3}", .{'v'}) else std.debug.print("{c:3}", .{' '});
    } else std.debug.print("\n", .{});

    for (spring) |c| {
        std.debug.print("{c:3}", .{c});
    } else std.debug.print("\n", .{});

    for (pg.items) |row| {
        for (row.items) |num| {
            std.debug.print("{d:3}", .{num});
        } else std.debug.print("\n", .{});
    }
}

fn validSpring(spring: []const u8, num: usize) bool {
    if (num > spring.len) return false;
    for (0..num) |i| {
        if (spring[i] == '.') return false;
    }

    if (num < spring.len and spring[num] == '#') return false;

    return true;
}
