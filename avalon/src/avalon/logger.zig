const logly = @import("logly");
const std = @import("std");

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var logger: ?*logly.Logger = null;
var logger_mutex = std.Thread.Mutex{};

pub fn init() !*logly.Logger {
    logger_mutex.lock();
    defer logger_mutex.unlock();

    // Return existing logger if already initialized
    if (logger) |existing| {
        return existing;
    }
    const allocator = gpa.allocator();

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
    return init();
}

pub fn deinit() void {
    logger_mutex.lock();
    defer logger_mutex.unlock();

    if (logger) |l| {
        l.deinit();
        logger = null;
    }
    _ = gpa.deinit();
}
