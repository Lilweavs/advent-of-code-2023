const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("test.txt"));
    std.debug.print("Day 02|1: {d}\n", .{part1});
    // const part2 = solvePart2(@embedFile("input.txt"));
    // std.debug.print("Day 01|2: {d}\n", .{part2});
}

const Cubes = struct { red: usize = 0, blue: usize = 0, green: usize = 0 };

const Game = std.ArrayList(std.ArrayList(Cubes));

fn solve(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var games = std.ArrayList(std.ArrayList(Cubes)).init(allocator);
    while (lines.next()) |line| {
        var start: usize = 0;
        for (0..line.len) |i| {
            if (line[i] == ':') {
                start = i + 1;
                break;
            }
        }

        try games.append(std.ArrayList(Cubes).init(allocator));
        var gamePtr = games.getLast();

        var hands = std.mem.tokenizeScalar(u8, line[start..], ';');

        var i: usize = 0;
        while (hands.next()) |hand| : (i += 1) {
            var str = std.mem.tokenize(u8, hand, " ,");

            try gamePtr.append(Cubes{});
            var cubePtr = gamePtr.getLast();

            // std.debug.print("{d}, {d}\n", .{ gamePtr.items.len, i });

            while (str.next()) |tmp| {
                var num = try std.fmt.parseInt(usize, tmp, 10);
                var tmp2 = str.next().?;
                if (tmp2[0] == 'r') {
                    cubePtr.red = num;
                } else if (tmp2[0] == 'b') {
                    cubePtr.blue = num;
                } else {
                    cubePtr.green = num;
                }
            }
            // std.debug.print("r: {d}, g: {d}, b: {d}\n", .{ cubePtr.red, cubePtr.green, cubePtr.blue });
        }
        std.debug.print("game len: {d}\n", .{gamePtr.items.len});
    }

    std.debug.print("{d}\n", .{games.items.len});

    var total: usize = 0;
    for (games.items, 0..) |game, i| {
        for (game.items) |cubes| {
            std.debug.print("r: {d}, g: {d}, b: {d}\n", .{ cubes.red, cubes.green, cubes.blue });
            if (cubes.red > 12 or cubes.green > 13 or cubes.blue > 14) {
                break;
            }
        } else {
            std.debug.print("{d}", .{i + 1});
            total += i + 1;
        }
    }

    return total;
}
