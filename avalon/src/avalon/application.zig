const std = @import("std");
const core = @import("./core/core.zig");
const logger = @import("logger.zig");
const event = @import("event/event.zig");
const event_manager = @import("event/event_manager.zig");

fn listenThread(game_event_manager: *event_manager.EventManager) void {
    game_event_manager.startListening() catch |err| {
        std.log.err("Event listener failed: {}", .{err});
    };
}

pub const Application = struct {
    // This struct represents your application and can be used to store any state or resources that your application needs.
    x: i32,
    y: i32,
    fn run(app: *Application) !void {
        std.debug.print("Running avalon.. x={} y={}\n", .{ app.x, app.y });
        try core.run();
        const game_logger = try logger.getLogger();
        const game_event_manager = try event_manager.init();

        const thread = try std.Thread.spawn(.{}, listenThread, .{game_event_manager});
        defer thread.join();

        while (true) {
            const event_category = [2]event.EventCategory{ event.EventCategory.Application, event.EventCategory.Input };
            var game_event: event.Event = .{ .type = event.EventType.AppRender, .categories = event.EventCategorySet.initMany(&event_category) };
            try game_event.emit();
            try game_logger.warn("Game is running \n", @src());
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
    const app_logger = try logger.init();
    try app_logger.warn("Logger init done", @src());
    try app.run();
    return app;
}
