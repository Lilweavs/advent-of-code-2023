const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 02|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("test.txt"), 2);
    // std.debug.print("Day 01|2: {d}\n", .{part2});
}

const Node = struct { left: []const u8, right: []const u8 };

fn solve(input: []const u8, comptime part: usize) !usize {
    _ = part;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenize(u8, input, "\r\n");
    const instructions = lines.next().?;
    var nodeMap = std.StringHashMap(Node).init(allocator);
    var nodes = std.ArrayList([]const u8).init(allocator);
    while (lines.next()) |line| {
        var tmp = std.mem.tokenize(u8, line, " =(,)");
        const key: []const u8 = tmp.next().?;
        try nodeMap.put(key, .{ .left = tmp.next().?, .right = tmp.next().? });
        if (key[2] == 'A') try nodes.append(key);
    }

    // for (startNodes.items) |item| {
    //     std.debug.print("{s}\n", .{item});
    // }
    // var keyIter = nodes.keyIterator();
    // while (keyIter.next()) |key| {
    //     std.debug.print("{s}\n", .{key.*});
    // }

    // var curr: []const u8 = "AAA";
    // _ = curr;
    // const end: []const u8 = "ZZZ";
    // _ = end;

    // var i: usize = 0;
    // _ = i;
    // var steps: usize = 0;
    // _ = steps;
    // while (!std.mem.eql(u8, curr, end)) : ({
    //     i = (i + 1) % instructions.len;
    //     steps += 1;
    // }) {
    //     if (nodeMap.get(curr)) |node| {
    //         curr = if (instructions[i] == 'R') node.right else node.left;
    //     }
    // }

    // std.debug.print("{d}\n", .{steps});

    // var curr: []const u8 = nodes.items[0];
    // const end = curr;
    // if (nodeMap.get(curr)) |node| {
    //     curr = if (instructions[i] == 'R') node.right else node.left;
    // }
    // i = 0;
    // steps = 0;
    // while (!std.mem.eql(u8, curr, end)) : ({
    //     i = (i + 1) % instructions.len;
    //     steps += 1;
    // }) {
    //     if (nodeMap.get(curr)) |node| {
    //         curr = if (instructions[i] == 'R') node.right else node.left;
    //     }
    //     if (steps % 1000 == 0) {
    //         std.debug.print("{d}\n", .{steps});
    //     }
    // }
    // return steps;
    // First attempt
    // i = 0;
    // steps = 0;
    // while (!AllValuesEndWithZ(&nodes)) : ({
    //     i = (i + 1) % instructions.len;
    //     steps += 1;
    // }) {
    //     for (nodes.items) |*ptr| {
    //         const node = nodeMap.get(ptr.*).?;
    //         ptr.* = if (instructions[i] == 'R') node.right else node.left;
    //     }
    //     if (steps % 1000000 == 0) {
    //         std.debug.print("{d}\n", .{steps});
    //     }
    // }

    // return steps;

    // var visited = std.StringHashMap(void).init(allocator);
    // _ = visited;

    // var curr: []const u8 = nodes.items[0];

    var total: usize = 1;
    var offset: usize = 0;
    for (nodes.items) |start| {
        const ghost = try FindGhostPattern(start, &nodeMap, instructions, allocator);
        std.debug.print("{d}, {d}\n", .{ ghost[0], ghost[1] - 1 });

        total *= ghost[0];
        offset += (ghost[1] - 1);
    }

    std.debug.print("{d}, {d}\n", .{ total, instructions.len });
    // while (!visited.contains(curr)) : ({
    //     i = (i + 1) % instructions.len;
    //     steps += 1;
    // }) {
    //     try visited.put(curr, {});
    //     if (nodeMap.get(curr)) |node| {
    //         curr = if (instructions[i] == 'R') node.right else node.left;
    //     }
    //     if (steps % 100 == 0) {
    //         std.debug.print("{d}\n", .{steps});
    //     }
    // }

    return total / instructions.len;
}

fn FindGhostPattern(start: []const u8, map: *std.StringHashMap(Node), instructions: []const u8, allocator: std.mem.Allocator) ![2]usize {
    var visited = std.StringArrayHashMap(void).init(allocator);
    // defer {
    //     var keyIter = visited.keyIterator();
    //     while (keyIter.next()) |key| {
    //         allocator.free(key);
    //     }
    //     visited.deinit();
    // }

    var curr: []const u8 = start;
    var i: usize = 0;
    var steps: usize = 0;
    while (!visited.contains(curr)) : ({
        i = (i + 1) % instructions.len;
        steps += 1;
    }) {
        try visited.put(curr, {});
        if (map.get(curr)) |node| {
            curr = if (instructions[i] == 'R') node.right else node.left;
        }
    }

    // var keyIter = visited.keyIterator();

    for (visited.keys()) |key| {
        // const tmp = visited.get(key).?;
        if (key[2] == 'Z') {
            std.debug.print("lmao\n", .{});
        }
    }
    // std.debug.print("idx: {d}\n", .{visited.getIndex(curr).?});
    // std.debug.print("idx: {d}\n", .{steps});

    // return steps;
    return .{ steps, visited.getIndex(curr).? };
}

fn AllValuesEndWithZ(array: *std.ArrayList([]const u8)) bool {
    for (array.items) |item| {
        if (item[2] != 'Z') return false;
    }
    return true;
}
