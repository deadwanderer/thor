package engine

import "core:mem"
import "core:strings"
import sdl "vendor:sdl2"


when THOR_PLATFORM == .SDL {

	@(private)
	InternalState :: struct {
		h_instance: w.HINSTANCE,
		hwnd:       w.HWND,
	}

	CLOCK_FREQUENCY: f64
	START_TIME: w.LARGE_INTEGER

	@(private)
	_platform_startup :: proc(
		plat_state: ^PlatformState,
		application_name: string,
		x, y, width, height: i32,
	) -> b8 {
		using sdl
		plat_state.internal_state = {}
		state: ^InternalState = &plat_state.internal_state


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
		for (PeekMessageA(&message, nil, 0, 0, PM_REMOVE)) {
			TranslateMessage(&message)
			DispatchMessageW(&message)
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
	_platform_console_write :: proc(message: string, color: u8) {
		using sdl
		console_handle: HANDLE = GetStdHandle(STD_OUTPUT_HANDLE)
		// Fatal, Error, Warn, Info, Debug, Trace
		levels: [6]u8 = {64, 4, 6, 2, 1, 8}
		SetConsoleTextAttribute(console_handle, u16(levels[color]))
		OutputDebugStringW(utf8_to_wstring(message))
		length := len(message)
		number_written: LPDWORD
		WriteConsoleW(console_handle, utf8_to_wstring(message), u32(length), number_written, nil)
	}

	@(private)
	_platform_console_write_error :: proc(message: string, color: u8) {
		using sdl
		console_handle: HANDLE = GetStdHandle(STD_ERROR_HANDLE)
		// Fatal, Error, Warn, Info, Debug, Trace
		levels: [6]u8 = {64, 4, 6, 2, 1, 8}
		SetConsoleTextAttribute(console_handle, u16(levels[color]))
		OutputDebugStringW(utf8_to_wstring(message))
		length := len(message)
		number_written: LPDWORD
		WriteConsoleW(console_handle, utf8_to_wstring(message), u32(length), number_written, nil)
	}

	@(private)
	_platform_get_absolute_time :: proc() -> f64 {
		now_time: w.LARGE_INTEGER
		w.QueryPerformanceCounter(&now_time)
		return f64(now_time) * CLOCK_FREQUENCY
	}

	@(private)
	_platform_sleep :: proc(ms: u64) {sdl.Delay(u32(ms))}
}
