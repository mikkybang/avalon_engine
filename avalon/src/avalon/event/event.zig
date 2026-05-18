const std = @import("std");
const mouse = @import("../core/mouse.zig");
const logger = @import("../logger.zig");

pub const EventType = enum(u32) { None, WindowClose, WindowResize, WindowFocus, WindowLostFocus, WindowMoved, AppTick, AppUpdate, AppRender, KeyPressed, KeyReleased, KeyTyped, MouseButtonPressed, MouseButtonReleased, MouseMoved, MouseScrolled };

pub const EventCategory = enum { Application, Input, Keyboard, Mouse, MousePressed };

pub const EventCategorySet = std.EnumSet(EventCategory);

// Data for different Events
pub const KeyEvent = struct { key: u16, is_repeat: bool = false };
pub const MouseMovedEvent = struct { x: f32 = 0, y: f32 = 0 };
pub const MousePressedEvent = struct { button: mouse.MouseButton };
pub const MouseReleasedEvent = struct { button: mouse.MouseButton };
pub const WindowEvent = struct { width: u16 = 0, height: u16 = 0 };

pub const EventData = union(enum) {
    key_pressed: KeyEvent,
    key_released: KeyEvent,
    mouse_moved: MouseMovedEvent,
    mouse_pressed: MousePressedEvent,
    mouse_released: MouseReleasedEvent,
    window_resized: WindowEvent,
    app_tick: void,
    app_update: void,
    app_render: void,
    none: void,
};

pub const Event = struct {
    type: EventType,
    categories: EventCategorySet,
    handled: bool = false,
    data: EventData = EventData{ .none = undefined },
    fn getName(self: Event) []const u8 {
        return @tagName(self.type);
    }
    fn isInCategory(self: Event, category: EventCategory) bool {
        return self.categories.contains(category);
    }
    pub fn emit(self: *Event) !void {
        const game_logger = try logger.getLogger();
        try game_logger.infof("Event {s} emitted", .{self.getName()}, @src());
        if (!self.handled) self.handled = true;
    }
};
