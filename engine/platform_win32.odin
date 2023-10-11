package engine

import "core:mem"
import "core:strings"
import w "core:sys/windows"


when THOR_PLATFORM == .Windows {

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
		using w
		plat_state.internal_state = {}
		state: ^InternalState = &plat_state.internal_state

		state.h_instance = HINSTANCE(GetModuleHandleA(nil))

		window_class_name := w.utf8_to_wstring("thor_window_class")

		icon: HICON = LoadIconA(state.h_instance, IDI_APPLICATION)
		wc: WNDCLASSW = {
			style         = CS_DBLCLKS,
			lpfnWndProc   = win32_process_message,
			cbClsExtra    = 0,
			cbWndExtra    = 0,
			hInstance     = state.h_instance,
			hIcon         = icon,
			hCursor       = LoadCursorA(nil, IDC_ARROW),
			hbrBackground = nil,
			lpszClassName = window_class_name,
		}

		if RegisterClassW(&wc) == 0 {
			MessageBoxW(
				nil,
				w.utf8_to_wstring("Window registration failed"),
				w.utf8_to_wstring("Error"),
				MB_ICONEXCLAMATION | MB_OK,
			)
			return false
		}

		window_x := x
		window_y := y
		window_height := height
		window_width := width

		window_style :=
			WS_OVERLAPPED |
			WS_SYSMENU |
			WS_CAPTION |
			WS_MAXIMIZEBOX |
			WS_MINIMIZEBOX |
			WS_THICKFRAME
		window_ex_style := WS_EX_APPWINDOW

		border_rect: RECT = {0, 0, 0, 0}
		AdjustWindowRectEx(&border_rect, window_style, false, window_ex_style)

		window_x += border_rect.left
		window_y += border_rect.top
		window_width += border_rect.right - border_rect.left
		window_height += border_rect.bottom - border_rect.top

		handle: HWND = CreateWindowExW(
			window_ex_style,
			window_class_name,
			w.utf8_to_wstring(application_name),
			window_style,
			window_x,
			window_y,
			window_width,
			window_height,
			nil,
			nil,
			state.h_instance,
			nil,
		)

		if handle == nil {
			MessageBoxW(
				nil,
				w.utf8_to_wstring("Window creation failed!"),
				w.utf8_to_wstring("Error!"),
				MB_ICONEXCLAMATION | MB_OK,
			)
			TFATAL("Window creation failed!")
			return false
		} else {
			state.hwnd = handle
		}

		should_activate := true
		show_window_command_flags := SW_SHOW if should_activate else SW_SHOWNOACTIVATE
		ShowWindow(state.hwnd, show_window_command_flags)

		// Clock setup
		frequency: LARGE_INTEGER
		QueryPerformanceFrequency(&frequency)
		CLOCK_FREQUENCY = f64(1.0 / frequency)
		QueryPerformanceCounter(&START_TIME)

		return true
	}

	@(private)
	_platform_shutdown :: proc(plat_state: ^PlatformState) {
		if plat_state.internal_state.hwnd != nil {
			w.DestroyWindow(plat_state.internal_state.hwnd)
			plat_state.internal_state.hwnd = nil
		}
	}

	@(private)
	_platform_pump_messages :: proc(plat_state: ^PlatformState) -> b8 {
		using w
		message: MSG
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
		using w
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
		using w
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
	_platform_sleep :: proc(ms: u64) {w.Sleep(u32(ms))}

	@(private = "file")
	win32_process_message :: proc "stdcall" (
		hwnd: w.HWND,
		msg: u32,
		w_param: w.WPARAM,
		l_param: w.LPARAM,
	) -> w.LRESULT {
		using w
		switch (msg) {
		case WM_ERASEBKGND:
			{
				return 1
			}
		case WM_CLOSE:
			{
				return 0
			}
		case WM_DESTROY:
			{
				PostQuitMessage(0)
				return 0
			}
		case WM_SIZE:
			{

			}
		case WM_KEYDOWN, WM_KEYUP, WM_SYSKEYDOWN, WM_SYSKEYUP:
			{

			}
		case WM_MOUSEMOVE:
			{}
		case WM_MOUSEWHEEL:
			{}
		case WM_LBUTTONDOWN, WM_MBUTTONDOWN, WM_RBUTTONDOWN, WM_LBUTTONUP, WM_MBUTTONUP, WM_RBUTTONUP:
			{}
		}
		return DefWindowProcA(hwnd, msg, w_param, l_param)
	}

}
