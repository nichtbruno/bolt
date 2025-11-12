const std = @import("std");
const utl = @import("util.zig");
const Allocator = std.mem.Allocator;

const cache_path = ".bolt/cache/";

fn getHomeDir(allocator: Allocator) ![]const u8 {
    if (std.process.getEnvVarOwned(allocator, "HOME")) |home_dir| {
        return home_dir;
    } else |err| {
        switch (err) {
            error.EnvironmentVariableNotFound => {},
            else => return err,
        }
    }

    if (std.process.getEnvVarOwned(allocator, "USERPROFILE")) |userprofile_dir| {
        return userprofile_dir;
    } else |err| {
        switch (err) {
            error.EnvironmentVariableNotFound => {},
            else => return err,
        }
    }

    return error.HomeDirectoryNotFound;
}

fn getCacheDir(allocator: Allocator) ![]const u8 {
    const home_dir = try getHomeDir(allocator);
    defer allocator.free(home_dir);

    const full = try std.fs.path.join(allocator, &.{home_dir, cache_path});
    return full;
}

pub fn init(allocator: Allocator) !void {
    const cache_dir = try getCacheDir(allocator);
    defer allocator.free(cache_dir);

    std.fs.makeDirAbsolute(cache_dir) catch |e| switch (e) {
        error.PathAlreadyExists => {},
        else => return e,
    };

    var cdir = try std.fs.openDirAbsolute(cache_dir, .{});
    defer cdir.close();
    if (!utl.fileExists(cdir, "cache.txt")) {
        const cf_path = try std.fs.path.join(allocator, &.{cache_dir, "cache.txt"});
        defer allocator.free(cf_path);
        _ = try std.fs.createFileAbsolute(cf_path, .{});
    }
}

pub fn file(allocator: Allocator, name: []const u8) !void {
    const cd_path = try getCacheDir(allocator);
    defer allocator.free(cd_path);
    const cf_path = try std.fs.path.join(allocator, &.{cd_path, "cache.txt"});
    defer allocator.free(cf_path);

    var cfile: std.fs.File = try std.fs.openFileAbsolute(cf_path, .{ .mode = .read_write, });
    defer cfile.close();

    const exists = try utl.templateExists(allocator, cfile, name);
    if (exists) |template_name| {
        defer allocator.free(template_name);
        var cdir = try std.fs.openDirAbsolute(cd_path, .{});
        defer cdir.close();
        try cdir.copyFile(name, std.fs.cwd(), template_name, .{});
    }
}

pub fn save_file(allocator: Allocator, path: []const u8, name: []const u8) !void {
    if (!utl.fileExists(std.fs.cwd(), path)) return;

    const cd_path = try getCacheDir(allocator);
    defer allocator.free(cd_path);
    const cf_path = try std.fs.path.join(allocator, &.{cd_path, "cache.txt"});
    defer allocator.free(cf_path);

    var cfile: std.fs.File = try std.fs.openFileAbsolute(cf_path, .{ .mode = .read_write, });
    defer cfile.close();

    const exists = try utl.templateExists(allocator, cfile, name);
    if (exists) |template_path| {
        allocator.free(template_path);
    } else {
        _ = try cfile.seekFromEnd(0);
        _ = try cfile.writer().print("{s}|{s}|f\n", .{ path, name });
    }

    var cdir = try std.fs.openDirAbsolute(cd_path, .{});
    defer cdir.close();
    try std.fs.cwd().copyFile(path, cdir, name, .{});
}

pub fn dir(allocator: Allocator, name: []const u8) !void {
    const cd_path = try getCacheDir(allocator);
    defer allocator.free(cd_path);
    const cf_path = try std.fs.path.join(allocator, &.{ cd_path, "cache.txt" });
    defer allocator.free(cf_path);

    var cfile: std.fs.File = try std.fs.openFileAbsolute(cf_path, .{ .mode = .read_write });
    defer cfile.close();

    const exists = try utl.templateExists(allocator, cfile, name);
    if (exists) |template_name| {
        defer allocator.free(template_name);
        var cdir = try std.fs.openDirAbsolute(cd_path, .{});
        defer cdir.close();
        try utl.copyDirRecursive(allocator, cdir, name, std.fs.cwd(), template_name);
    }
}

pub fn save_dir(allocator: Allocator, path: []const u8, name: []const u8) !void {
    var testfile = std.fs.cwd().openDir(path, .{}) catch return;
    testfile.close();

    const cd_path = try getCacheDir(allocator);
    defer allocator.free(cd_path);
    const cf_path = try std.fs.path.join(allocator, &.{ cd_path, "cache.txt" });
    defer allocator.free(cf_path);

    var cfile: std.fs.File = try std.fs.openFileAbsolute(cf_path, .{ .mode = .read_write, });
    defer cfile.close();

    const exists = try utl.templateExists(allocator, cfile, name);
    if (exists) |template_path| {
        allocator.free(template_path);
    } else {
        _ = try cfile.seekFromEnd(0);
        _ = try cfile.writer().print("{s}|{s}|d\n", .{ path, name });
    }

    var cdir = try std.fs.openDirAbsolute(cd_path, .{});
    defer cdir.close();
    try utl.copyDirRecursive(allocator, std.fs.cwd(), path, cdir, name);
}

pub fn list(allocator: Allocator) !void {
    const cd_path = try getCacheDir(allocator);
    defer allocator.free(cd_path);
    const cf_path = try std.fs.path.join(allocator, &.{cd_path, "cache.txt"});
    defer allocator.free(cf_path);

    var cfile: std.fs.File = try std.fs.openFileAbsolute(cf_path, .{ .mode = .read_only, });
    defer cfile.close();

    const max_size = 10 * 1024 * 1024;
    const content = try cfile.readToEndAlloc(allocator, max_size);
    defer allocator.free(content);

    std.debug.print("Saved templates\n", .{});
    std.debug.print("---------------\n", .{});

    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    while (lines.next()) |line| {
        var items = std.mem.tokenizeScalar(u8, line, '|');
        _ = items.next();
        if (items.next()) |template_name| {
            if (items.next()) |kind| {
                // const type_str = if (std.mem.eql(u8, kind, "f")) "file" else "directory";
                // std.debug.print("  {s} ({s})\n", .{ template_name, type_str });
                if (std.mem.eql(u8, kind, "f")) {
                    std.debug.print("  {s} (file)\n", .{ template_name });
                } else {
                    defer std.debug.print("  {s} (dir)\n", .{ template_name });
                }
            }
        }
    }
}

pub fn remove(allocator: Allocator, name: []const u8) !void {
    const cd_path = try getCacheDir(allocator);
    defer allocator.free(cd_path);
    const cf_path = try std.fs.path.join(allocator, &.{cd_path, "cache.txt"});
    defer allocator.free(cf_path);

    var cfile: std.fs.File = try std.fs.openFileAbsolute(cf_path, .{ .mode = .read_only, });
    defer cfile.close();

    const max_size = 10 * 1024 * 1024;
    const content = try cfile.readToEndAlloc(allocator, max_size);
    defer allocator.free(content);

    var new_content = std.ArrayList(u8).init(allocator);
    defer new_content.deinit();

    var found = false;
    var kind_to_delete: ?u8 = null;

    var lines = std.mem.tokenizeScalar(u8, content, '\n');
    while (lines.next()) |line| {
        var items = std.mem.tokenizeScalar(u8, line, '|');
        _ = items.next();
        const template_name = items.next();
        const kind = items.next();

        if (template_name != null and std.mem.eql(u8, template_name.?, name)) {
            found = true;
            kind_to_delete = if (kind != null and kind.?.len > 0) kind.?[0] else null;
            continue;
        }

        try new_content.appendSlice(line);
        try new_content.append('\n');
    }

    if (!found) {
        std.debug.print("Template '{s}' not found.\n", .{name});
        return;
    }

    var write_file = try std.fs.openFileAbsolute(cf_path, .{ .mode = .write_only, .lock = .exclusive });
    defer write_file.close();
    try write_file.seekTo(0);
    try write_file.setEndPos(0);
    try write_file.writeAll(new_content.items);

    var cdir = try std.fs.openDirAbsolute(cd_path, .{});
    defer cdir.close();

    if (kind_to_delete) |kind| {
        if (kind == 'f') {
            cdir.deleteFile(name) catch {};
        } else if (kind == 'd') {
            cdir.deleteTree(name) catch {};
        }
    }

    std.debug.print("Template {s} successfully removed.\n", .{name});
}

pub fn clear(allocator: Allocator) !void {
    const cd_path = try getCacheDir(allocator);
    defer allocator.free(cd_path);
    try std.fs.deleteTreeAbsolute(cd_path);
    try init(allocator);
    std.debug.print("Bolt cache successfully cleared.\n", .{});
}
