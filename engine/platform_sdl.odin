package engine

import "core:fmt"
import "core:mem"
import "core:strings"
import sdl "vendor:sdl2"


when THOR_PLATFORM == .SDL {

	@(private)
	InternalState :: struct {
		// h_instance: w.HINSTANCE,
		window: ^sdl.Window,
	}

	CLOCK_FREQUENCY: f64
	START_TIME: u64

	@(private)
	_platform_startup :: proc(
		plat_state: ^PlatformState,
		application_name: string,
		x, y, width, height: i32,
	) -> b8 {
		using sdl
		plat_state.internal_state = {}
		state: ^InternalState = &plat_state.internal_state

		result := Init(INIT_VIDEO | INIT_AUDIO | INIT_GAMECONTROLLER | INIT_HAPTIC)
		if result != 0 {
			fmt.eprintf("Failed to initialized SDL: %s\n", GetError())
			return false
		}

		state.window = CreateWindow(
			strings.clone_to_cstring(application_name),
			x,
			y,
			width,
			height,
			WINDOW_HIDDEN | WINDOW_RESIZABLE | WINDOW_VULKAN,
		)
		if state.window == nil {
			fmt.eprintf("Failed to create SDL window: %s\n", GetError())
			return false
		}
		ShowWindow(state.window)

		perf_freq := GetPerformanceFrequency()
		CLOCK_FREQUENCY = 1.0 / f64(perf_freq)

		return true
	}

	@(private)
	_platform_shutdown :: proc(plat_state: ^PlatformState) {
		if plat_state.internal_state.window != nil {
			sdl.DestroyWindow(plat_state.internal_state.window)
			plat_state.internal_state.window = nil
		}
	}

	@(private)
	_platform_pump_messages :: proc(plat_state: ^PlatformState) -> b8 {
		using sdl
		event: Event
		for PollEvent(&event) {
			#partial switch event.type {
			case .QUIT:
				{
					data: EventContext = {}
					event_fire(.ApplicationQuit, nil, data)
				}
			case .KEYUP, .KEYDOWN:
				{
					pressed: b8 = event.type == .KEYDOWN
					assert(pressed == (event.key.state == sdl.PRESSED))
					key, handled := sdl_scancode_to_thor_key(event.key.keysym.scancode)
					if handled {input_process_key(key, pressed)}
				}
			case .MOUSEBUTTONUP, .MOUSEBUTTONDOWN:
				{
					pressed: b8 = event.type == .MOUSEBUTTONDOWN
					assert(pressed == (event.button.state == sdl.PRESSED))
					button, handled := sdl_mousebutton_to_thor_mousebutton(event.button.button)
					if handled {input_process_button(button, pressed)}
				}
			case .MOUSEMOTION:
				{
					x_position := event.motion.x
					y_position := event.motion.y

					input_process_mouse_move(i16(x_position), i16(y_position))
				}
			case .MOUSEWHEEL:
				{
					scroll_delta := event.wheel.y
					if scroll_delta != 0 {
						scroll_delta = -1 if scroll_delta < 0 else 1
						input_process_mouse_wheel(i8(scroll_delta))
					}
				}
			case .WINDOWEVENT:
				{
					#partial switch event.window.event {
					case .RESIZED:
						{
							width := event.window.data1
							height := event.window.data2

							data: EventContext = {}
							data.data.u16[0] = u16(width)
							data.data.u16[1] = u16(height)
							event_fire(.Resized, nil, data)
						}
					}
				}
			}
		}

		return true
	}

	@(private)
	_platform_allocate :: proc(size: u64, aligned: b8) -> rawptr {
		result, err := mem.alloc(int(size))
		if err == .None {
			return result
		} else {
			TFATAL("Failed to allocate memory (%v)\n", err)
			return nil
		}
	}

	@(private)
	_platform_free :: proc(block: rawptr, aligned: b8) {
		mem.free(block)
	}

	@(private)
	_platform_zero_memory :: proc(block: rawptr, size: u64) -> rawptr {
		return mem.zero(block, int(size))
	}

	@(private)
	_platform_copy_memory :: proc(dest, src: rawptr, size: u64) -> rawptr {
		return mem.copy(dest, src, int(size))
	}

	@(private)
	_platform_set_memory :: proc(dest: rawptr, value: i32, size: u64) -> rawptr {
		return mem.set(dest, byte(value), int(size))
	}


	@(private)
	_platform_console_write :: proc(message: string, level: LogLevel) {
		using sdl
		output_colored_text(message, level)
	}

	@(private)
	_platform_console_write_error :: proc(message: string, level: LogLevel) {
		using sdl
		output_colored_text(message, level)
	}

	@(private)
	_platform_get_absolute_time :: proc() -> f64 {
		now_time: u64 = sdl.GetPerformanceCounter()
		return f64(now_time) * CLOCK_FREQUENCY
	}

	@(private)
	_platform_sleep :: proc(ms: u64) {
		sdl.Delay(u32(ms))
	}


	ESC: string : "\x1b"
	CSI: string : ESC + "["

	DEFAULT :: CSI + "0m"
	CLEARLINE :: CSI + "1K"
	MOVESTART :: CSI + "1G"

	Color :: enum {
		Black,
		Red,
		Green,
		Blue,
		Yellow,
		Magenta,
		Cyan,
		White,
		BrightBlack,
		BrightRed,
		BrightGreen,
		BrightBlue,
		BrightYellow,
		BrightMagenta,
		BrightCyan,
		BrightWhite,
	}

	ColorCode :: struct {
		fg: cstring,
		bg: cstring,
	}

	@(private = "file")
	output_colored_text :: proc(message: string, level: LogLevel) {
		codes: [Color]ColorCode = {
			.Black = {"30", "40"},
			.Red = {"31", "41"},
			.Green = {"32", "42"},
			.Yellow = {"33", "43"},
			.Blue = {"34", "44"},
			.Magenta = {"35", "45"},
			.Cyan = {"36", "46"},
			.White = {"37", "47"},
			.BrightBlack = {"90", "100"},
			.BrightRed = {"91", "101"},
			.BrightGreen = {"92", "102"},
			.BrightYellow = {"93", "103"},
			.BrightBlue = {"94", "104"},
			.BrightMagenta = {"95", "105"},
			.BrightCyan = {"96", "106"},
			.BrightWhite = {"97", "107"},
		}

		levelColors: [LogLevel]ColorCode = {
			.Fatal = {codes[.Black].fg, codes[.Red].bg},
			.Error = {codes[.Red].fg, codes[.Black].bg},
			.Warn = {codes[.Yellow].fg, codes[.Black].bg},
			.Info = {codes[.Green].fg, codes[.Black].bg},
			.Debug = {codes[.Blue].fg, codes[.Black].bg},
			.Trace = {codes[.White].fg, codes[.Black].bg},
		}

		outputString := fmt.tprintf(
			"%s%s%s%sm%s%sm%s%s\n",
			CLEARLINE,
			MOVESTART,
			CSI,
			levelColors[level].fg,
			CSI,
			levelColors[level].bg,
			message,
			DEFAULT,
		)

		sdl.Log(strings.clone_to_cstring(outputString))
	}

	@(private = "file")
	sdl_scancode_to_thor_key :: proc(sc: sdl.Scancode) -> (Keys, b8) {
		#partial switch sc {
		case .A:
			{return .A, true}
		case .B:
			{return .B, true}
		case .C:
			{return .C, true}
		case .D:
			{return .D, true}
		case .E:
			{return .E, true}
		case .F:
			{return .F, true}
		case .G:
			{return .G, true}
		case .H:
			{return .H, true}
		case .I:
			{return .I, true}
		case .J:
			{return .J, true}
		case .K:
			{return .K, true}
		case .L:
			{return .L, true}
		case .M:
			{return .M, true}
		case .N:
			{return .N, true}
		case .O:
			{return .O, true}
		case .P:
			{return .P, true}
		case .Q:
			{return .Q, true}
		case .R:
			{return .R, true}
		case .S:
			{return .S, true}
		case .T:
			{return .T, true}
		case .U:
			{return .U, true}
		case .V:
			{return .V, true}
		case .W:
			{return .W, true}
		case .X:
			{return .X, true}
		case .Y:
			{return .Y, true}
		case .Z:
			{return .Z, true}

		case .NUM1:
			{return .Num1, true}
		case .NUM2:
			{return .Num2, true}
		case .NUM3:
			{return .Num3, true}
		case .NUM4:
			{return .Num4, true}
		case .NUM5:
			{return .Num5, true}
		case .NUM6:
			{return .Num6, true}
		case .NUM7:
			{return .Num7, true}
		case .NUM8:
			{return .Num8, true}
		case .NUM9:
			{return .Num9, true}
		case .NUM0:
			{return .Num0, true}

		case .RETURN:
			{return .Enter, true}
		case .ESCAPE:
			{return .Escape, true}
		case .BACKSPACE:
			{return .Backspace, true}
		case .TAB:
			{return .Tab, true}
		case .SPACE:
			{return .Space, true}

		case .MINUS:
			{return .Minus, true}
		case .EQUALS:
			{return .Equal, true}
		case .LEFTBRACKET:
			{return .LBracket, true}
		case .RIGHTBRACKET:
			{return .RBracket, true}
		case .BACKSLASH:
			{return .Backslash, true}
		case .SEMICOLON:
			{return .Semicolon, true}
		case .APOSTROPHE:
			{return .Apostrophe, true}
		case .GRAVE:
			{return .Grave, true}
		case .COMMA:
			{return .Comma, true}
		case .PERIOD:
			{return .Period, true}
		case .SLASH:
			{return .Slash, true}

		case .CAPSLOCK:
			{return .CapsLock, true}

		case .F1:
			{return .F1, true}
		case .F2:
			{return .F2, true}
		case .F3:
			{return .F3, true}
		case .F4:
			{return .F4, true}
		case .F5:
			{return .F5, true}
		case .F6:
			{return .F6, true}
		case .F7:
			{return .F7, true}
		case .F8:
			{return .F8, true}
		case .F9:
			{return .F9, true}
		case .F10:
			{return .F10, true}
		case .F11:
			{return .F11, true}
		case .F12:
			{return .F12, true}

		case .PRINTSCREEN:
			{return .PrintScreen, true}
		case .SCROLLLOCK:
			{return .Scroll, true}
		case .PAUSE:
			{return .Pause, true}
		case .INSERT:
			{return .Insert, true}
		case .HOME:
			{return .Home, true}
		case .PAGEUP:
			{return .PageUp, true}
		case .DELETE:
			{return .Delete, true}
		case .END:
			{return .End, true}
		case .PAGEDOWN:
			{return .PageDown, true}
		case .RIGHT:
			{return .Right, true}
		case .LEFT:
			{return .Left, true}
		case .DOWN:
			{return .Down, true}
		case .UP:
			{return .Up, true}

		case .NUMLOCKCLEAR:
			{return .NumLock, true}
		case .KP_DIVIDE:
			{return .Divide, true}
		case .KP_MULTIPLY:
			{return .Multiply, true}
		case .KP_MINUS:
			{return .Minus, true}
		case .KP_PLUS:
			{return .Add, true}
		case .KP_ENTER:
			{return .NumPadEqual, true}
		case .KP_1:
			{return .NumPad1, true}
		case .KP_2:
			{return .NumPad2, true}
		case .KP_3:
			{return .NumPad3, true}
		case .KP_4:
			{return .NumPad4, true}
		case .KP_5:
			{return .NumPad5, true}
		case .KP_6:
			{return .NumPad6, true}
		case .KP_7:
			{return .NumPad7, true}
		case .KP_8:
			{return .NumPad8, true}
		case .KP_9:
			{return .NumPad9, true}
		case .KP_0:
			{return .NumPad0, true}
		case .KP_PERIOD:
			{return .Decimal, true}

		case .APPLICATION:
			{return .Apps, true}
		case .EXECUTE:
			{return .Execute, true}
		case .HELP:
			{return .Help, true}
		case .SELECT:
			{return .Select, true}

		// RETURN2 = 158,

		case .LCTRL:
			{return .LControl, true}
		case .LSHIFT:
			{return .LShift, true}
		case .LALT:
			{return .LAlt, true}
		case .LGUI:
			{return .LSuper, true}
		case .RCTRL:
			{return .RControl, true}
		case .RSHIFT:
			{return .RShift, true}
		case .RGUI:
			{return .RSuper, true}
		case .RALT:
			{return .RAlt, true}

		case .MODE:
			{return .ModeChange, true}

		case .SLEEP:
			{return .Sleep, true}

		case .APP1:
			{return .Apps, true}
		case .APP2:
			{return .Apps, true}
		case:
			{
				TERROR("Unknown/unmapped scancode: %s", sc)
			}
		}
		return .MaxKeys, false
	}

	@(private = "file")
	sdl_mousebutton_to_thor_mousebutton :: proc(smb: u8) -> (Buttons, b8) {
		switch smb {
		case sdl.BUTTON_LEFT:
			{return .Left, true}
		case sdl.BUTTON_MIDDLE:
			{return .Middle, true}
		case sdl.BUTTON_RIGHT:
			{return .Right, true}
		}
		return .MaxButtons, false
	}
}
