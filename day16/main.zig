const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 16|1: {d}\n", .{part1});
    const part2 = try solve(@embedFile("input.txt"), 2);
    std.debug.print("Day 16|2: {d}\n", .{part2});
}

const Direction = enum { Up, Down, Left, Right };

const Node = struct { x: isize, y: isize, d: Direction };

fn solve(input: []const u8, comptime part: usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenizeSequence(u8, input, "\r\n");

    var grid = std.ArrayList([]const u8).init(allocator);

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        try grid.append(line);
    }

    if (comptime part == 1) {
        return GetNumberIlluminatedTiles(allocator, grid.items, Node{ .x = -1, .y = 0, .d = Direction.Right });
    }

    var numIlluminated: usize = 0;

    for (0..grid.items.len) |j| {
        var tmp = try GetNumberIlluminatedTiles(allocator, grid.items, Node{ .x = -1, .y = @intCast(j), .d = Direction.Right });
        numIlluminated = @max(numIlluminated, tmp);
        tmp = try GetNumberIlluminatedTiles(allocator, grid.items, Node{ .x = @intCast(grid.items[0].len), .y = @intCast(j), .d = Direction.Left });
        numIlluminated = @max(numIlluminated, tmp);
    }
    for (0..grid.items[0].len) |i| {
        var tmp = try GetNumberIlluminatedTiles(allocator, grid.items, Node{ .x = @intCast(i), .y = -1, .d = Direction.Down });
        numIlluminated = @max(numIlluminated, tmp);
        tmp = try GetNumberIlluminatedTiles(allocator, grid.items, Node{ .x = @intCast(i), .y = @intCast(grid.items.len), .d = Direction.Up });
        numIlluminated = @max(numIlluminated, tmp);
    }

    return numIlluminated;
}

fn GetNumberIlluminatedTiles(allocator: std.mem.Allocator, grid: [][]const u8, start: Node) !usize {
    var numIlluminated: usize = 0;

    var visited = std.ArrayList(Node).init(allocator);
    var unvisited = std.ArrayList(Node).init(allocator);

    try unvisited.append(start);

    while (unvisited.items.len != 0) {
        var curr = unvisited.pop();

        if (ContainsNode(visited.items, curr)) {
            continue;
        }

        try visited.append(curr);

        // get next direction
        switch (curr.d) {
            Direction.Up => {
                if (curr.y != 0) curr.y -= 1 else continue;
            },
            Direction.Down => {
                if (curr.y != grid.len - 1) curr.y += 1 else continue;
            },
            Direction.Right => {
                if (curr.x != grid[0].len - 1) curr.x += 1 else continue;
            },
            Direction.Left => {
                if (curr.x != 0) curr.x -= 1 else continue;
            },
        }

        // Move and add new directions
        switch (grid[@intCast(curr.y)][@intCast(curr.x)]) {
            '|' => {
                if (curr.d == Direction.Left or curr.d == Direction.Right) {
                    try unvisited.append(Node{ .x = curr.x, .y = curr.y, .d = Direction.Up });
                    try unvisited.append(Node{ .x = curr.x, .y = curr.y, .d = Direction.Down });
                } else try unvisited.append(curr);
            },
            '-' => {
                if (curr.d == Direction.Up or curr.d == Direction.Down) {
                    try unvisited.append(Node{ .x = curr.x, .y = curr.y, .d = Direction.Left });
                    try unvisited.append(Node{ .x = curr.x, .y = curr.y, .d = Direction.Right });
                } else try unvisited.append(curr);
            },
            '\\' => {
                if (curr.d == Direction.Up) {
                    try unvisited.append(Node{ .x = curr.x, .y = curr.y, .d = Direction.Left });
                } else if (curr.d == Direction.Down) {
                    try unvisited.append(Node{ .x = curr.x, .y = curr.y, .d = Direction.Right });
                } else if (curr.d == Direction.Left) {
                    try unvisited.append(Node{ .x = curr.x, .y = curr.y, .d = Direction.Up });
                } else if (curr.d == Direction.Right) {
                    try unvisited.append(Node{ .x = curr.x, .y = curr.y, .d = Direction.Down });
                }
            },
            '/' => {
                if (curr.d == Direction.Up) {
                    try unvisited.append(Node{ .x = curr.x, .y = curr.y, .d = Direction.Right });
                } else if (curr.d == Direction.Down) {
                    try unvisited.append(Node{ .x = curr.x, .y = curr.y, .d = Direction.Left });
                } else if (curr.d == Direction.Left) {
                    try unvisited.append(Node{ .x = curr.x, .y = curr.y, .d = Direction.Down });
                } else if (curr.d == Direction.Right) {
                    try unvisited.append(Node{ .x = curr.x, .y = curr.y, .d = Direction.Up });
                }
            },
            '.' => try unvisited.append(curr),
            else => unreachable,
        }
    }

    for (0..grid.len) |j| {
        for (0..grid[0].len) |i| {
            if (ContainsLocation(visited.items, i, j)) numIlluminated += 1;
        }
    }
    return numIlluminated;
}

fn ContainsNode(haystack: []Node, needle: Node) bool {
    for (haystack) |node| {
        if (needle.x == node.x and needle.y == node.y and needle.d == node.d) return true;
    }
    return false;
}

fn ContainsLocation(haystack: []Node, x: usize, y: usize) bool {
    for (haystack) |node| {
        if (x == node.x and y == node.y) return true;
    }
    return false;
}
