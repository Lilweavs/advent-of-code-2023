const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("test.txt"), 1);
    std.debug.print("Day 05|1: {d}\n", .{part1});
    const part2 = try solve(@embedFile("test.txt"), 2);
    std.debug.print("Day 05|2: {d}\n", .{part2});
}

const Ranges = struct { des: usize = 0, src: usize = 0, len: usize = 0 };

fn solve(input: []const u8, comptime part: usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    var seeds = std.ArrayList(usize).init(allocator);
    var maps = [_]std.ArrayList(Ranges){std.ArrayList(Ranges).init(allocator)} ** 7;

    var lines = std.mem.tokenize(u8, input, "\r\n");

    var nums = std.mem.tokenizeScalar(u8, lines.next().?, ' ');
    _ = nums.next();
    while (nums.next()) |line| {
        try seeds.append(try std.fmt.parseInt(usize, line, 10));
    }

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

    if (comptime part == 1) {
        for (seeds.items) |seed| {
            min = @min(min, GetLocation(&maps, seed));
        }
        return min;
    }

    var unprocessed = std.ArrayList([2]usize).init(allocator);
    var processed = std.ArrayList([2]usize).init(allocator);

    for (0..(seeds.items.len / 2)) |j| {
        const r = [_]usize{ seeds.items[j * 2], seeds.items[2 * j] + seeds.items[2 * j + 1] };
        try unprocessed.append(r);
    }

    for (maps) |map| {
        try processed.resize(0);
        while (unprocessed.items.len != 0) {
            const range = unprocessed.pop();
            try mapRanges(range, map.items, &unprocessed, &processed);
        }
        try unprocessed.appendSlice(processed.items);
    }

    min = std.math.maxInt(usize);
    for (unprocessed.items) |r| {
        min = @min(min, r[0]);
        // std.debug.print("[{d},{d})\n", .{ r[0], r[1] });
    }

    return min;
}

fn mapRanges(range: [2]usize, map: []Ranges, unprocessed: *std.ArrayList([2]usize), processed: *std.ArrayList([2]usize)) !void {
    for (map) |r| {
        const src: [2]usize = [_]usize{ r.src, r.src + r.len };
        const m: [2]usize = [_]usize{ r.des, r.des + r.len };

        if (src[0] < range[1] and src[1] > range[0]) {
            const intersection = [_]usize{ @max(range[0], src[0]), @min(range[1], src[1]) };

            try processed.append([_]usize{ m[0] + (intersection[0] - src[0]), m[0] + (intersection[1] - src[0]) });

            if (range[0] < intersection[0]) {
                try unprocessed.append([_]usize{ range[0], intersection[0] });
            }

            if (intersection[1] < range[1]) {
                try unprocessed.append([_]usize{ intersection[1], range[1] });
            }
            break;
        }
    } else try processed.append([_]usize{ range[0], range[1] });
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
