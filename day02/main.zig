const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), part1Strategy);
    std.debug.print("Day 02|1: {d}\n", .{part1});
    const part2 = try solve(@embedFile("input.txt"), part2Strategy);
    std.debug.print("Day 01|2: {d}\n", .{part2});
}

const CubeSet = struct { red: usize = 0, blue: usize = 0, green: usize = 0 };
const Games = std.ArrayList(std.ArrayList(CubeSet));

fn solve(input: []const u8, comptime strategy: fn (*std.ArrayList(std.ArrayList(CubeSet))) usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var games = Games.init(allocator);
    while (lines.next()) |line| {
        try games.append(std.ArrayList(CubeSet).init(allocator));
        var gamePtr = &games.items[games.items.len - 1];

        var hands = std.mem.tokenize(u8, line, ":;");
        _ = hands.next(); // Trim Game XX:

        while (hands.next()) |hand| {
            var str = std.mem.tokenize(u8, hand, " ,");

            try gamePtr.append(CubeSet{});
            var cubePtr = &gamePtr.items[gamePtr.items.len - 1];

            while (str.next()) |tmp| {
                const num = try std.fmt.parseInt(usize, tmp, 10);
                const tmp2 = str.next().?;
                switch (tmp2[0]) {
                    'r' => cubePtr.red = num,
                    'b' => cubePtr.blue = num,
                    'g' => cubePtr.green = num,
                    else => unreachable,
                }
            }
        }
    }

    return strategy(&games);
}

fn part1Strategy(games: *std.ArrayList(std.ArrayList(CubeSet))) usize {
    var total: usize = 0;
    for (games.items, 1..) |game, i| {
        for (game.items) |cubes| {
            if (cubes.red > 12 or cubes.green > 13 or cubes.blue > 14) {
                break;
            }
        } else {
            total += i;
        }
    }
    return total;
}

fn part2Strategy(games: *std.ArrayList(std.ArrayList(CubeSet))) usize {
    var total: usize = 0;
    for (games.items) |game| {
        var max = CubeSet{};
        for (game.items) |cubes| {
            max.red = @max(max.red, cubes.red);
            max.green = @max(max.green, cubes.green);
            max.blue = @max(max.blue, cubes.blue);
        } else {
            total += (max.red * max.green * max.blue);
        }
    }
    return total;
}

test "test-part1" {
    const result = try solve(@embedFile("test.txt"), part1Strategy);
    try std.testing.expectEqual(result, 8);
}

test "test-part2" {
    const result = try solve(@embedFile("test.txt"), part2Strategy);
    try std.testing.expectEqual(result, 2286);
}
