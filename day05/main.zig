const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("test.txt"));
    std.debug.print("Day 02|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("input.txt"), 2);
    // std.debug.print("Day 01|2: {d}\n", .{part2});
}

const Ranges = struct { src: usize = 0, des: usize = 0, len: usize = 0 };

const Bounds = struct { lSrc: usize = 0, rSrc: usize = 0, lDes: usize = 0, rDes: usize = 0 };

fn solve(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var seeds = std.ArrayList(usize).init(allocator);
    var maps = [_]std.ArrayList(Ranges){std.ArrayList(Ranges).init(allocator)} ** 7;

    // Parse the input
    var lines = std.mem.tokenize(u8, input, "\r\n");

    // Seed Parsing
    var nums = std.mem.tokenizeScalar(u8, lines.next().?, ' ');
    _ = nums.next();
    while (nums.next()) |line| {
        try seeds.append(try std.fmt.parseInt(u8, line, 10));
    } else _ = nums.next();

    var i: usize = 0;
    while (nums.next()) |line| {
        if (std.ascii.isAlphabetic(line[0])) continue;
        if (line.len == 0) {
            i += 1;
            continue;
        }

        nums = std.mem.tokenizeScalar(u8, line, ' ');

        try maps[i].append(.{ .src = try std.fmt.parseInt(u8, nums.next().?, 10), .des = try std.fmt.parseInt(u8, nums.next().?, 10), .len = try std.fmt.parseInt(u8, nums.next().?, 10) });

        // while (nums.next()) |num| {
        //     try maps[i].append(try std.fmt.parseInt(u8, num, 10));
        // }
    }

    try GetUniqueNumbers(maps[0], allocator);

    return 0;
}

fn GetUniqueNumbers(map: std.ArrayList(Ranges), allocator: std.mem.Allocator) !void {
    var uniqueNumbers = std.ArrayList(Bounds).init(allocator);

    for (map.items) |range| {
        var leftSrc = range.src;
        var leftDes = range.des;
        var rightSrc = leftSrc + range.len - 1;
        var rightDes = rightSrc + range.len - 1;

        for (uniqueNumbers.items) |bounds| {
            if (bounds.lSrc >= leftSrc) leftSrc = bounds.lSrc + 1;
            if (bounds.lDes >= leftDes) leftDes = bounds.lDes + 1;

            if (bounds.rSrc <= rightSrc) rightSrc = bounds.rSrc - 1;
            if (bounds.rDes <= rightDes) rightDes = bounds.rDes - 1;

            if ((rightSrc < leftSrc) or (rightDes < leftDes)) break;
        } else {
            try uniqueNumbers.append(.{ .lSrc = leftSrc, .rSrc = rightSrc, .lDes = leftDes, .rDes = rightDes });
        }
    }
}
