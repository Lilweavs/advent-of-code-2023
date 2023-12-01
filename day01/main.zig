const std = @import("std");

pub fn main() !void {
    std.debug.print("\n", .{});
    const part1 = try solve(@embedFile("input.txt"));
    std.debug.print("Day 01|1: {d}\n", .{part1});
    // const part2 = try solve(@embedFile("input.txt"));
    // std.debug.print("Day 01|2: {d}\n", .{part2});
}

const numbers = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

fn checkIfNumber(str: []const u8) usize {
    for (str, 0..) |c, i| {
        if (c > 48 and c < 58) {
            return (c - '0') * 10;
        }

        for (numbers, 0..) |numStr, num| {
            for (0..numStr.len) |j| {
                if (str[i + j] != numStr[j]) {
                    break;
                }
                if (j == numStr.len - 1) {
                    return (num + 1) * 10;
                }
            }
        }
    }
    return 0;
}

fn rcheckIfNumber(str: []const u8) usize {
    for (0..str.len) |i| {
        const c = str[str.len - 1 - i];
        if (c > 48 and c < 58) {
            return (c - '0');
        }

        for (numbers, 0..) |numStr, num| {
            if (i < numStr.len - 1) {
                continue;
            }
            for (0..numStr.len) |j| {
                if (str[str.len - 1 - i + j] != numStr[j]) {
                    break;
                }
                if (j == numStr.len - 1) {
                    return (num + 1);
                }
            }
        }
    }
    return 0;
}

fn solve(input: []const u8) !usize {
    var lines = std.mem.tokenize(u8, input, "\r\n");

    // var total: usize = 0;
    // while (lines.next()) |line| {
    //     for (line) |c| {
    //         if (c > 48 and c < 58) {
    //             total += (c - '0') * 10;
    //             break;
    //         }
    //     }

    //     for (line, 0..) |_, i| {
    //         const c = line[line.len - 1 - i];
    //         if (c > 48 and c < 58) {
    //             total += (c - '0');
    //             break;
    //         }
    //     }
    // }

    var total: usize = 0;
    while (lines.next()) |line| {
        total += checkIfNumber(line);
        total += rcheckIfNumber(line);
    }

    return total;
}

test "test-part1" {
    const result = try solve(@embedFile("test1.txt"));
    try std.testing.expectEqual(result, 77);
}

test "test-part2" {
    const result = try solve(@embedFile("test1.txt"));
    try std.testing.expectEqual(result, 281);
}
