const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("test.txt"), 1);
    std.debug.print("Day 19|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("input.txt"), 2);
    // std.debug.print("Day 19|2: {d}\n", .{part2});
}

// const ModuleType = enum {
//     FlipFlop,
//     Conjunction,
//     Broadcaster,
//     Button,
// };

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
// const Module = struct {
//     type: ModuleType = undefined,
//     state: bool = undefined,
//     inputs: = undefined,
// };

fn solve(input: []const u8, comptime part: usize) !usize {
    _ = part;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.splitSequence(u8, input, "\r\n");
    // var lines = std.mem.splitScalar(u8, input, '\n');
    // var lines = std.mem.tokenizeSequence(u8, input, "\r\n");
    // var modules = std.StringHashMap(std.ArrayList([]const u8)).init(allocator);

    // var states = std.StringArrayHashMap(Module).init(allocator);

    var flipFlopModules = std.StringArrayHashMap(FlipFlop).init(allocator);
    var conjunctionModules = std.StringArrayHashMap(Conjunction).init(allocator);
    var untypedModule = std.StringHashMap(u8).init(allocator);

    var broadcaster: std.ArrayList([]const u8) = undefined;

    // parse workflows
    while (lines.next()) |line| {
        // std.debug.print("{s}\n", .{line});
        if (line.len == 0) break;

        var iter = std.mem.tokenize(u8, line, " ->,");

        var str = iter.next().?;

        // const module = switch (str[0]) {

        //     '%' => Module{ .type = ModuleType.FlipFlop, .state = false },
        //     '&' => Module{ .type = ModuleType.Conjunction, .state = false },
        //     'b' => Module{ .type = ModuleType.Broadcaster, .state = true },
        //     else => unreachable,
        // };

        var outputs = blk: {
            if (str[0] == '%') {
                try flipFlopModules.put(str[1..str.len], FlipFlop{});
                var tmpModule = flipFlopModules.getPtr(str[1..str.len]).?;
                // tmpModule.outputs = std.ArrayList([]const u8).init(allocator);
                break :blk &tmpModule.outputs;
            } else if (str[0] == '&') {
                try conjunctionModules.put(str[1..str.len], Conjunction{});
                var tmpModule = conjunctionModules.getPtr(str[1..str.len]).?;
                // tmpModule.inputs = std.ArrayList(*bool).init(allocator);
                tmpModule.inputs = std.StringArrayHashMap(bool).init(allocator);
                break :blk &tmpModule.outputs;
            } else break :blk &broadcaster;
        };

        outputs.* = std.ArrayList([]const u8).init(allocator);

        // try states.put(str[1..str.len], module);

        // try modules.put(str[1..str.len], std.ArrayList([]const u8).init(allocator));
        // var destinations = modules.getPtr(str[1..str.len]).?;

        while (iter.next()) |dest| {
            // std.debug.print("{s}\n", .{dest});
            try outputs.append(dest);
        }
    } else {
        // try modules.put("button", std.ArrayList([]const u8).init(allocator));
        // var destinations = modules.getPtr("button").?;
        // try destinations.append("roadcaster");

        // try states.put("roadcaster", .{ .type = ModuleType.Broadcaster, .state = false });
        // var keyIter = conjunctionModules.keyIterator();
        // while (keyIter.next()) |key| {
        for (conjunctionModules.keys()) |key| {
            var tmp = conjunctionModules.getPtr(key).?;
            // tmp.inputs = std.ArrayList(*bool).init(allocator);
            tmp.inputs = std.StringArrayHashMap(bool).init(allocator);
        }
    }

    lines.reset();

    while (lines.next()) |line| {
        if (line.len == 0) break;

        var iter = std.mem.tokenize(u8, line, " ->,");

        const src = iter.next().?;

        while (iter.next()) |dest| {
            // std.debug.print("src: {s}, {s}\n", .{ src, dest });
            if (conjunctionModules.getPtr(dest)) |module| {
                // var srcModule = flipFlopModules.getPtr(src[1..src.len]).?;

                if (flipFlopModules.getPtr(src[1..src.len])) |srcModule| {
                    _ = srcModule;
                    // try module.inputs.append(&srcModule.state);
                    try module.inputs.put(src[1..src.len], false);
                } else {
                    // var srcModule = conjunctionModules.get(src[1..src.len]).?;
                    // _ = srcModule;
                    // try module.inputs.append(&srcModule.state);
                    try module.inputs.put(src[1..src.len], false);
                }
            } else if (flipFlopModules.contains(dest)) {} else {
                // must be an untyped
                try untypedModule.put(dest, 0);
            }
        }
    }

    // std.debug.print("Size: {d}", .{untypedModule.count()});

    var lPulses: usize = 0;
    var hPulses: usize = 0;

    var queue = std.ArrayList(Step).init(allocator);
    // var sizeq = std.ArrayList(usize).init(allocator);
    // _ = sizeq;
    // var i: usize = 0;
    // while (i < 1 or !CycleComplete(flipFlopModules.values(), conjunctionModules.values())) : (i += 1) {
    for (0..1000) |i| {
        _ = i;

        // for (broadcaster.items) |dest| {
        //     try queue.append(.{ .src = "roadcaster", .dest = dest, .pulse = false });
        // }
        // try sizeq.append(1);
        try queue.append(.{ .src = "button", .dest = "roadcaster", .pulse = false });
        // lPulses += broadcaster.items.len;

        // var size: usize = 0;
        while (queue.items.len != 0) {
            // for (0..10) |_| {
            // std.debug.print("Q: [ ", .{});
            // for (queue.items) |s| {
            //     std.debug.print("{s}, ", .{s.src});
            // } else std.debug.print("]\n", .{});

            const step = queue.orderedRemove(0);

            if (step.pulse) hPulses += 1 else lPulses += 1;

            // std.debug.print("{s} {} -> {s}\n", .{ step.src, step.pulse, step.dest });

            if (flipFlopModules.getPtr(step.src)) |src| {
                _ = src;
                // src.state = !src.state;
                if (flipFlopModules.getPtr(step.dest)) |ffm| {
                    if (step.pulse == true) continue;
                    // src.state = step.pulse;

                    ffm.state = !ffm.state;
                    for (ffm.outputs.items) |dest| {
                        try queue.append(.{ .src = step.dest, .dest = dest, .pulse = ffm.state });
                    }
                } else if (conjunctionModules.getPtr(step.dest)) |cjm| {
                    try cjm.inputs.put(step.src, step.pulse);

                    const pulse = for (cjm.inputs.values(), cjm.inputs.keys()) |state, key| {
                        _ = key;
                        // std.debug.print("{s}={} ", .{ key, state });
                        if (state == false) {
                            break true;
                        }
                    } else false;
                    // std.debug.print(" to_send={}\n", .{cjm.state});

                    for (cjm.outputs.items) |dest| {
                        try queue.append(.{ .src = step.dest, .dest = dest, .pulse = pulse });
                    }
                } else {
                    // should be rx
                }
            } else if (conjunctionModules.getPtr(step.src)) |src| {
                _ = src;
                // _ = src;
                // src.state = step.pulse;
                if (flipFlopModules.getPtr(step.dest)) |ffm| {
                    if (step.pulse == true) continue;
                    ffm.state = !ffm.state;
                    for (ffm.outputs.items) |dest| {
                        try queue.append(.{ .src = step.dest, .dest = dest, .pulse = ffm.state });
                    }
                } else if (conjunctionModules.getPtr(step.dest)) |cjm| {
                    try cjm.inputs.put(step.src, step.pulse);

                    const pulse = for (cjm.inputs.values(), cjm.inputs.keys()) |state, key| {
                        _ = key;
                        // std.debug.print("{s}={} ", .{ key, state });
                        if (state == false) {
                            break true;
                        }
                    } else false;
                    // std.debug.print(" to_send={}\n", .{cjm.state});

                    for (cjm.outputs.items) |dest| {
                        try queue.append(.{ .src = step.dest, .dest = dest, .pulse = pulse });
                    }
                } else {
                    // rx
                }
            } else if (std.mem.eql(u8, "roadcaster", step.src)) {
                if (flipFlopModules.getPtr(step.dest)) |ffm| {
                    if (step.pulse == true) continue;
                    ffm.state = !ffm.state;
                    for (ffm.outputs.items) |dest| {
                        try queue.append(.{ .src = step.dest, .dest = dest, .pulse = ffm.state });
                    }
                } else if (conjunctionModules.getPtr(step.dest)) |cjm| {
                    try cjm.inputs.put(step.src, step.pulse);

                    const pulse = for (cjm.inputs.values(), cjm.inputs.keys()) |state, key| {
                        std.debug.print("{s}={} ", .{ key, state });
                        if (state == false) {
                            break true;
                        }
                    } else false;
                    _ = pulse;
                    // std.debug.print(" to_send={}\n", .{cjm.state});

                    for (cjm.outputs.items) |dest| {
                        try queue.append(.{ .src = step.dest, .dest = dest, .pulse = false });
                    }
                } else {
                    // rx
                }
            } else {
                for (broadcaster.items) |dest| {
                    // if (flipFlopModules.getPtr())
                    try queue.append(.{ .src = step.dest, .dest = dest, .pulse = false });
                }
                // rx
                // continue;
            }

            // std.debug.print("Cycle {d}: {}\n\n", .{ i, CycleComplete(flipFlopModules.values(), conjunctionModules.values()) });
            // try sizeq.append(output.len);
        }

        // for (output) |dest| {
        //     try queue.append(.{ .src = step.dest, .dest = dest, .pulse = pulse });
        // }
    }
    // }

    std.debug.print("{d},{d}\n", .{ lPulses, hPulses });

    // return lPulses * hPulses * (1000 / i) * (1000 / i);

    return lPulses * hPulses;
}

fn CycleComplete(ff: []FlipFlop, cj: []Conjunction) bool {
    _ = cj;
    // _ = cj;
    for (ff) |state| {
        // std.debug.print("FF: {}\n", .{state.state});
        if (state.state == true) return false;
    }
    // for (cj) |state| {
    //     // std.debug.print("CJ: {}\n", .{state.state});
    //     if (state.state == true) return false;
    // }
    return true;
}
