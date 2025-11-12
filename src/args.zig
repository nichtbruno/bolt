const std = @import("std");

const print = std.debug.print;
const eql = std.mem.eql;

var PROGRAM_NAME: []const u8 = undefined;

const USAGE_MAN =
    \\Usage: {s} [OPTIONS]
    \\
    \\A template management tool for creating and reusing file and directory structures.
    \\
    \\OPTIONS:
    \\  -h, --help
    \\      Display this help message and exit.
    \\
    \\FILE TEMPLATES:
    \\  -sf <file_path> <template_name>
    \\      Save an existing file as a reusable template.
    \\
    \\  -f <template_name>
    \\      Create a new file from a saved template.
    \\
    \\DIRECTORY TEMPLATES:
    \\  -sd <directory_path> <template_name>
    \\      Save an existing directory structure and contents as a template.
    \\
    \\  -d <template_name>
    \\      Create a new directory structure from a saved template.
    \\
    \\MANAGEMENT:
    \\  -ls, --list
    \\      List all saved file and directory templates.
    \\
    \\  -r <template_name>, --remove <template_name>
    \\      Remove a saved template by name.
    \\
    \\  --clear
    \\      Delete all saved templates (cannot be undone).
    \\
    \\EXAMPLES:
    \\  Save a file as template:
    \\    bolt -sf ./config.json my_config
    \\
    \\  Create file from template:
    \\    bolt -f my_config
    \\
    \\  Save directory as template:
    \\    bolt -sd ./project_structure react_starter
    \\
    \\  Create directory from template:
    \\    bolt -d react_starter
    \\
    \\  List all templates:
    \\    bolt -ls
    \\
;

pub const Action = enum {
    HELP, FILE, SAVE_FILE, DIR, SAVE_DIR, LIST, REMOVE, CLEAR,
};

const ArgParseError = error{ MissingArgs, InvalidArgs };

pub const CLIArgs = struct {
    action: Action = undefined,
    path: []const u8 = undefined,
    name: []const u8 = undefined,

    pub fn new() CLIArgs {
        return CLIArgs {
            .action = undefined,
            .path = undefined,
            .name = undefined,
        };
    }

    pub fn parseArgs(self: *CLIArgs, args: [][:0]u8) ArgParseError!void {
        var yo: usize = 1;
        while (yo < args.len and args[yo][0] == '-') : (yo += 1) {
            if (eql(u8, args[yo], "-h") or eql(u8, args[yo], "--help")) {
                self.action = Action.HELP;
            } else if (eql(u8, args[yo], "-f")) {
                if (yo + 1 >= args.len) {
                    printQuickHelp();
                    return error.MissingArgs;
                }
                self.name = args[yo+1];
                self.action = Action.FILE;
            } else if (eql(u8, args[yo], "-sf")) {
                if (yo + 2 >= args.len) {
                    printQuickHelp();
                    return error.MissingArgs;
                }
                self.path = args[yo+1];
                self.name = args[yo+2];
                self.action = Action.SAVE_FILE;
            } else if (eql(u8, args[yo], "-d")) {
                if (yo + 1 >= args.len) {
                    printQuickHelp();
                    return error.MissingArgs;
                }
                self.name = args[yo+1];
                self.action = Action.DIR;
            } else if (eql(u8, args[yo], "-sd")) {
                if (yo + 2 >= args.len) {
                    printQuickHelp();
                    return error.MissingArgs;
                }
                self.path = args[yo+1];
                self.name = args[yo+2];
                self.action = Action.SAVE_DIR;
            } else if (eql(u8, args[yo], "-ls") or eql(u8, args[yo], "--list")) {
                self.action = Action.LIST;
            } else if (eql(u8, args[yo], "-r")) {
                if (yo + 1 >= args.len) {
                    printQuickHelp();
                    return error.MissingArgs;
                }
                self.name = args[yo+1];
                self.action = Action.REMOVE;
            } else if (eql(u8, args[yo], "--clear")) {
                self.action = Action.CLEAR;
            }
        }
    }
};

pub fn printQuickHelp() void {
    print("Invalid Usage! Try '{s} -h' for more help.\n", .{PROGRAM_NAME});
}

pub fn printMenu() void {
    print(USAGE_MAN, .{PROGRAM_NAME});
}
