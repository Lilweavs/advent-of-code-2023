const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 24|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("input.txt"), 2);
    // std.debug.print("Day 22|2: {d}\n", .{part2});
}

const Vector = struct { x: f128 = undefined, y: f128 = undefined, z: f128 = undefined };
const Mat3f = [9]f128;
const HailStone = struct { pos: Vector = undefined, vel: Vector = undefined };

fn sub(lhs: Vector, rhs: Vector) Vector {
    return Vector{ .x = lhs.x - rhs.x, .y = lhs.y - rhs.y, .z = lhs.z - rhs.z };
}

fn add(lhs: Vector, rhs: Vector) Vector {
    return Vector{ .x = lhs.x + rhs.x, .y = lhs.y + rhs.y, .z = lhs.z + rhs.z };
}

fn dot(lhs: Vector, rhs: Vector) f128 {
    return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z;
}

fn cross(lhs: Vector, rhs: Vector) Vector {
    return Vector{ .x = (lhs.y * rhs.z - lhs.z * rhs.y), .y = (lhs.z * rhs.x - lhs.x * rhs.z), .z = (lhs.x * rhs.y - lhs.y * rhs.x) };
}

// fn linearSystemSolver(A: Mat3f, b: Vector) Vector {
//     // gauss jordan method with pivot
// }

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
                        std.debug.print("A: {d},{d},{d} | {d}, {d}, {d}\n", .{ @as(f64, @floatCast(lhs.pos.x)), @as(f64, @floatCast(lhs.pos.y)), @as(f64, @floatCast(lhs.pos.z)), @as(f64, @floatCast(lhs.vel.x)), @as(f64, @floatCast(lhs.vel.y)), @as(f64, @floatCast(lhs.vel.z)) });
                        std.debug.print("B: {d},{d},{d} | {d}, {d}, {d} | ", .{ @as(f64, @floatCast(rhs.pos.x)), @as(f64, @floatCast(rhs.pos.y)), @as(f64, @floatCast(rhs.pos.z)), @as(f64, @floatCast(rhs.vel.x)), @as(f64, @floatCast(rhs.vel.y)), @as(f64, @floatCast(rhs.vel.z)) });
                        std.debug.print("{d},{d} -> [{e}, {e}]\n", .{ i, j, intersection[0], intersection[1] });
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

    const v1a = HailStone{ .pos = Vector{ .x = 378613557802976, .y = 343832968186921, .z = 265485333215312 }, .vel = Vector{ .x = -55, .y = -7, .z = 66 } };
    const v2a = HailStone{ .pos = Vector{ .x = 346028219022056, .y = 71761937209378, .z = 361082665598801 }, .vel = Vector{ .x = 28, .y = 317, .z = -10 } };
    const v1b = HailStone{ .pos = Vector{ .x = 210766682614070, .y = 195090312450915, .z = 153665324776120 }, .vel = Vector{ .x = 135, .y = 163, .z = 237 } };
    const v2b = HailStone{ .pos = Vector{ .x = 262034555718005, .y = 242812720175557, .z = 175962192386276 }, .vel = Vector{ .x = -129, .y = -78, .z = 187 } };
    const v1c = HailStone{ .pos = Vector{ .x = 247904518343169, .y = 354588433650479, .z = 202903172797639 }, .vel = Vector{ .x = 107, .y = -40, .z = 144 } };
    const v2c = HailStone{ .pos = Vector{ .x = 346028219022056, .y = 71761937209378, .z = 361082665598801 }, .vel = Vector{ .x = 28, .y = 317, .z = -10 } };

    // A: 378613557802976,343832968186921,265485333215312 | -55, -7, 66
    // B: 346028219022056,71761937209378,361082665598801 | 28, 317, -10 | 288,299 -> [3.699624763052137e+14, 3.427319214508422e+14]
    // A: 210766682614070,195090312450915,153665324776120 | 135, 163, 237
    // B: 262034555718005,242812720175557,175962192386276 | -129, -78, 187 | 290,293 -> [2.3851127885492022e+14, 2.2858934346764528e+14]
    // A: 247904518343169,354588433650479,202903172797639 | 107, -40, 144
    // B: 346028219022056,71761937209378,361082665598801 | 28, 317, -10 | 297,299 -> [3.67074756839265e+14, 3.1003881178277956e+14]

    const row1 = cross(sub(v2a.vel, v1a.vel), sub(v2a.pos, v1a.pos));
    const row2 = cross(sub(v2b.vel, v1b.vel), sub(v2b.pos, v1b.pos));
    const row3 = cross(sub(v2c.vel, v1c.vel), sub(v2c.pos, v1c.pos));
    const b1 = dot(v1a.pos, cross(v1a.vel, v2a.pos)) + dot(v2a.pos, cross(v2a.vel, v1a.pos));
    const b2 = dot(v1b.pos, cross(v1b.vel, v2b.pos)) + dot(v2b.pos, cross(v2b.vel, v1b.pos));
    const b3 = dot(v1c.pos, cross(v1c.vel, v2c.pos)) + dot(v2c.pos, cross(v2c.vel, v1c.pos));

    var m: Mat3f = undefined;
    var b: Vector = undefined;

    m[0] = row1.x;
    m[1] = row1.y;
    m[2] = row1.z;
    m[3] = row2.x;
    m[4] = row2.y;
    m[5] = row2.z;
    m[6] = row3.x;
    m[7] = row3.y;
    m[8] = row3.z;

    b.x = b1;
    b.y = b2;
    b.z = b3;

    for (0..3) |j| {
        for (0..3) |i| {
            std.debug.print("{e} ", .{m[3 * j + i]});
        } else std.debug.print("\n", .{});
    }

    std.debug.print("[{e},{e},{e}]\n", .{ b.x, b.y, b.z });

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
