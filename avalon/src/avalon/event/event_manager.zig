const event_buffer = @import("./event_buffer.zig");
const event = @import("./event.zig");
const logger = @import("../logger.zig");
const std = @import("std");

pub const EventManager = struct {
    event_buffer: event_buffer.EventBuffer,
    buffer_storage: [20 * @sizeOf(event.Event)]u8,
    fba: std.heap.FixedBufferAllocator,
    mutex: std.Thread.Mutex = .{},
    condition: std.Thread.Condition = .{},

    pub fn processEvent(self: *EventManager) !void {
        self.mutex.lock();
        defer self.mutex.unlock();
        while (self.event_buffer.isEmpty()) {
            self.condition.wait(&self.mutex);
        }

        var event_to_process: event.Event = undefined;
        const event_read = try self.event_buffer.read(&event_to_process);
        if (event_read) {
            const game_logger = try logger.getLogger();
            try game_logger.infof("Event Manager processing {s}", .{event_to_process.getName()}, @src());
        }
    }
    pub fn startListening(self: *EventManager) !void {
        while (true) {
            try self.processEvent();
        }
    }
    pub fn addEvent(self: *EventManager, new_event: *event.Event) !void {
        self.mutex.lock();
        defer self.mutex.unlock();
        const event_added = try self.event_buffer.write(new_event);

        if (event_added) {
            self.condition.signal();
            const game_logger = try logger.getLogger();
            try game_logger.infof("Event Manager Added {s} to process", .{new_event.getName()}, @src());
        }
    }
};

var event_manager: ?*EventManager = null;

pub fn init() !*EventManager {
    if (event_manager) |existing| return existing;

    const em = try std.heap.page_allocator.create(EventManager);
    errdefer std.heap.page_allocator.destroy(em);

    em.fba = std.heap.FixedBufferAllocator.init(&em.buffer_storage);
    em.event_buffer = try event_buffer.init(em.fba.allocator(), 20);
    em.mutex = .{};
    em.condition = .{};

    event_manager = em;
    return em;
}

pub fn getEventManager() !*EventManager {
    if (event_manager) |ev| {
        return ev;
    }
    return init();
}
