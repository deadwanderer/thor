package engine

Buttons :: enum {
	Left,
	Middle,
	Right,
	MaxButtons,
}

Keys :: enum {
	Backspace   = 0x08,
	Enter       = 0x0D,
	Tab         = 0x09,
	Shift       = 0x10,
	Control     = 0x11,
	Pause       = 0x13,
	Capital     = 0x14,
	Escape      = 0x1B,
	Convert     = 0x1C,
	NonConvert  = 0x1D,
	Accept      = 0x1E,
	ModeChange  = 0x1F,
	Space       = 0x20,
	Prior       = 0x21,
	Next        = 0x22,
	End         = 0x23,
	Home        = 0x24,
	Left        = 0x25,
	Up          = 0x26,
	Right       = 0x27,
	Down        = 0x28,
	Select      = 0x29,
	Print       = 0x2A,
	Execute     = 0x2B,
	Snapshot    = 0x2C,
	Insert      = 0x2D,
	Delete      = 0x2E,
	Help        = 0x2F,
	A           = 0x41,
	B           = 0x42,
	C           = 0x43,
	D           = 0x44,
	E           = 0x45,
	F           = 0x46,
	G           = 0x47,
	H           = 0x48,
	I           = 0x49,
	J           = 0x4A,
	K           = 0x4B,
	L           = 0x4C,
	M           = 0x4D,
	N           = 0x4E,
	O           = 0x4F,
	P           = 0x50,
	Q           = 0x51,
	R           = 0x52,
	S           = 0x53,
	T           = 0x54,
	U           = 0x55,
	V           = 0x56,
	W           = 0x57,
	X           = 0x58,
	Y           = 0x59,
	Z           = 0x5A,
	LWin        = 0x5B,
	RWin        = 0x5C,
	Apps        = 0x5D,
	Sleep       = 0x5F,
	Numpad0     = 0x60,
	Numpad1     = 0x61,
	Numpad2     = 0x62,
	Numpad3     = 0x63,
	Numpad4     = 0x64,
	Numpad5     = 0x65,
	Numpad6     = 0x66,
	Numpad7     = 0x67,
	Numpad8     = 0x68,
	Numpad9     = 0x69,
	Multiply    = 0x6A,
	Add         = 0x6B,
	Separator   = 0x6C,
	Subtract    = 0x6D,
	Decimal     = 0x6E,
	Divide      = 0x6F,
	F1          = 0x70,
	F2          = 0x71,
	F3          = 0x72,
	F4          = 0x73,
	F5          = 0x74,
	F6          = 0x75,
	F7          = 0x76,
	F8          = 0x77,
	F9          = 0x78,
	F10         = 0x79,
	F11         = 0x7A,
	F12         = 0x7B,
	F13         = 0x7C,
	F14         = 0x7D,
	F15         = 0x7E,
	F16         = 0x7F,
	F17         = 0x80,
	F18         = 0x81,
	F19         = 0x82,
	F20         = 0x83,
	F21         = 0x84,
	F22         = 0x85,
	F23         = 0x86,
	F24         = 0x87,
	NumLock     = 0x90,
	Scroll      = 0x91,
	NumpadEqual = 0x92,
	LShift      = 0xA0,
	RShift      = 0xA1,
	LControl    = 0xA2,
	RControl    = 0xA3,
	LMenu       = 0xA4,
	RMenu       = 0xA5,
	Semicolon   = 0xBA,
	Plus        = 0xBB,
	Comma       = 0xBC,
	Minus       = 0xBD,
	Period      = 0xBE,
	Slash       = 0xBF,
	Grave       = 0xC0,
}

input_initialize :: proc() {
	STATE = {}
	IS_INITIALIZED = true
	TINFO("Input subsystem initialized.")
}

input_shutdown :: proc() {
	IS_INITIALIZED = false
}

input_update :: proc(delta_time: f64) {
	if !IS_INITIALIZED {return}

	tcopy_memory(&STATE.keyboard_previous, &STATE.keyboard_current, size_of(KeyboardState))
	tcopy_memory(&STATE.mouse_previous, &STATE.mouse_current, size_of(MouseState))
}

@(export)
input_is_key_down :: proc(key: Keys) -> b8 {
	if !IS_INITIALIZED {return false}
	return STATE.keyboard_current.keys[key] == true
}

@(export)
input_is_key_up :: proc(key: Keys) -> b8 {
	if !IS_INITIALIZED {return false}
	return STATE.keyboard_current.keys[key] == false
}

@(export)
input_was_key_down :: proc(key: Keys) -> b8 {
	if !IS_INITIALIZED {return false}
	return STATE.keyboard_previous.keys[key] == true
}

@(export)
input_was_key_up :: proc(key: Keys) -> b8 {
	if !IS_INITIALIZED {return false}
	return STATE.keyboard_previous.keys[key] == false
}

@(export)
input_key_pressed :: proc(key: Keys) -> b8 {
	if !IS_INITIALIZED {return false}
	return input_is_key_down(key) && !input_was_key_down(key)
}

@(export)
input_key_released :: proc(key: Keys) -> b8 {
	if !IS_INITIALIZED {return false}
	return input_was_key_down(key) && !input_is_key_down(key)
}

input_process_key :: proc(key: Keys, pressed: b8) {
	if STATE.keyboard_current.keys[key] != pressed {
		STATE.keyboard_current.keys[key] = pressed

		ctx: EventContext = {}
		ctx.data.key = key
		event_fire(
			SystemEventCode.KeyPressed if pressed else SystemEventCode.KeyReleased,
			nil,
			ctx,
		)
	}
}

@(export)
input_is_button_down :: proc(button: Buttons) -> b8 {
	if !IS_INITIALIZED {return false}
	return STATE.mouse_current.buttons[button] == true
}

@(export)
input_is_button_up :: proc(button: Buttons) -> b8 {
	if !IS_INITIALIZED {return false}
	return STATE.mouse_current.buttons[button] == false
}

@(export)
input_was_button_down :: proc(button: Buttons) -> b8 {
	if !IS_INITIALIZED {return false}
	return STATE.mouse_previous.buttons[button] == true
}

@(export)
input_was_button_up :: proc(button: Buttons) -> b8 {
	if !IS_INITIALIZED {return false}
	return STATE.mouse_previous.buttons[button] == false
}

@(export)
input_button_pressed :: proc(button: Buttons) -> b8 {
	if !IS_INITIALIZED {return false}
	return input_is_button_down(button) && !input_was_button_down(button)
}

@(export)
input_button_released :: proc(button: Buttons) -> b8 {
	if !IS_INITIALIZED {return false}
	return input_was_button_down(button) && !input_is_button_down(button)
}

@(export)
input_get_mouse_position :: proc() -> (x, y: i32) {
	if !IS_INITIALIZED {
		x = 0
		y = 0
		return
	}
	x = i32(STATE.mouse_current.x)
	y = i32(STATE.mouse_current.y)
	return
}

@(export)
input_get_previous_mouse_position :: proc() -> (x, y: i32) {
	if !IS_INITIALIZED {
		x = 0
		y = 0
		return
	}
	x = i32(STATE.mouse_previous.x)
	y = i32(STATE.mouse_previous.y)
	return
}

input_process_button :: proc(button: Buttons, pressed: b8) {
	if STATE.mouse_current.buttons[button] != pressed {
		STATE.mouse_current.buttons[button] = pressed

		ctx: EventContext = {}
		ctx.data.button = button
		event_fire(
			SystemEventCode.ButtonPressed if pressed else SystemEventCode.ButtonReleased,
			nil,
			ctx,
		)
	}
}

input_process_mouse_move :: proc(x, y: i16) {
	if STATE.mouse_current.x != x || STATE.mouse_current.y != y {
		STATE.mouse_current.x = x
		STATE.mouse_current.y = y

		ctx: EventContext = {}
		ctx.data.i16[0] = x
		ctx.data.i16[1] = y
		event_fire(SystemEventCode.MouseMoved, nil, ctx)
	}
}

input_process_mouse_wheel :: proc(z_delta: i8) {
	ctx: EventContext = {}
	ctx.data.i8[0] = z_delta
	event_fire(SystemEventCode.MouseWheel, nil, ctx)
}

@(private = "file")
KeyboardState :: struct {
	keys: [256]b8,
}

@(private = "file")
MouseState :: struct {
	x, y:    i16,
	buttons: [Buttons.MaxButtons]b8,
}

@(private = "file")
InputState :: struct {
	keyboard_current:  KeyboardState,
	keyboard_previous: KeyboardState,
	mouse_current:     MouseState,
	mouse_previous:    MouseState,
}

@(private = "file")
IS_INITIALIZED: b8

@(private = "file")
STATE: InputState
