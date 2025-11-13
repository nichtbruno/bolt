const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn fileExists(cwd: std.fs.Dir, file_name: []const u8) bool {
    cwd.access(file_name, .{}) catch return false;
    return true;
}

pub fn getType(dir: std.fs.Dir, file_name: []const u8) !?std.fs.File.Kind {
    const stat  = try dir.statFile(file_name);
    return switch(stat.kind) {
        .file => .file,
        .directory => .directory,
        else => null,
    };
}

pub fn templateExists(allocator: Allocator, cache_file: std.fs.File, name: []const u8) !?[]const u8 {
    try cache_file.seekTo(0);
    const max_size = 10 * 1024 * 1024;
    const content = try cache_file.readToEndAlloc(allocator, max_size);
    defer allocator.free(content);

    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    while (lines.next()) |line| {
        var items = std.mem.tokenizeScalar(u8, line, '|');
        const path = items.next();
        if (items.next()) |n_name| {
            if (std.mem.eql(u8, n_name, name)) {
                if (path) |p| {
                    return try allocator.dupe(u8, p);
                }
            }
        }
    }
    return null;
}

pub fn copyDirRecursive(allocator: Allocator, src_dir: std.fs.Dir, src_path: []const u8, dst_dir: std.fs.Dir, dst_path: []const u8) !void {
    var src = try src_dir.openDir(src_path, .{ .iterate = true });
    defer src.close();

    dst_dir.makeDir(dst_path) catch |e| switch (e) {
        error.PathAlreadyExists => {},
        else => return e,
    };

    var dest = try dst_dir.openDir(dst_path, .{});
    defer dest.close();

    var i = src.iterate();
    while (try i.next()) |e| {
        switch (e.kind) {
            .file => {
                try src.copyFile(e.name, dest, e.name, .{});
            },
            .directory => {
                const src_sub_path = try std.fs.path.join(allocator, &.{ src_path, e.name });
                defer allocator.free(src_sub_path);
                const dest_sub_path = e.name;

                try copyDirRecursive(allocator, src_dir, src_sub_path, dest, dest_sub_path);
            },
            else => {},
        }
    }
}
