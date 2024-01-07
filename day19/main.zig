const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 19|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("test.txt"), 2);
    // std.debug.print("Day 19|2: {d}\n", .{part2});
}

const Part = struct { x: usize, m: usize, a: usize, s: usize };

const Instruction = struct { category: u8, cmp: u8, val: usize, rule: []const u8 };

fn solve(input: []const u8, comptime part: usize) !usize {
    _ = part;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.splitSequence(u8, input, "\r\n");

    var workflows = std.StringHashMap(std.ArrayList(Instruction)).init(allocator);

    var parts = std.ArrayList(Part).init(allocator);

    // parse workflows
    while (lines.next()) |line| {
        // std.debug.print("{s}\n", .{line});
        if (line.len == 0) break;
        // Create Has entry
        var sIter = std.mem.tokenize(u8, line, "{}");
        const key = sIter.next().?;
        try workflows.put(key, std.ArrayList(Instruction).init(allocator));

        var workflow = workflows.getPtr(key).?;

        // create new has entry
        var wfIter = std.mem.tokenizeScalar(u8, sIter.next().?, ',');
        while (wfIter.next()) |str| {
            if (std.mem.indexOfScalar(u8, str, ':')) |i| {
                try workflow.append(Instruction{ .category = str[0], .cmp = str[1], .val = try std.fmt.parseInt(usize, str[2..i], 10), .rule = str[i + 1 ..] });
            } else {
                try workflow.append(Instruction{ .category = '0', .cmp = '0', .val = 0, .rule = str });
            }
        }
    }

    while (lines.next()) |line| {
        // std.debug.print("{s}\n", .{line});
        if (line.len == 0) break;
        var sItr = std.mem.tokenize(u8, line, "{}=xmas,");

        try parts.append(Part{
            .x = try std.fmt.parseInt(usize, sItr.next().?, 10),
            .m = try std.fmt.parseInt(usize, sItr.next().?, 10),
            .a = try std.fmt.parseInt(usize, sItr.next().?, 10),
            .s = try std.fmt.parseInt(usize, sItr.next().?, 10),
        });
    }

    // std.debug.print("plans: {d}\n", .{workflows.capacity()});
    // std.debug.print("parts: {d}\n", .{parts.items.len});

    var sum: usize = 0;
    for (parts.items) |prt| {
        var workflow = workflows.get("in").?;

        // std.debug.print("Part: {{x={d},m={d},a={d},s={d}}}\n", .{ prt.x, prt.m, prt.a, prt.s });
        var i: usize = 0;
        const ack = while (true) {
            const plan = workflow.items[i];
            // std.debug.print("Plan: {c}{c}{d}:{s}\n", .{ plan.category, plan.cmp, plan.val, plan.rule });
            var tmp: bool = false;
            if (plan.cmp == '<') {
                tmp = switch (plan.category) {
                    'x' => prt.x < plan.val,
                    'm' => prt.m < plan.val,
                    'a' => prt.a < plan.val,
                    's' => prt.s < plan.val,
                    else => unreachable,
                };
            } else if (plan.cmp == '>') {
                tmp = switch (plan.category) {
                    'x' => prt.x > plan.val,
                    'm' => prt.m > plan.val,
                    'a' => prt.a > plan.val,
                    's' => prt.s > plan.val,
                    else => unreachable,
                };
            } else tmp = true;

            if (tmp) {
                if (plan.rule.len == 1 and plan.rule[0] == 'A') {
                    break true;
                } else if (plan.rule.len == 1 and plan.rule[0] == 'R') {
                    break false;
                } else {
                    workflow = workflows.get(plan.rule).?;
                    i = 0;
                }
            } else i += 1;
        } else unreachable;

        if (ack) {
            sum += (prt.x + prt.m + prt.a + prt.s);
        }
    }

    return sum;
}
