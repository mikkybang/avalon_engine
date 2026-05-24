const std = @import("std");
const event = @import("event.zig");

pub const EventBuffer = struct {
    events: []event.Event,
    capacity: usize,
    read_index: usize,
    write_index: usize,
    mask: usize,
    pub fn write(self: *EventBuffer, data: *event.Event) !bool {
        const read_index = self.read_index;
        const write_index = self.write_index;
        const next_write_index = (self.write_index + 1) & self.mask;
        if (next_write_index == read_index) return false;
        self.events[write_index] = data.*;
        self.write_index = next_write_index;
        return true;
    }
    pub fn read(self: *EventBuffer, address: *event.Event) !bool {
        const read_index = self.read_index;
        const write_index = self.write_index;
        if (read_index == write_index) return false;
        address.* = self.events[self.read_index];
        self.read_index = (read_index + 1) & self.mask;
        return true;
    }
    pub fn isEmpty(self: *EventBuffer) !bool {
        return self.read_index == self.write_index;
    }
};

pub fn init(allocator: std.mem.Allocator, size: usize) !EventBuffer {
    const events = try allocator.alloc(event.Event, size);
    return EventBuffer{
        .events = events,
        .capacity = size,
        .read_index = 0,
        .write_index = 0,
        .mask = size - 1,
    };
}
