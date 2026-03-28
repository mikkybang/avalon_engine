const logly = @import("logly");
const std = @import("std");

var logger: logly.Logger = undefined;

pub fn init() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create logger
    logger = try logly.Logger.init(allocator);
}
