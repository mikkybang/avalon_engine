const event_buffer = @import("./event_buffer.zig");
const event = @import("./event.zig");
const logger = @import("../logger.zig");
const std = @import("std");

const EventManagerError = error{
    EventManagerNotInitialized,
};
pub const EventManager = struct {
    event_buffer: event_buffer.EventBuffer,
    buffer_storage: [20 * @sizeOf(event.Event)]u8,
    fba: std.heap.FixedBufferAllocator,
    mutex: std.Io.Mutex,
    condition: std.Io.Condition,
    running: bool = true,
    io: std.Io,

    pub fn addEvent(self: *EventManager, new_event: *event.Event) !void {
        try self.mutex.lock(self.io);
        defer self.mutex.unlock(self.io);
        const event_added = try self.event_buffer.write(new_event);
        if (event_added) {
            self.condition.signal(self.io);
            const game_logger = try logger.getLogger();
            try game_logger.infof("Event Manager Added {s} to process", .{new_event.getName()}, @src());
        }
    }

    pub fn processEvent(self: *EventManager) !void {
        try self.mutex.lock(self.io);
        defer self.mutex.unlock(self.io);
        while (self.event_buffer.isEmpty() and self.running) {
            try self.condition.wait(self.io, &self.mutex);
        }
        if (!self.running) return;
    }

    pub fn startListening(self: *EventManager) !void {
        while (self.running) {
            try self.processEvent();
        }
    }

    pub fn stop(self: *EventManager) !void {
        try self.mutex.lock(self.io);
        defer self.mutex.unlock(self.io);
        self.running = false;
        self.condition.broadcast(self.io);
        self.event_buffer.deinit(self.fba.allocator());
    }
};

var event_manager: ?*EventManager = null;

pub fn init(io: std.Io) !*EventManager {
    if (event_manager) |existing| return existing;

    const em = try std.heap.page_allocator.create(EventManager);
    errdefer std.heap.page_allocator.destroy(em);

    em.fba = std.heap.FixedBufferAllocator.init(&em.buffer_storage);
    em.event_buffer = try event_buffer.init(em.fba.allocator(), 20);
    em.mutex = std.Io.Mutex.init;
    em.condition = std.Io.Condition.init;
    em.running = true;
    em.io = io;

    event_manager = em;
    return em;
}

pub fn getEventManager() !*EventManager {
    if (event_manager) |ev| {
        return ev;
    }
    return error.EventManagerNotInitialized;
}
