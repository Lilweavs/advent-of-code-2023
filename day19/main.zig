const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("test.txt"), 1);
    std.debug.print("Day 19|1: {d}\n", .{part1});
    const part2 = try solve(@embedFile("test.txt"), 2);
    std.debug.print("Day 19|2: {d}\n", .{part2});
}

const Part = struct { x: usize, m: usize, a: usize, s: usize };

const Instruction = struct { category: u8, cmp: u8, val: usize, rule: []const u8 };

fn solve(input: []const u8, comptime part: usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.splitSequence(u8, input, "\r\n");
    // var lines = std.mem.splitScalar(u8, input, '\n');
    // var lines = std.mem.tokenizeSequence(u8, input, "\r\n");

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

    std.debug.print("Workflows: {d}\n", .{workflows.capacity()});
    std.debug.print("Parts: {d}\n", .{parts.items.len});

    if (comptime part == 1) {
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

    // create binary tree of poosibilities
    const possibilies = TraverseTree("in", &workflows, Range{ .l = 1, .r = 4000 }, Range{ .l = 1, .r = 4000 }, Range{ .l = 1, .r = 4000 }, Range{ .l = 1, .r = 4000 });

    return possibilies;
}

const Range = struct { l: usize, r: usize };

fn GetInterval(r: Range, cmp: u8, val: usize) Range {
    var range = r;
    if (cmp == '<') {
        if (range.r > val) range.r = val - 1;
    } else {
        if (range.l < val) range.l = val + 1;
    }
    return range;
}

fn TraverseTree(
    rule: []const u8,
    workflows: *std.StringHashMap(std.ArrayList(Instruction)),
    xrange: Range,
    mrange: Range,
    arange: Range,
    srange: Range,
) usize {
    var xr = xrange;
    var mr = mrange;
    var ar = arange;
    var sr = srange;
    if (rule.len == 1 and rule[0] == 'A') {
        std.debug.print("[{},{}], [{},{}], [{},{}], [{},{}]\n", .{ xr.l, xr.r, mr.l, mr.r, ar.l, ar.r, sr.l, sr.r });
        return (xr.r - xr.l + 1) * (mr.r - mr.l + 1) * (ar.r - ar.l + 1) * (sr.r - sr.l + 1); // accepted
    } else if (rule.len == 1 and rule[0] == 'R') return 0; // rejected
    const workflow = workflows.get(rule).?;

    var possibilities: usize = 0;
    for (workflow.items) |plan| {
        if (plan.cmp != '0') {
            switch (plan.category) {
                'x' => {
                    if (plan.cmp == '<') {
                        possibilities += TraverseTree(plan.rule, workflows, Range{ .l = xr.l, .r = plan.val - 1 }, mr, ar, sr);
                        xr.l = plan.val;
                    } else {
                        possibilities += TraverseTree(plan.rule, workflows, Range{ .l = plan.val + 1, .r = mr.r }, mr, ar, sr);
                        xr.r = plan.val;
                    }
                },
                'm' => {
                    if (plan.cmp == '<') {
                        possibilities += TraverseTree(plan.rule, workflows, xr, Range{ .l = mr.l, .r = plan.val - 1 }, ar, sr);
                        mr.l = plan.val;
                    } else {
                        possibilities += TraverseTree(plan.rule, workflows, xr, Range{ .l = plan.val + 1, .r = mr.r }, ar, sr);
                        mr.r = plan.val;
                    }
                },
                'a' => {
                    if (plan.cmp == '<') {
                        possibilities += TraverseTree(plan.rule, workflows, xr, mr, Range{ .l = ar.l, .r = plan.val - 1 }, sr);
                        ar.l = plan.val;
                    } else {
                        possibilities += TraverseTree(plan.rule, workflows, xr, mr, Range{ .l = plan.val + 1, .r = ar.r }, sr);
                        ar.r = plan.val;
                    }
                },
                's' => {
                    if (plan.cmp == '<') {
                        possibilities += TraverseTree(plan.rule, workflows, xr, mr, ar, Range{ .l = sr.l, .r = plan.val - 1 });
                        sr.l = plan.val;
                    } else {
                        possibilities += TraverseTree(plan.rule, workflows, xr, mr, ar, Range{ .l = plan.val + 1, .r = sr.r });
                        sr.r = plan.val;
                    }
                },
                else => unreachable,
            }
        } else {
            possibilities += TraverseTree(plan.rule, workflows, xr, mr, ar, sr);
        }
    }
    return possibilities;
}
