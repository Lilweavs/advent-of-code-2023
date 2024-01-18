const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 19|1: {d}\n", .{part1});
    const part2 = try solve(@embedFile("input.txt"), 2);
    std.debug.print("Day 19|2: {d}\n", .{part2});
}

const FlipFlop = struct {
    state: bool = false,
    outputs: std.ArrayList([]const u8) = undefined,
};

const Conjunction = struct {
    state: bool = false,
    outputs: std.ArrayList([]const u8) = undefined,
    inputs: std.StringArrayHashMap(bool) = undefined,
};

const Step = struct { src: []const u8, dest: []const u8, pulse: bool };

fn solve(input: []const u8, comptime part: usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.splitSequence(u8, input, "\r\n");

    var flipFlopModules = std.StringArrayHashMap(FlipFlop).init(allocator);
    var conjunctionModules = std.StringArrayHashMap(Conjunction).init(allocator);

    var broadcaster: std.ArrayList([]const u8) = undefined;

    while (lines.next()) |line| {
        if (line.len == 0) break;

        var iter = std.mem.tokenize(u8, line, " ->,");

        var str = iter.next().?;

        const outputs = blk: {
            if (str[0] == '%') {
                try flipFlopModules.put(str[1..str.len], FlipFlop{});
                var tmpModule = flipFlopModules.getPtr(str[1..str.len]).?;
                break :blk &tmpModule.outputs;
            } else if (str[0] == '&') {
                try conjunctionModules.put(str[1..str.len], Conjunction{});
                var tmpModule = conjunctionModules.getPtr(str[1..str.len]).?;
                tmpModule.inputs = std.StringArrayHashMap(bool).init(allocator);
                break :blk &tmpModule.outputs;
            } else break :blk &broadcaster;
        };

        outputs.* = std.ArrayList([]const u8).init(allocator);

        while (iter.next()) |dest| {
            try outputs.append(dest);
        }
    } else {
        for (conjunctionModules.values()) |*cjm| {
            cjm.inputs = std.StringArrayHashMap(bool).init(allocator);
        }
    }

    lines.reset();

    while (lines.next()) |line| {
        if (line.len == 0) break;

        var iter = std.mem.tokenize(u8, line, " ->,");

        const src = iter.next().?;

        while (iter.next()) |dest| {
            if (conjunctionModules.getPtr(dest)) |module| {
                try module.inputs.put(src[1..src.len], false);
            }
        }
    }

    // &fh -> ql // &ss -> ql // &mf -> ql // &fz -> ql

    var queue = std.ArrayList(Step).init(allocator);

    var rx_feeders = std.StringArrayHashMap(usize).init(allocator);
    try rx_feeders.put("fh", 0);
    try rx_feeders.put("ss", 0);
    try rx_feeders.put("mf", 0);
    try rx_feeders.put("fz", 0);

    var lPulses: usize = 0;
    var hPulses: usize = 0;
    var i: usize = 0;
    while (true) : (i += 1) {
        try queue.append(.{ .src = "button", .dest = "roadcaster", .pulse = false });

        if (comptime part == 1) {
            if (i == 1000) break;
        }

        while (queue.items.len != 0) {
            const step = queue.orderedRemove(0);

            if (step.pulse) hPulses += 1 else lPulses += 1;

            if (comptime part == 2) {
                if (rx_feeders.getPtr(step.src)) |feeder| {
                    if (step.pulse == true) feeder.* = i + 1;

                    var sum: usize = 1;
                    for (rx_feeders.values()) |value| {
                        if (value == 0) break else sum *= value;
                    } else return sum;
                }
            }

            if (std.mem.eql(u8, "button", step.src)) {
                for (broadcaster.items) |dest| {
                    try queue.append(.{ .src = step.dest, .dest = dest, .pulse = false });
                }
            } else {
                if (flipFlopModules.getPtr(step.dest)) |ffm| {
                    if (step.pulse == true) continue;

                    ffm.state = !ffm.state;
                    for (ffm.outputs.items) |dest| {
                        try queue.append(.{ .src = step.dest, .dest = dest, .pulse = ffm.state });
                    }
                } else if (conjunctionModules.getPtr(step.dest)) |cjm| {
                    try cjm.inputs.put(step.src, step.pulse);

                    const pulse = for (cjm.inputs.values()) |state| {
                        if (state == false) break true;
                    } else false;

                    for (cjm.outputs.items) |dest| {
                        try queue.append(.{ .src = step.dest, .dest = dest, .pulse = pulse });
                    }
                } else {
                    // should be rx
                }
            }
        }
    }

    return lPulses * hPulses;
}
