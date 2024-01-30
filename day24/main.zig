const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 24|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("input.txt"), 2);
    // std.debug.print("Day 22|2: {d}\n", .{part2});
}

const Vector = struct { x: f128, y: f128, z: f128 };
const HailStone = struct { pos: Vector, vel: Vector };

fn solve(input: []const u8, comptime part: usize) !usize {
    _ = part;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.splitSequence(u8, input, "\r\n");

    var hailstones = std.ArrayList(HailStone).init(allocator);

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var iter = std.mem.tokenize(u8, line, ", @");

        try hailstones.append(HailStone{ .pos = Vector{
            .x = try std.fmt.parseFloat(f128, iter.next().?),
            .y = try std.fmt.parseFloat(f128, iter.next().?),
            .z = try std.fmt.parseFloat(f128, iter.next().?),
        }, .vel = Vector{
            .x = try std.fmt.parseFloat(f128, iter.next().?),
            .y = try std.fmt.parseFloat(f128, iter.next().?),
            .z = try std.fmt.parseFloat(f128, iter.next().?),
        } });
    }

    // const llim = @as(f128, 7);
    // const ulim = @as(f128, 27);
    const llim = @as(f128, 200000000000000);
    const ulim = @as(f128, 400000000000000);

    var loopNum: usize = 0;
    var numIntersections: usize = 0;
    for (0..hailstones.items.len) |i| {
        for (i + 1..hailstones.items.len) |j| {
            loopNum += 1;
            const lhs = hailstones.items[i];
            const rhs = hailstones.items[j];
            const ans = HailStoneIntersection2D(lhs, rhs);

            // std.debug.print("A: {d},{d},{d}\n", .{ lhs.pos.x, lhs.pos.y, lhs.pos.z });
            // std.debug.print("B: {d},{d},{d} | ", .{ rhs.pos.x, rhs.pos.y, rhs.pos.z });
            if (ans) |intersection| {
                if ((std.math.sign((intersection[0] - lhs.pos.x)) != std.math.sign(lhs.vel.x)) or (std.math.sign((intersection[0] - rhs.pos.x)) != std.math.sign(rhs.vel.x))) {
                    // std.debug.print("{d},{d} -> Past\n", .{ i, j });
                    // if (lhs.vel.x < 0 and lhs.pos.x < intersection[0]) {
                    // std.debug.print("{d},{d} -> Past\n", .{ i, j });
                    // } else if (lhs.vel.x > 0 and lhs.pos.x > intersection[0]) {
                    //     std.debug.print("{d},{d} -> Past\n", .{ i, j });
                } else if ((std.math.sign((intersection[1] - lhs.pos.y)) != std.math.sign(lhs.vel.y)) or (std.math.sign((intersection[1] - rhs.pos.y)) != std.math.sign(rhs.vel.y))) {} else {
                    if ((intersection[0] <= ulim and intersection[0] >= llim) and (intersection[1] <= ulim and intersection[1] >= llim)) {
                        // std.debug.print("{d},{d} -> [{e}, {e}]\n", .{ i, j, intersection[0], intersection[1] });
                        numIntersections += 1;
                    } else {
                        // std.debug.print("{d},{d} -> Out of bounds\n", .{ i, j });
                    }
                }
            } else {
                // std.debug.print("{d},{d} -> Parallel\n", .{ i, j });
            }
        }
    }

    std.debug.print("{d}\n", .{loopNum});

    return numIntersections;
}

fn HailStoneIntersection2D(lhs: HailStone, rhs: HailStone) ?[2]f128 {
    const a1 = -lhs.vel.y / lhs.vel.x;
    const a2 = -rhs.vel.y / rhs.vel.x;
    const c1 = lhs.pos.y + a1 * lhs.pos.x;
    const c2 = rhs.pos.y + a2 * rhs.pos.x;

    if (a1 == a2) return null;

    return .{ -(c2 - c1) / (a1 - a2), -(a2 * c1 - a1 * c2) / (a1 - a2) };
}
