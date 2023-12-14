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
    var nodes = std.StringHashMap(Node).init(allocator);

    while (lines.next()) |line| {
        var tmp = std.mem.tokenize(u8, line, " =(,)");
        try nodes.put(tmp.next().?, .{ .left = tmp.next().?, .right = tmp.next().? });
    }

    // var keyIter = nodes.keyIterator();
    // while (keyIter.next()) |key| {
    //     std.debug.print("{s}\n", .{key.*});
    // }

    var curr: []const u8 = "AAA";
    const end: []const u8 = "ZZZ";

    var i: usize = 0;
    var steps: usize = 0;
    while (!std.mem.eql(u8, curr, end)) : ({
        i = (i + 1) % instructions.len;
        steps += 1;
    }) {
        if (nodes.get(curr)) |node| {
            curr = if (instructions[i] == 'R') node.right else node.left;
        }
    }

    std.debug.print("{d}\n", .{steps});

    return steps;
}
