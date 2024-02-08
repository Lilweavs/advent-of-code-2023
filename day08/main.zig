const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("test.txt"), 1);
    std.debug.print("Day 08|1: {d}\n", .{part1});
    const part2 = try solve(@embedFile("test.txt"), 2);
    std.debug.print("Day 08|2: {d}\n", .{part2});
}

const Node = struct { left: []const u8, right: []const u8 };

fn solve(input: []const u8, comptime part: usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenize(u8, input, "\r\n");
    const instructions = lines.next().?;
    var nodes = std.StringHashMap(Node).init(allocator);

    while (lines.next()) |line| {
        var tmp = std.mem.tokenize(u8, line, " =(,)");
        try nodes.put(tmp.next().?, .{ .left = tmp.next().?, .right = tmp.next().? });
    }

    if (comptime part == 1) {
        var curr: []const u8 = "AAA";
        const end: []const u8 = "ZZZ";

        var steps: usize = 0;
        while (!std.mem.eql(u8, curr, end)) {
            steps += 1;
            if (nodes.get(curr)) |node| {
                curr = if (instructions[(steps - 1) % instructions.len] == 'R') node.right else node.left;
            }
        }
        return steps;
    }

    var steps: usize = 1;
    var keyIter = nodes.keyIterator();
    while (keyIter.next()) |key| {
        var curr = key.*;
        if (curr[curr.len - 1] == 'A') {
            var i: usize = 0;
            while (curr[curr.len - 1] != 'Z') {
                i += 1;
                if (nodes.get(curr)) |node| {
                    curr = if (instructions[(i - 1) % instructions.len] == 'R') node.right else node.left;
                }
            } else steps = (steps * i) / std.math.gcd(steps, i);
        }
    }

    return steps;
}
