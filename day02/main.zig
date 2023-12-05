const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"));
    std.debug.print("Day 02|1: {d}\n", .{part1});
    // const part2 = solvePart2(@embedFile("input.txt"));
    // std.debug.print("Day 01|2: {d}\n", .{part2});
}

const CubeSet = struct { red: usize = 0, blue: usize = 0, green: usize = 0 };

const Game = std.ArrayList(std.ArrayList(CubeSet));

fn solve(input: []const u8) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var lines = std.mem.tokenizeScalar(u8, input, '\n');

    var games = std.ArrayList(std.ArrayList(CubeSet)).init(allocator);
    while (lines.next()) |line| {
        var start: usize = 0;
        for (0..line.len) |i| {
            if (line[i] == ':') {
                start = i + 1;
                break;
            }
        }

        try games.append(std.ArrayList(CubeSet).init(allocator));
        var gamePtr = &games.items[games.items.len - 1];

        var hands = std.mem.tokenizeScalar(u8, line[start..], ';');

        while (hands.next()) |hand| {
            var str = std.mem.tokenize(u8, hand, " ,");

            try gamePtr.append(CubeSet{});
            var cubePtr = &gamePtr.items[gamePtr.items.len - 1];

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
        }
    }

    // std.debug.print("{d}\n", .{games.items.len});

    // var total: usize = 0;
    // for (games.items, 1..) |game, i| {
    //     for (game.items) |cubes| {
    //         if (cubes.red > 12 or cubes.green > 13 or cubes.blue > 14) {
    //             break;
    //         }
    //     } else {
    //         total += i;
    //     }
    // }

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
