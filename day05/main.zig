const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"));
    std.debug.print("Day 02|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("input.txt"), 2);
    // std.debug.print("Day 01|2: {d}\n", .{part2});
}

const Ranges = struct { des: usize = 0, src: usize = 0, len: usize = 0 };

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
        try seeds.append(try std.fmt.parseInt(usize, line, 10));
    } else _ = nums.next();

    var i: i32 = -1;
    while (lines.next()) |line| {
        if (std.ascii.isAlphabetic(line[0])) {
            i += 1;
            continue;
        }

        nums = std.mem.tokenizeScalar(u8, line, ' ');

        try maps[@intCast(i)].append(.{ .des = try std.fmt.parseInt(usize, nums.next().?, 10), .src = try std.fmt.parseInt(usize, nums.next().?, 10), .len = try std.fmt.parseInt(usize, nums.next().?, 10) });
    }

    var min: usize = std.math.maxInt(usize);
    for (seeds.items) |seed| {
        min = @min(min, GetLocation(&maps, seed));
    }

    return min;
}

fn GetLocation(maps: *[7]std.ArrayList(Ranges), seed: usize) usize {
    var retVal = seed;
    for (maps) |ranges| {
        for (ranges.items) |range| {
            if ((retVal >= range.src) and (retVal <= range.src + range.len - 1)) {
                retVal = retVal - range.src + range.des;
                break;
            }
        }
    }

    return retVal;
}
