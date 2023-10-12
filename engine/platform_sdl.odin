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
					return false
				}
			case .KEYUP, .KEYDOWN:
				{

				}
			case .MOUSEBUTTONUP, .MOUSEBUTTONDOWN:
				{}
			case .MOUSEMOTION:
				{

				}
			case .MOUSEWHEEL:
				{

				}
			case .WINDOWEVENT:
				{
					#partial switch event.window.event {
					case .RESIZED:
						{

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
			"%s%s%s%sm%s%sm%s",
			CLEARLINE,
			MOVESTART,
			CSI,
			levelColors[level].fg,
			CSI,
			levelColors[level].bg,
			message,
		)

		sdl.Log(strings.clone_to_cstring(outputString))
	}

	@(private)
	_platform_console_write :: proc(message: string, color: u8) {
		using sdl
		output_colored_text(message, LogLevel(color))
	}

	@(private)
	_platform_console_write_error :: proc(message: string, color: u8) {
		using sdl
		output_colored_text(message, LogLevel(color))
	}

	@(private)
	_platform_get_absolute_time :: proc() -> f64 {
		now_time: u64 = sdl.GetPerformanceCounter()
		return f64(now_time) * CLOCK_FREQUENCY
	}

	@(private)
	_platform_sleep :: proc(ms: u64) {sdl.Delay(u32(ms))}
}
