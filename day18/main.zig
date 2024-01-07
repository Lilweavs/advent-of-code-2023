const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 18|1: {d}\n", .{part1});
    const part2 = try solve(@embedFile("input.txt"), 2);
    std.debug.print("Day 18|2: {d}\n", .{part2});
}

const Grid = struct { x: isize = undefined, y: isize = undefined };

const Plan = struct { dir: u8 = undefined, dis: isize = undefined };

fn solve(input: []const u8, comptime part: usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenize(u8, input, "\r\n");

    var digPlan = std.ArrayList(Plan).init(allocator);

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var iter = std.mem.tokenize(u8, line, " ()#");

        if (comptime part == 1) {
            const plan = Plan{ .dir = iter.next().?[0], .dis = try std.fmt.parseInt(isize, iter.next().?, 10) };

            try digPlan.append(plan);
        } else {
            _ = iter.next();
            _ = iter.next();
            const ins = iter.next().?;

            const plan = Plan{ .dir = switch (ins[ins.len - 1]) {
                '0' => 'R',
                '2' => 'L',
                '1' => 'D',
                '3' => 'U',
                else => unreachable,
            }, .dis = try std.fmt.parseInt(isize, ins[0 .. ins.len - 1], 16) };
            try digPlan.append(plan);
        }
    }

    var vertices = try std.ArrayList(Grid).initCapacity(allocator, digPlan.items.len);

    var vertex = Grid{ .x = 0, .y = 0 };

    for (digPlan.items) |plan| {
        switch (plan.dir) {
            'R' => vertex.x += plan.dis,
            'L' => vertex.x -= plan.dis,
            'D' => vertex.y += plan.dis,
            'U' => vertex.y -= plan.dis,
            else => unreachable,
        }
        try vertices.append(vertex);
    }

    var area: isize = 0;
    for (0..vertices.items.len - 1) |j| {
        const c = vertices.items[j];
        const n = vertices.items[j + 1];
        area += (c.y + n.y) * (c.x - n.x);
    } else {
        const c = vertices.items[vertices.items.len - 1];
        const n = vertices.items[0];
        area += (c.y + n.y) * (c.x - n.x);
        area = try std.math.absInt(@divExact(area, 2));
    }

    var edges: isize = 0;
    for (digPlan.items) |plan| {
        edges += plan.dis;
    }

    return @intCast(area + 1 - @divExact(edges, 2) + edges);
}
