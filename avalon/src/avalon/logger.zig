const logly = @import("logly");
const std = @import("std");

var logger: ?*logly.Logger = null;
var logger_mutex = std.Io.Mutex.init;

const LoggerError = error{
    LoggerNotInitialized,
};

pub fn init(io: std.Io, allocator: std.mem.Allocator) !*logly.Logger {
    try logger_mutex.lock(io);
    defer logger_mutex.unlock(io);

    // Return existing logger if already initialized
    if (logger) |existing| {
        return existing;
    }

    // Enable ANSI colors on Windows
    _ = logly.Terminal.enableAnsiColors();

    // Create logger
    const new_logger = try logly.Logger.init(allocator);
    logger = new_logger;

    try new_logger.critical("Logger setup", @src());
    return new_logger;
}

pub fn getLogger() !*logly.Logger {
    if (logger) |l| {
        return l;
    }
    return error.LoggerNotInitialized;
}

pub fn deinit() void {
    if (logger) |l| {
        l.deinit();
        logger = null;
    }
}
