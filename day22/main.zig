const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 22|1: {d}\n", .{part1});
    const part2 = try solve(@embedFile("input.txt"), 2);
    std.debug.print("Day 22|2: {d}\n", .{part2});
}

const Brick = struct { start: [3]usize, end: [3]usize };

fn cmpByHeight(context: void, a: Brick, b: Brick) bool {
    return std.sort.asc(usize)(context, a.end[2], b.end[2]);
}

fn solve(input: []const u8, comptime part: usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.splitSequence(u8, input, "\r\n");

    var bricks = std.ArrayList(Brick).init(allocator);

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        var iter = std.mem.tokenize(u8, line, ",~");

        const start: [3]usize = [_]usize{
            try std.fmt.parseInt(usize, iter.next().?, 10),
            try std.fmt.parseInt(usize, iter.next().?, 10),
            try std.fmt.parseInt(usize, iter.next().?, 10),
        };
        const end: [3]usize = [_]usize{
            try std.fmt.parseInt(usize, iter.next().?, 10),
            try std.fmt.parseInt(usize, iter.next().?, 10),
            try std.fmt.parseInt(usize, iter.next().?, 10),
        };

        try bricks.append(Brick{ .start = start, .end = end });
    }

    std.mem.sort(Brick, bricks.items, {}, cmpByHeight);

    SimulateFallingBrick(&bricks.items, bricks.items.len); // bricks are now the default state

    var sum: usize = 0;

    var criticalBricks = std.ArrayList(usize).init(allocator);

    for (0..bricks.items.len) |i| {
        var nBricks = try bricks.clone();

        SimulateFallingBrick(&nBricks.items, i);

        const critical: bool = for (nBricks.items[i..], bricks.items[i..]) |lhs, rhs| {
            if (!(std.mem.eql(usize, &lhs.start, &rhs.start) and std.mem.eql(usize, &lhs.end, &rhs.end))) {
                break false;
            }
        } else blk: {
            sum += 1;
            break :blk true;
        };

        if (!critical) try criticalBricks.append(i);
    }

    if (comptime part == 2) {
        var brickRef = try std.ArrayList(*Brick).initCapacity(allocator, bricks.items.len);

        sum = 0;
        for (criticalBricks.items) |idx| {
            var nBricks = try bricks.clone();
            for (nBricks.items) |*ptr| {
                brickRef.appendAssumeCapacity(ptr);
            }

            SimulateFallingBrick(&nBricks.items, idx);

            var numFalling: usize = 0;
            for (brickRef.items, bricks.items, 0..) |lhs, rhs, i| {
                if (i == idx) continue;
                if (!(std.mem.eql(usize, &lhs.start, &rhs.start) and std.mem.eql(usize, &lhs.end, &rhs.end))) {
                    numFalling += 1;
                }
            } else sum += numFalling;
            brickRef.clearRetainingCapacity();
        }
    }
    return sum;
}

fn SimulateFallingBrick(bricks: *[]Brick, skipIdx: usize) void {
    var maxGridHeights: [10][10]usize = [_][10]usize{[_]usize{0} ** 10} ** 10;

    for (bricks.*, 0..) |*b, idx| {
        if (idx == skipIdx) continue;
        var newHeight: usize = 0;
        for (b.start[1]..b.end[1] + 1) |j| {
            for (b.start[0]..b.end[0] + 1) |i| {
                newHeight = @max(newHeight, maxGridHeights[j][i]);
            }
        } else newHeight += 1;

        const amountToFall: usize = b.start[2] - newHeight;
        b.start[2] -= amountToFall;
        b.end[2] -= amountToFall;

        for (b.start[1]..b.end[1] + 1) |j| {
            for (b.start[0]..b.end[0] + 1) |i| {
                maxGridHeights[j][i] = newHeight + (b.end[2] - b.start[2]);
            }
        }
    }
}
