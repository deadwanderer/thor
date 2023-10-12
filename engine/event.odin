package engine

EventContext :: struct {
	data: struct #raw_union {
		i64:    [2]i64,
		u64:    [2]u64,
		f64:    [2]f64,
		i32:    [4]i32,
		u32:    [4]u32,
		f32:    [4]f32,
		i16:    [8]i16,
		u16:    [8]u16,
		i8:     [16]i8,
		u8:     [16]u8,
		c:      [16]byte,
		key:    Keys,
		button: Buttons,
	},
}

SystemEventCode :: enum u16 {
	ApplicationQuit = 0x01,
	KeyPressed      = 0x02,
	KeyReleased     = 0x03,
	ButtonPressed   = 0x04,
	ButtonReleased  = 0x05,
	MouseMoved      = 0x06,
	MouseWheel      = 0x07,
	Resized         = 0x08,
	Max             = 0xFF,
}

on_event_fn :: proc(
	code: SystemEventCode,
	sender: rawptr,
	listener_inst: rawptr,
	data: EventContext,
) -> b8

@(private = "file")
RegisteredEvent :: struct {
	listener: rawptr,
	callback: on_event_fn,
}

@(private = "file")
EventCodeEntry :: struct {
	events: [dynamic]RegisteredEvent,
}

@(private = "file")
MAX_MESSAGE_CODES :: 16384

@(private = "file")
EventSystemState :: struct {
	registered: [MAX_MESSAGE_CODES]EventCodeEntry,
}

@(private = "file")
IS_INITIALIZED: b8

@(private = "file")
STATE: EventSystemState

@(export)
event_initialize :: proc() -> b8 {
	if IS_INITIALIZED {
		return false
	}
	IS_INITIALIZED = false
	STATE = {}
	IS_INITIALIZED = true
	return true
}

@(export)
event_shutdown :: proc() {
	for i := 0; i < MAX_MESSAGE_CODES; i += 1 {
		delete(STATE.registered[i].events)
	}
	STATE = {}
}

@(export)
event_register :: proc(code: SystemEventCode, listener: rawptr, on_event: on_event_fn) -> b8 {
	if !IS_INITIALIZED {
		return false
	}

	registered_count := len(STATE.registered[code].events)
	for i := 0; i < registered_count; i += 1 {
		if STATE.registered[code].events[i].listener == listener {
			return false
		}
	}

	event: RegisteredEvent = {}
	event.listener = listener
	event.callback = on_event
	append(&STATE.registered[code].events, event)

	return true
}

@(export)
event_unregister :: proc(code: SystemEventCode, listener: rawptr, on_event: on_event_fn) -> b8 {
	if !IS_INITIALIZED {
		return false
	}

	registered_count := len(STATE.registered[code].events)
	if registered_count == 0 {
		return false
	}

	for i := 0; i < registered_count; i += 1 {
		e := STATE.registered[code].events[i]
		if e.listener == listener && e.callback == on_event {
			unordered_remove(&STATE.registered[code].events, i)
		}
	}

	return false
}

@(export)
event_fire :: proc(code: SystemEventCode, sender: rawptr, ctx: EventContext) -> b8 {
	if !IS_INITIALIZED {return false}

	registered_count := len(STATE.registered[code].events)
	if registered_count == 0 {
		return false
	}

	for i := 0; i < registered_count; i += 1 {
		e := STATE.registered[code].events[i]
		if e.callback(code, sender, e.listener, ctx) {
			return true
		}
	}

	return false
}
