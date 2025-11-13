const std = @import("std");
const arg = @import("args.zig");
const mon = @import("monster.zig");

const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    var clia = arg.CLIArgs.new();
    _ = try clia.parseArgs(args);
    // print("action: {}\npath: {s}\nname: {s}\n", .{clia.action, clia.path, clia.name});

    try mon.init(allocator);
    switch (clia.action) {
        arg.Action.HELP => { arg.printMenu(); },
        arg.Action.TEMPLATE => { try mon.from_template(allocator, clia.name); },
        arg.Action.SAVE => { try mon.save_template(allocator, clia.path, clia.name); },
        arg.Action.LIST => { try mon.list(allocator); },
        arg.Action.REMOVE => { try mon.remove(allocator, clia.name); },
        arg.Action.CLEAR => { try mon.clear(allocator); },
    }
}
