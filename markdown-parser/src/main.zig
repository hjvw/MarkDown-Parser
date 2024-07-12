const std = @import("std");
const clap = @import("clap");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const params = comptime clap.parseParamsComptime(
        \\-p,--filepath <str>  File path.
        \\
    );

    var diag = clap.Diagnostic{};
    var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
        .diagnostic = &diag,
        .allocator = gpa.allocator(),
    }) catch |err| {
        // Report useful error and exit
        diag.report(std.io.getStdErr().writer(), err) catch {};
        return err;
    };
    defer res.deinit();
    var path: []const u8 = undefined;
    if (res.args.filepath) |p| {
        path = p;
    }

    var gp = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gp.deinit();
    const allocator = gp.allocator();

    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    var line = std.ArrayList(u8).init(allocator);
    defer line.deinit();
    const writer = line.writer();
    var line_no: usize = 0;

    var g = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = g.deinit();
    const alloc = g.allocator();

    var new_lines = std.ArrayList([]u8).init(alloc);
    defer new_lines.deinit();

    // var oListCount: u8 = 0;
    var oListOn: bool = false;
    var liOn: bool = false;
    var endoList: bool = false;
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const a = arena.allocator();
    var innerLiOn: bool = false;
    var innerOlOn: bool = false;
    var innerEndOList: bool = false;
    while (reader.streamUntilDelimiter(writer, '\n', null)) {
        defer line.clearRetainingCapacity();
        var bu: [256]u8 = undefined;
        var fba = std.heap.FixedBufferAllocator.init(&bu);
        const al = fba.allocator();

        var count: u8 = 0;
        var block: bool = undefined;
        line_no += 1;
        if (oListOn and line.items[0] == 32 and line.items[1] == 32 and line.items[2] == 32 and line.items[3] == 32) {
            for (4..line.items.len) |index| {
                if (line.items[index] == 49 and line.items[index + 1] == 46 and line.items[index + 2] == 32) {
                    var string = "<ol>";
                    var x = [_]u8{ ' ', ' ', ' ', ' ' };
                    var i: usize = 0;
                    for (string) |v| {
                        x[i] = v;
                        i += 1;
                    }

                    std.debug.print("dasdaddadsad", .{});
                    std.debug.print("{s}", .{x});
                    try new_lines.append(&x);
                    string = "<li>";
                    var z = [_]u8{ ' ', ' ', ' ', ' ' };
                    i = 0;
                    for (string) |v| {
                        z[i] = v;
                        i += 1;
                    }
                    innerOlOn = true;
                    std.debug.print("{s}", .{z});

                    try new_lines.append(&z);
                    innerLiOn = true;
                }
                if (line.items[index] >= 49 and line.items[index + 1] == 46 and line.items[index + 2] == 32 and innerOlOn and !innerLiOn) {
                    const string = "<li>";
                    var x = [_]u8{ ' ', ' ', ' ', ' ' };
                    var i: usize = 0;
                    for (string) |v| {
                        x[i] = v;
                        i += 1;
                    }
                    innerLiOn = true;
                    std.debug.print("{s}", .{x});

                    try new_lines.append(&x);
                }
            }
        } else {
            innerEndOList = true;
        }
        if (innerEndOList and innerOlOn and !innerLiOn) {
            const string = "</ol>";
            var x = [_]u8{ ' ', ' ', ' ', ' ', ' ' };
            var i: usize = 0;
            for (string) |v| {
                x[i] = v;
                i += 1;
            }
            innerOlOn = false;
            innerLiOn = false;
            std.debug.print("{s}", .{x});
            try new_lines.append(&x);
        }

        std.debug.print("{}", .{line.items[0]});
        for (0..3) |value| {
            // std.debug.print("s", .{});
            if (line.items[value] == 49 and line.items[value + 1] == 46 and line.items[value + 2] == 32 and oListOn == false) {
                var string = "<ol>";
                var x = [_]u8{ ' ', ' ', ' ', ' ' };
                var i: usize = 0;
                for (string) |v| {
                    x[i] = v;
                    i += 1;
                }
                oListOn = true;
                std.debug.print("dasdaddadsad", .{});
                std.debug.print("{s}", .{x});
                try new_lines.append(&x);
                string = "<li>";
                var z = [_]u8{ ' ', ' ', ' ', ' ' };
                i = 0;
                for (string) |v| {
                    z[i] = v;
                    i += 1;
                }
                std.debug.print("{s}", .{z});
                liOn = true;
                try new_lines.append(&z);
            }
            if (line.items[value] >= 49 and line.items[value + 1] == 46 and line.items[value + 2] == 32 and oListOn and !liOn) {
                const string = "<li>";
                var x = [_]u8{ ' ', ' ', ' ', ' ' };
                var i: usize = 0;
                for (string) |v| {
                    x[i] = v;
                    i += 1;
                }
                std.debug.print("{s}", .{x});
                liOn = true;
                // innerOlOn = false;
                try new_lines.append(&x);
            }
            if (line.items[value] != 49 and line.items[value + 1] != 46 and line.items[value + 2] != 32 and oListOn and !liOn) {
                endoList = true;
            }
        }

        if (endoList) {
            const string = "</ol>";
            var x = [_]u8{ ' ', ' ', ' ', ' ', ' ' };
            var i: usize = 0;
            for (string) |v| {
                x[i] = v;
                i += 1;
            }
            oListOn = false;
            std.debug.print("{s}", .{x});
            try new_lines.append(&x);
        }
        if (line.items[0] == 35) {
            block = blk: {
                count += 1;
                for (1..6) |v| {
                    if (line.items[v] == 35) {
                        count += 1;
                    }
                    if (line.items[v] == 32) {
                        try new_lines.append(try std.fmt.allocPrint(al, "<h{d}>", .{count}));

                        break :blk true;
                    }
                }

                break :blk false;
            };
        }

        var starCount: u8 = 0;
        var noStar: u8 = 0;
        var starsUsed: bool = false;
        var can: u8 = 0;
        for (0..line.items.len) |index| {
            switch (line.items[index]) {
                35 => _ = bl: {
                    if (index <= count and block == true) {
                        break :bl null;
                    } else {
                        var b2: [256]u8 = undefined;
                        var g2 = std.heap.FixedBufferAllocator.init(&b2);
                        const allll = g2.allocator();

                        try new_lines.append(try std.fmt.allocPrint(allll, "{c}", .{line.items[index]}));
                    }
                },
                42 => _ = blo: {
                    if (can != 0) {
                        can -= 1;
                    }
                    if (starsUsed == true and noStar != 0) {
                        var slice: []u8 = undefined;

                        switch (starCount) {
                            1 => slice = blk: {
                                const string = "</em>";
                                var x = [_]u8{ ' ', ' ', ' ', ' ', ' ' };
                                var i: usize = 0;
                                for (string) |v| {
                                    x[i] = v;
                                    i += 1;
                                }
                                break :blk &x;
                            },
                            2 => slice = blk: {
                                const string = "</strong>";
                                var x = [_]u8{ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' };
                                var i: usize = 0;
                                for (string) |v| {
                                    x[i] = v;
                                    i += 1;
                                }
                                break :blk &x;
                            },
                            3 => slice = blk: {
                                const string = "</em></strong>";
                                var x = [_]u8{ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' };
                                var i: usize = 0;
                                for (string) |v| {
                                    x[i] = v;
                                    i += 1;
                                }
                                break :blk &x;
                            },
                            else => _ = unreachable,
                        }
                        can = starCount;

                        starCount = 0;
                        starsUsed = false;
                        noStar = 0;
                        try new_lines.append(slice);
                        continue;
                    }

                    if (starsUsed == false and can == 0) {
                        if (line.items[index + 1] != 42) {
                            var slice: []u8 = undefined;
                            starCount += 1;
                            switch (starCount) {
                                1 => slice = blk: {
                                    const string = "<em>";
                                    var x = [_]u8{ ' ', ' ', ' ', ' ' };
                                    var i: usize = 0;
                                    for (string) |v| {
                                        x[i] = v;
                                        i += 1;
                                    }
                                    break :blk &x;
                                },
                                2 => slice = blk: {
                                    const string = "<strong>";
                                    var x = [_]u8{ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' };
                                    var i: usize = 0;
                                    for (string) |v| {
                                        x[i] = v;
                                        i += 1;
                                    }
                                    break :blk &x;
                                },
                                3 => slice = blk: {
                                    const string = "<em><strong>";
                                    var x = [_]u8{ ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ' };
                                    var i: usize = 0;
                                    for (string) |v| {
                                        x[i] = v;
                                        i += 1;
                                    }
                                    break :blk &x;
                                },
                                else => unreachable,
                            }
                            noStar += 1;
                            starsUsed = true;
                            try new_lines.append(slice);
                        } else {
                            noStar = 0;
                            starCount += 1;
                        }
                        break :blo null;
                    }
                },
                else => _ = blo: {
                    if (64 < line.items[index] and line.items[index] < 123) {
                        std.debug.print("{c}", .{line.items[index]});
                        const str = try std.fmt.allocPrint(a, "{c}", .{line.items[index]});

                        try new_lines.append(str);

                        noStar += 1;

                        break :blo null;
                    }
                },
            }
        }

        if (innerLiOn) {
            const string = "</li>";
            var x = [_]u8{ ' ', ' ', ' ', ' ', ' ' };
            var i: usize = 0;
            for (string) |v| {
                x[i] = v;
                i += 1;
            }
            innerLiOn = false;

            try new_lines.append(&x);
        }
        if (liOn) {
            const string = "</li>";
            var x = [_]u8{ ' ', ' ', ' ', ' ', ' ' };
            var i: usize = 0;
            for (string) |v| {
                x[i] = v;
                i += 1;
            }
            liOn = false;
            try new_lines.append(&x);
        }
        if (block) {
            _ = try new_lines.append(try std.fmt.allocPrint(al, "</h{d}>", .{count}));
        }
    } else |err| switch (err) {
        error.EndOfStream => if (line.items.len > 0) {
            line_no += 1;
        },
        else => return err,
    }
    std.debug.print("{s}", .{new_lines.items});
}
