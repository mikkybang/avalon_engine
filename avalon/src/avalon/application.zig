const std = @import("std");
const core = @import("core.zig");
const logger = @import("logger.zig");

pub const Application = struct {
    // This struct represents your application and can be used to store any state or resources that your application needs.
    x: i32,
    y: i32,
    fn run(app: *Application) !void {
        std.debug.print("Running avalon.. x={} y={}\n", .{ app.x, app.y });
        try core.run();
        while (true) {
            const gameLogger = try logger.getLogger();
            try gameLogger.warn("Game is running \n", @src());
        }
    }
};

pub fn create() !Application {
    // This function is called by the client to create an instance of your application.
    // You can use it to set up any global state or resources that your application needs.
    std.debug.print("Creating avalon application...", .{});
    var app = Application{
        .x = 0,
        .y = 0,
    };
    const appLogger = try logger.init();
    try appLogger.warn("Logger init done", @src());
    try app.run();
    return app;
}
