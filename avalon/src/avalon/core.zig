const std = @import("std");

pub fn run() !void {
    // This function is required by the Zig compiler, but it won't be called
    // because we're building a library, not an executable.
    std.debug.print("Running avalon core...", .{});
}

