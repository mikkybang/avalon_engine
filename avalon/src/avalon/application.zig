const std = @import("std");
const core = @import("./core/core.zig");
const logger = @import("logger.zig");
const event = @import("event/event.zig");
const event_manager = @import("event/event_manager.zig");
const glfw = @cImport({
    @cInclude("GLFW/glfw3.h");
});

fn listenThread(game_event_manager: *event_manager.EventManager) void {
    game_event_manager.startListening() catch |err| {
        std.log.err("Event listener failed: {}", .{err});
    };
}

pub const Application = struct {
    // This struct represents your application and can be used to store any state or resources that your application needs.
    x: i32,
    y: i32,
    running: bool = true,

    pub fn stop(self: *Application) void {
        self.running = false;
    }

    pub fn run(self: *Application, init: std.process.Init) !void {
        std.debug.print("Running avalon.. x={} y={}\n", .{ self.x, self.y });
        try core.run();
        const game_logger = try logger.getLogger();
        const game_event_manager = try event_manager.init(init.io);

        const thread = try std.Thread.spawn(.{}, listenThread, .{game_event_manager});
        defer {
            game_event_manager.stop() catch {};
            thread.join();
            glfw.glfwTerminate();
            game_logger.deinit();
        }
        _ = glfw.glfwInit();
        const window = glfw.glfwCreateWindow(800, 600, "Avalon", null, null);
        glfw.glfwMakeContextCurrent(window);

        defer glfw.glfwDestroyWindow(window);

        while (glfw.glfwWindowShouldClose(window) == 0) {
            glfw.glfwSwapBuffers(window);
            glfw.glfwPollEvents();
            const event_category = [2]event.EventCategory{ event.EventCategory.Application, event.EventCategory.Input };
            var game_event: event.Event = .{ .type = event.EventType.AppRender, .categories = event.EventCategorySet.initMany(&event_category) };
            try game_event.emit();
            try game_logger.warn("Game is running \n", @src());
        }
    }
};

pub fn create(init: std.process.Init) !Application {
    // This function is called by the client to create an instance of your application.
    // You can use it to set up any global state or resources that your application needs.
    std.debug.print("Creating avalon application...", .{});
    var app = Application{
        .x = 0,
        .y = 0,
        .running = true,
    };
    const app_logger = try logger.init(init.io, init.gpa);
    try app_logger.warn("Logger init done", @src());
    try app.run(init);
    return app;
}
