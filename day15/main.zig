const std = @import("std");

pub fn main() !void {
    const part1 = try solve(@embedFile("input.txt"), 1);
    std.debug.print("Day 15|1: {d}\n", .{part1});
    const part2 = try solve(@embedFile("input.txt"), 2);
    std.debug.print("Day 15|2: {d}\n", .{part2});
}

const Cargo = struct { label: []const u8, focalLength: usize };

fn solve(input: []const u8, comptime part: usize) !usize {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var initSequence = std.mem.tokenize(u8, input, ",\r\n");

    var sum: usize = 0;
    if (comptime part == 1) {
        while (initSequence.next()) |step| {
            sum += HashString(step);
        }
        return sum;
    }

    var boxes = try std.ArrayList(std.ArrayList(Cargo)).initCapacity(allocator, 256);

    try boxes.appendNTimes(std.ArrayList(Cargo).init(allocator), 256);

    while (initSequence.next()) |step| {
        if (step[step.len - 1] == '-') {
            var box = &boxes.items[HashString(step[0 .. step.len - 1])];

            if (BoxContains(box.items, step[0 .. step.len - 1])) |offset| {
                _ = box.orderedRemove(offset);
            }
        } else {
            const eqlIndex = std.mem.indexOfScalar(u8, step, '=').?;
            const label = step[0..eqlIndex];
            const focalLength = step[step.len - 1] - '0';

            var box = &boxes.items[HashString(step[0..eqlIndex])];

            if (BoxContains(box.items, label)) |offset| {
                box.items[offset].focalLength = focalLength;
            } else {
                try box.append(Cargo{ .label = label, .focalLength = focalLength });
            }
        }
    }

    // PrintBoxes(&boxes);

    for (boxes.items, 1..) |box, boxNum| {
        if (box.items.len == 0) continue;
        for (box.items, 1..) |cargo, slot| {
            sum += (boxNum * slot * cargo.focalLength);
        }
    }

    return sum;
}

fn BoxContains(box: []Cargo, label: []const u8) ?usize {
    for (box, 0..) |cargo, offset| {
        if (std.mem.eql(u8, cargo.label, label)) return offset;
    }
    return null;
}

fn HashString(string: []const u8) usize {
    var hash: usize = 0;
    for (string) |c| hash = ((hash + c) * 17) % 256;
    return hash;
}

fn PrintBoxes(boxes: *std.ArrayList(std.ArrayList(Cargo))) void {
    for (boxes.items, 0..) |box, idx| {
        if (box.items.len == 0) continue;

        std.debug.print("Box {d}:", .{idx});
        for (box.items) |cargo| {
            std.debug.print(" [{s} {d}]", .{ cargo.label, cargo.focalLength });
        }
        std.debug.print("\n", .{});
    }
}
