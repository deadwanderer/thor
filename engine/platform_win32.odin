package engine

import "core:fmt"
import "core:mem"
import "core:runtime"
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

		window_class_name := cstring("thor_window_class")

		icon: HICON = LoadIconA(state.h_instance, IDI_APPLICATION)
		wc: WNDCLASSA = {
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

		if RegisterClassA(&wc) == 0 {
			MessageBoxA(
				nil,
				cstring("Window registration failed"),
				cstring("Error"),
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

		handle: HWND = CreateWindowExA(
			window_ex_style,
			window_class_name,
			strings.clone_to_cstring(application_name),
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
			MessageBoxA(
				nil,
				cstring("Window creation failed!"),
				cstring("Error!"),
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
		for PeekMessageA(&message, nil, 0, 0, PM_REMOVE) {
			TranslateMessage(&message)
			DispatchMessageA(&message)
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
		using w
		OutputDebugStringA(strings.clone_to_cstring(message))
		console_handle: HANDLE = GetStdHandle(STD_OUTPUT_HANDLE)
		output_colored_text(console_handle, message, level)
	}

	@(private)
	_platform_console_write_error :: proc(message: string, level: LogLevel) {
		using w
		OutputDebugStringA(strings.clone_to_cstring(message))
		console_handle: HANDLE = GetStdHandle(STD_ERROR_HANDLE)
		output_colored_text(console_handle, message, level)
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
		context = runtime.default_context()
		// fmt.printf("processing message %s\n", msg_to_type(msg))
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
	output_colored_text :: proc(handle:w.HANDLE ,message: string, level: LogLevel) {
		using w
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
			DEFAULT
		)
		consoleMode: DWORD
		if !GetConsoleMode(handle, &consoleMode) {
			fmt.eprintln("Failed to get console mode.")
			return
		}
		if !SetConsoleMode(handle, consoleMode | ENABLE_VIRTUAL_TERMINAL_PROCESSING) {
			fmt.eprintln("Failed to set console mode.")
			return
		}
		length := len(outputString)
		number_written: LPDWORD
		WriteConsoleA(handle, raw_data(outputString), u32(length), number_written, nil)
		if !SetConsoleMode(handle, consoleMode) {
			fmt.eprintln("Failed to reset console mode.")
			return
		}
	}
}

@(private = "file")
msg_to_type :: proc(msg: u32) -> string {
	switch msg {

	case 0x0000:
		{return "WM_NULL"}
	case 0x0001:
		{return "WM_CREATE"}
	case 0x0002:
		{return "WM_DESTROY"}
	case 0x0003:
		{return "WM_MOVE"}
	case 0x0005:
		{return "WM_SIZE"}
	case 0x0006:
		{return "WM_ACTIVATE"}
	case 0x0007:
		{return "WM_SETFOCUS"}
	case 0x0008:
		{return "WM_KILLFOCUS"}
	case 0x000a:
		{return "WM_ENABLE"}
	case 0x000b:
		{return "WM_SETREDRAW"}
	case 0x000c:
		{return "WM_SETTEXT"}
	case 0x000d:
		{return "WM_GETTEXT"}
	case 0x000e:
		{return "WM_GETTEXTLENGTH"}
	case 0x000f:
		{return "WM_PAINT"}
	case 0x0010:
		{return "WM_CLOSE"}
	case 0x0011:
		{return "WM_QUERYENDSESSION"}
	case 0x0012:
		{return "WM_QUIT"}
	case 0x0013:
		{return "WM_QUERYOPEN"}
	case 0x0014:
		{return "WM_ERASEBKGND"}
	case 0x0015:
		{return "WM_SYSCOLORCHANGE"}
	case 0x0016:
		{return "WM_ENDSESSION"}
	case 0x0018:
		{return "WM_SHOWWINDOW"}
	case 0x0019:
		{return "WM_CTLCOLOR"}
	case 0x001a:
		{return "WM_WININICHANGE|WM_SETTINGCHANGE"}
	case 0x001b:
		{return "WM_DEVMODECHANGE"}
	case 0x001c:
		{return "WM_ACTIVATEAPP"}
	case 0x001d:
		{return "WM_FONTCHANGE"}
	case 0x001e:
		{return "WM_TIMECHANGE"}
	case 0x001f:
		{return "WM_CANCELMODE"}
	case 0x0020:
		{return "WM_SETCURSOR"}
	case 0x0021:
		{return "WM_MOUSEACTIVATE"}
	case 0x0022:
		{return "WM_CHILDACTIVATE"}
	case 0x0023:
		{return "WM_QUEUESYNC"}
	case 0x0024:
		{return "WM_GETMINMAXINFO"}
	case 0x0026:
		{return "WM_PAINTICON"}
	case 0x0027:
		{return "WM_ICONERASEBKGND"}
	case 0x0028:
		{return "WM_NEXTDLGCTL"}
	case 0x002a:
		{return "WM_SPOOLERSTATUS"}
	case 0x002b:
		{return "WM_DRAWITEM"}
	case 0x002c:
		{return "WM_MEASUREITEM"}
	case 0x002d:
		{return "WM_DELETEITEM"}
	case 0x002e:
		{return "WM_VKEYTOITEM"}
	case 0x002f:
		{return "WM_CHARTOITEM"}
	case 0x0030:
		{return "WM_SETFONT"}
	case 0x0031:
		{return "WM_GETFONT"}
	case 0x0032:
		{return "WM_SETHOTKEY"}
	case 0x0033:
		{return "WM_GETHOTKEY"}
	case 0x0037:
		{return "WM_QUERYDRAGICON"}
	case 0x0039:
		{return "WM_COMPAREITEM"}
	case 0x003d:
		{return "WM_GETOBJECT"}
	case 0x0041:
		{return "WM_COMPACTING"}
	case 0x0044:
		{return "WM_COMMNOTIFY"}
	case 0x0046:
		{return "WM_WINDOWPOSCHANGING"}
	case 0x0047:
		{return "WM_WINDOWPOSCHANGED"}
	case 0x0048:
		{return "WM_POWER"}
	case 0x0049:
		{return "WM_COPYGLOBALDATA"}
	case 0x004a:
		{return "WM_COPYDATA"}
	case 0x004b:
		{return "WM_CANCELJOURNAL"}
	case 0x004e:
		{return "WM_NOTIFY"}
	case 0x0050:
		{return "WM_INPUTLANGCHANGEREQUEST"}
	case 0x0051:
		{return "WM_INPUTLANGCHANGE"}
	case 0x0052:
		{return "WM_TCARD"}
	case 0x0053:
		{return "WM_HELP"}
	case 0x0054:
		{return "WM_USERCHANGED"}
	case 0x0055:
		{return "WM_NOTIFYFORMAT"}
	case 0x007b:
		{return "WM_CONTEXTMENU"}
	case 0x007c:
		{return "WM_STYLECHANGING"}
	case 0x007d:
		{return "WM_STYLECHANGED"}
	case 0x007e:
		{return "WM_DISPLAYCHANGE"}
	case 0x007f:
		{return "WM_GETICON"}
	case 0x0080:
		{return "WM_SETICON"}
	case 0x0081:
		{return "WM_NCCREATE"}
	case 0x0082:
		{return "WM_NCDESTROY"}
	case 0x0083:
		{return "WM_NCCALCSIZE"}
	case 0x0084:
		{return "WM_NCHITTEST"}
	case 0x0085:
		{return "WM_NCPAINT"}
	case 0x0086:
		{return "WM_NCACTIVATE"}
	case 0x0087:
		{return "WM_GETDLGCODE"}
	case 0x0088:
		{return "WM_SYNCPAINT"}
	case 0x00a0:
		{return "WM_NCMOUSEMOVE"}
	case 0x00a1:
		{return "WM_NCLBUTTONDOWN"}
	case 0x00a2:
		{return "WM_NCLBUTTONUP"}
	case 0x00a3:
		{return "WM_NCLBUTTONDBLCLK"}
	case 0x00a4:
		{return "WM_NCRBUTTONDOWN"}
	case 0x00a5:
		{return "WM_NCRBUTTONUP"}
	case 0x00a6:
		{return "WM_NCRBUTTONDBLCLK"}
	case 0x00a7:
		{return "WM_NCMBUTTONDOWN"}
	case 0x00a8:
		{return "WM_NCMBUTTONUP"}
	case 0x00a9:
		{return "WM_NCMBUTTONDBLCLK"}
	case 0x00ab:
		{return "WM_NCXBUTTONDOWN"}
	case 0x00ac:
		{return "WM_NCXBUTTONUP"}
	case 0x00ad:
		{return "WM_NCXBUTTONDBLCLK"}
	case 0x00b0:
		{return "EM_GETSEL"}
	case 0x00b1:
		{return "EM_SETSEL"}
	case 0x00b2:
		{return "EM_GETRECT"}
	case 0x00b3:
		{return "EM_SETRECT"}
	case 0x00b4:
		{return "EM_SETRECTNP"}
	case 0x00b5:
		{return "EM_SCROLL"}
	case 0x00b6:
		{return "EM_LINESCROLL"}
	case 0x00b7:
		{return "EM_SCROLLCARET"}
	case 0x00b8:
		{return "EM_GETMODIFY"}
	case 0x00b9:
		{return "EM_SETMODIFY"}
	case 0x00ba:
		{return "EM_GETLINECOUNT"}
	case 0x00bb:
		{return "EM_LINEINDEX"}
	case 0x00bc:
		{return "EM_SETHANDLE"}
	case 0x00bd:
		{return "EM_GETHANDLE"}
	case 0x00be:
		{return "EM_GETTHUMB"}
	case 0x00c1:
		{return "EM_LINELENGTH"}
	case 0x00c2:
		{return "EM_REPLACESEL"}
	case 0x00c3:
		{return "EM_SETFONT"}
	case 0x00c4:
		{return "EM_GETLINE"}
	case 0x00c5:
		{return "EM_LIMITTEXT|EM_SETLIMITTEXT"}
	case 0x00c6:
		{return "EM_CANUNDO"}
	case 0x00c7:
		{return "EM_UNDO"}
	case 0x00c8:
		{return "EM_FMTLINES"}
	case 0x00c9:
		{return "EM_LINEFROMCHAR"}
	case 0x00ca:
		{return "EM_SETWORDBREAK"}
	case 0x00cb:
		{return "EM_SETTABSTOPS"}
	case 0x00cc:
		{return "EM_SETPASSWORDCHAR"}
	case 0x00cd:
		{return "EM_EMPTYUNDOBUFFER"}
	case 0x00ce:
		{return "EM_GETFIRSTVISIBLELINE"}
	case 0x00cf:
		{return "EM_SETREADONLY"}
	case 0x00d0:
		{return "EM_SETWORDBREAKPROC"}
	case 0x00d1:
		{return "EM_GETWORDBREAKPROC"}
	case 0x00d2:
		{return "EM_GETPASSWORDCHAR"}
	case 0x00d3:
		{return "EM_SETMARGINS"}
	case 0x00d4:
		{return "EM_GETMARGINS"}
	case 0x00d5:
		{return "EM_GETLIMITTEXT"}
	case 0x00d6:
		{return "EM_POSFROMCHAR"}
	case 0x00d7:
		{return "EM_CHARFROMPOS"}
	case 0x00d8:
		{return "EM_SETIMESTATUS"}
	case 0x00d9:
		{return "EM_GETIMESTATUS"}
	case 0x00e0:
		{return "SBM_SETPOS"}
	case 0x00e1:
		{return "SBM_GETPOS"}
	case 0x00e2:
		{return "SBM_SETRANGE"}
	case 0x00e3:
		{return "SBM_GETRANGE"}
	case 0x00e4:
		{return "SBM_ENABLE_ARROWS"}
	case 0x00e6:
		{return "SBM_SETRANGEREDRAW"}
	case 0x00e9:
		{return "SBM_SETSCROLLINFO"}
	case 0x00ea:
		{return "SBM_GETSCROLLINFO"}
	case 0x00eb:
		{return "SBM_GETSCROLLBARINFO"}
	case 0x00f0:
		{return "BM_GETCHECK"}
	case 0x00f1:
		{return "BM_SETCHECK"}
	case 0x00f2:
		{return "BM_GETSTATE"}
	case 0x00f3:
		{return "BM_SETSTATE"}
	case 0x00f4:
		{return "BM_SETSTYLE"}
	case 0x00f5:
		{return "BM_CLICK"}
	case 0x00f6:
		{return "BM_GETIMAGE"}
	case 0x00f7:
		{return "BM_SETIMAGE"}
	case 0x00f8:
		{return "BM_SETDONTCLICK"}
	case 0x00fe:
		{return "WM_INPUT_DEVICE_CHANGE"}
	case 0x00ff:
		{return "WM_INPUT"}
	case 0x0100:
		{return "WM_KEYDOWN|WM_KEYFIRST"}
	case 0x0101:
		{return "WM_KEYUP"}
	case 0x0102:
		{return "WM_CHAR"}
	case 0x0103:
		{return "WM_DEADCHAR"}
	case 0x0104:
		{return "WM_SYSKEYDOWN"}
	case 0x0105:
		{return "WM_SYSKEYUP"}
	case 0x0106:
		{return "WM_SYSCHAR"}
	case 0x0107:
		{return "WM_SYSDEADCHAR"}
	case 0xFFFF:
		{return "UNICODE_NOCHAR"}
	case 0x0109:
		{return "WM_UNICHAR|WM_KEYLAST|WM_WNT_CONVERTREQUESTEX"}
	case 0x010a:
		{return "WM_CONVERTREQUEST"}
	case 0x010b:
		{return "WM_CONVERTRESULT"}
	case 0x010c:
		{return "WM_INTERIM"}
	case 0x010d:
		{return "WM_IME_STARTCOMPOSITION"}
	case 0x010e:
		{return "WM_IME_ENDCOMPOSITION"}
	case 0x010f:
		{return "WM_IME_COMPOSITION|WM_IME_KEYLAST"}
	case 0x0110:
		{return "WM_INITDIALOG"}
	case 0x0111:
		{return "WM_COMMAND"}
	case 0x0112:
		{return "WM_SYSCOMMAND"}
	case 0x0113:
		{return "WM_TIMER"}
	case 0x0114:
		{return "WM_HSCROLL"}
	case 0x0115:
		{return "WM_VSCROLL"}
	case 0x0116:
		{return "WM_INITMENU"}
	case 0x0117:
		{return "WM_INITMENUPOPUP"}
	case 0x0118:
		{return "WM_SYSTIMER"}
	case 0x011f:
		{return "WM_MENUSELECT"}
	case 0x0120:
		{return "WM_MENUCHAR"}
	case 0x0121:
		{return "WM_ENTERIDLE"}
	case 0x0122:
		{return "WM_MENURBUTTONUP"}
	case 0x0123:
		{return "WM_MENUDRAG"}
	case 0x0124:
		{return "WM_MENUGETOBJECT"}
	case 0x0125:
		{return "WM_UNINITMENUPOPUP"}
	case 0x0126:
		{return "WM_MENUCOMMAND"}
	case 0x0127:
		{return "WM_CHANGEUISTATE"}
	case 0x0128:
		{return "WM_UPDATEUISTATE"}
	case 0x0129:
		{return "WM_QUERYUISTATE"}
	case 0x0131:
		{return "WM_LBTRACKPOINT"}
	case 0x0132:
		{return "WM_CTLCOLORMSGBOX"}
	case 0x0133:
		{return "WM_CTLCOLOREDIT"}
	case 0x0134:
		{return "WM_CTLCOLORLISTBOX"}
	case 0x0135:
		{return "WM_CTLCOLORBTN"}
	case 0x0136:
		{return "WM_CTLCOLORDLG"}
	case 0x0137:
		{return "WM_CTLCOLORSCROLLBAR"}
	case 0x0138:
		{return "WM_CTLCOLORSTATIC"}
	case 0x0140:
		{return "CB_GETEDITSEL"}
	case 0x0141:
		{return "CB_LIMITTEXT"}
	case 0x0142:
		{return "CB_SETEDITSEL"}
	case 0x0143:
		{return "CB_ADDSTRING"}
	case 0x0144:
		{return "CB_DELETESTRING"}
	case 0x0145:
		{return "CB_DIR"}
	case 0x0146:
		{return "CB_GETCOUNT"}
	case 0x0147:
		{return "CB_GETCURSEL"}
	case 0x0148:
		{return "CB_GETLBTEXT"}
	case 0x0149:
		{return "CB_GETLBTEXTLEN"}
	case 0x014a:
		{return "CB_INSERTSTRING"}
	case 0x014b:
		{return "CB_RESETCONTENT"}
	case 0x014c:
		{return "CB_FINDSTRING"}
	case 0x014d:
		{return "CB_SELECTSTRING"}
	case 0x014e:
		{return "CB_SETCURSEL"}
	case 0x014f:
		{return "CB_SHOWDROPDOWN"}
	case 0x0150:
		{return "CB_GETITEMDATA"}
	case 0x0151:
		{return "CB_SETITEMDATA"}
	case 0x0152:
		{return "CB_GETDROPPEDCONTROLRECT"}
	case 0x0153:
		{return "CB_SETITEMHEIGHT"}
	case 0x0154:
		{return "CB_GETITEMHEIGHT"}
	case 0x0155:
		{return "CB_SETEXTENDEDUI"}
	case 0x0156:
		{return "CB_GETEXTENDEDUI"}
	case 0x0157:
		{return "CB_GETDROPPEDSTATE"}
	case 0x0158:
		{return "CB_FINDSTRINGEXACT"}
	case 0x0159:
		{return "CB_SETLOCALE"}
	case 0x015a:
		{return "CB_GETLOCALE"}
	case 0x015b:
		{return "CB_GETTOPINDEX"}
	case 0x015c:
		{return "CB_SETTOPINDEX"}
	case 0x015d:
		{return "CB_GETHORIZONTALEXTENT"}
	case 0x015e:
		{return "CB_SETHORIZONTALEXTENT"}
	case 0x015f:
		{return "CB_GETDROPPEDWIDTH"}
	case 0x0160:
		{return "CB_SETDROPPEDWIDTH"}
	case 0x0161:
		{return "CB_INITSTORAGE"}
	case 0x0163:
		{return "CB_MULTIPLEADDSTRING"}
	case 0x0164:
		{return "CB_GETCOMBOBOXINFO"}
	case 0x0165:
		{return "CB_MSGMAX"}
	case 0x0200:
		{return "WM_MOUSEFIRST|WM_MOUSEMOVE"}
	case 0x0201:
		{return "WM_LBUTTONDOWN"}
	case 0x0202:
		{return "WM_LBUTTONUP"}
	case 0x0203:
		{return "WM_LBUTTONDBLCLK"}
	case 0x0204:
		{return "WM_RBUTTONDOWN"}
	case 0x0205:
		{return "WM_RBUTTONUP"}
	case 0x0206:
		{return "WM_RBUTTONDBLCLK"}
	case 0x0207:
		{return "WM_MBUTTONDOWN"}
	case 0x0208:
		{return "WM_MBUTTONUP"}
	case 0x0209:
		{return "WM_MBUTTONDBLCLK|WM_MOUSELAST"}
	case 0x020a:
		{return "WM_MOUSEWHEEL"}
	case 0x020b:
		{return "WM_XBUTTONDOWN"}
	case 0x020c:
		{return "WM_XBUTTONUP"}
	case 0x020d:
		{return "WM_XBUTTONDBLCLK"}
	case 0x020e:
		{return "WM_MOUSEHWHEEL"}
	case 0x0210:
		{return "WM_PARENTNOTIFY"}
	case 0x0211:
		{return "WM_ENTERMENULOOP"}
	case 0x0212:
		{return "WM_EXITMENULOOP"}
	case 0x0213:
		{return "WM_NEXTMENU"}
	case 0x0214:
		{return "WM_SIZING"}
	case 0x0215:
		{return "WM_CAPTURECHANGED"}
	case 0x0216:
		{return "WM_MOVING"}
	case 0x0218:
		{return "WM_POWERBROADCAST"}
	case 0x0219:
		{return "WM_DEVICECHANGE"}
	case 0x0220:
		{return "WM_MDICREATE"}
	case 0x0221:
		{return "WM_MDIDESTROY"}
	case 0x0222:
		{return "WM_MDIACTIVATE"}
	case 0x0223:
		{return "WM_MDIRESTORE"}
	case 0x0224:
		{return "WM_MDINEXT"}
	case 0x0225:
		{return "WM_MDIMAXIMIZE"}
	case 0x0226:
		{return "WM_MDITILE"}
	case 0x0227:
		{return "WM_MDICASCADE"}
	case 0x0228:
		{return "WM_MDIICONARRANGE"}
	case 0x0229:
		{return "WM_MDIGETACTIVE"}
	case 0x0230:
		{return "WM_MDISETMENU"}
	case 0x0231:
		{return "WM_ENTERSIZEMOVE"}
	case 0x0232:
		{return "WM_EXITSIZEMOVE"}
	case 0x0233:
		{return "WM_DROPFILES"}
	case 0x0234:
		{return "WM_MDIREFRESHMENU"}
	case 0x0238:
		{return "WM_POINTERDEVICECHANGE"}
	case 0x0239:
		{return "WM_POINTERDEVICEINRANGE"}
	case 0x023a:
		{return "WM_POINTERDEVICEOUTOFRANGE"}
	case 0x0240:
		{return "WM_TOUCH"}
	case 0x0241:
		{return "WM_NCPOINTERUPDATE"}
	case 0x0242:
		{return "WM_NCPOINTERDOWN"}
	case 0x0243:
		{return "WM_NCPOINTERUP"}
	case 0x0245:
		{return "WM_POINTERUPDATE"}
	case 0x0246:
		{return "WM_POINTERDOWN"}
	case 0x0247:
		{return "WM_POINTERUP"}
	case 0x0249:
		{return "WM_POINTERENTER"}
	case 0x024a:
		{return "WM_POINTERLEAVE"}
	case 0x024b:
		{return "WM_POINTERACTIVATE"}
	case 0x024c:
		{return "WM_POINTERCAPTURECHANGED"}
	case 0x024d:
		{return "WM_TOUCHHITTESTING"}
	case 0x024e:
		{return "WM_POINTERWHEEL"}
	case 0x024f:
		{return "WM_POINTERHWHEEL"}
	case 0x0250:
		{return "DM_POINTERHITTEST"}
	case 0x0251:
		{return "WM_POINTERROUTEDTO"}
	case 0x0252:
		{return "WM_POINTERROUTEDAWAY"}
	case 0x0253:
		{return "WM_POINTERROUTEDRELEASED"}
	case 0x0280:
		{return "WM_IME_REPORT"}
	case 0x0281:
		{return "WM_IME_SETCONTEXT"}
	case 0x0282:
		{return "WM_IME_NOTIFY"}
	case 0x0283:
		{return "WM_IME_CONTROL"}
	case 0x0284:
		{return "WM_IME_COMPOSITIONFULL"}
	case 0x0285:
		{return "WM_IME_SELECT"}
	case 0x0286:
		{return "WM_IME_CHAR"}
	case 0x0288:
		{return "WM_IME_REQUEST"}
	case 0x0290:
		{return "WM_IMEKEYDOWN|WM_IME_KEYDOWN"}
	case 0x0291:
		{return "WM_IMEKEYUP|WM_IME_KEYUP"}
	case 0x02a0:
		{return "WM_NCMOUSEHOVER"}
	case 0x02a1:
		{return "WM_MOUSEHOVER"}
	case 0x02a2:
		{return "WM_NCMOUSELEAVE"}
	case 0x02a3:
		{return "WM_MOUSELEAVE"}
	case 0x02b1:
		{return "WM_WTSSESSION_CHANGE"}
	case 0x02c0:
		{return "WM_TABLET_FIRST"}
	case 0x02df:
		{return "WM_TABLET_LAST"}
	case 0x02e0:
		{return "WM_DPICHANGED"}
	case 0x02e2:
		{return "WM_DPICHANGED_BEFOREPARENT"}
	case 0x02e3:
		{return "WM_DPICHANGED_AFTERPARENT"}
	case 0x02e4:
		{return "WM_GETDPISCALEDSIZE"}
	case 0x0300:
		{return "WM_CUT"}
	case 0x0301:
		{return "WM_COPY"}
	case 0x0302:
		{return "WM_PASTE"}
	case 0x0303:
		{return "WM_CLEAR"}
	case 0x0304:
		{return "WM_UNDO"}
	case 0x0305:
		{return "WM_RENDERFORMAT"}
	case 0x0306:
		{return "WM_RENDERALLFORMATS"}
	case 0x0307:
		{return "WM_DESTROYCLIPBOARD"}
	case 0x0308:
		{return "WM_DRAWCLIPBOARD"}
	case 0x0309:
		{return "WM_PAINTCLIPBOARD"}
	case 0x030a:
		{return "WM_VSCROLLCLIPBOARD"}
	case 0x030b:
		{return "WM_SIZECLIPBOARD"}
	case 0x030c:
		{return "WM_ASKCBFORMATNAME"}
	case 0x030d:
		{return "WM_CHANGECBCHAIN"}
	case 0x030e:
		{return "WM_HSCROLLCLIPBOARD"}
	case 0x030f:
		{return "WM_QUERYNEWPALETTE"}
	case 0x0310:
		{return "WM_PALETTEISCHANGING"}
	case 0x0311:
		{return "WM_PALETTECHANGED"}
	case 0x0312:
		{return "WM_HOTKEY"}
	case 0x0317:
		{return "WM_PRINT"}
	case 0x0318:
		{return "WM_PRINTCLIENT"}
	case 0x0319:
		{return "WM_APPCOMMAND"}
	case 0x031A:
		{return "WM_THEMECHANGED"}
	case 0x031D:
		{return "WM_CLIPBOARDUPDATE"}
	case 0x031E:
		{return "WM_DWMCOMPOSITIONCHANGED"}
	case 0x031F:
		{return "WM_DWMNCRENDERINGCHANGED"}
	case 0x0320:
		{return "WM_DWMCOLORIZATIONCOLORCHANGED"}
	case 0x0321:
		{return "WM_DWMWINDOWMAXIMIZEDCHANGE"}
	case 0x0323:
		{return "WM_DWMSENDICONICTHUMBNAIL"}
	case 0x0326:
		{return "WM_DWMSENDICONICLIVEPREVIEWBITMAP"}
	case 0x033F:
		{return "WM_GETTITLEBARINFOEX"}
	case 0x0358:
		{return "WM_HANDHELDFIRST"}
	case 0x035f:
		{return "WM_HANDHELDLAST"}
	case 0x0360:
		{return "WM_AFXFIRST"}
	case 0x037f:
		{return "WM_AFXLAST"}
	case 0x0380:
		{return "WM_PENWINFIRST"}
	case 0x0381:
		{return "WM_RCRESULT"}
	case 0x0382:
		{return "WM_HOOKRCRESULT"}
	case 0x0383:
		{return "WM_GLOBALRCCHANGE|WM_PENMISCINFO"}
	case 0x0384:
		{return "WM_SKB"}
	case 0x0385:
		{return "WM_HEDITCTL|WM_PENCTL"}
	case 0x0386:
		{return "WM_PENMISC"}
	case 0x0387:
		{return "WM_CTLINIT"}
	case 0x0388:
		{return "WM_PENEVENT"}
	case 0x038f:
		{return "WM_PENWINLAST"}
	case 0x0400:
		{return "DDM_SETFMT|DM_GETDEFID|NIN_SELECT|TBM_GETPOS|WM_PSD_PAGESETUPDLG|WM_USER"}
	case 0x0401:
		{return "CBEM_INSERTITEMA|DDM_DRAW|DM_SETDEFID|HKM_SETHOTKEY"}
	case 0x0402:
		{return "CBEM_SETIMAGELIST"}
	case 0x0403:
		{return "CBEM_GETIMAGELIST"}
	case 0x0404:
		{return "CBEM_GETITEMA"}
	case 0x0405:
		{return "CBEM_SETITEMA"}
	case 0x0406:
		{return "CBEM_GETCOMBOCONTROL"}
	case 0x0407:
		{return "CBEM_GETEDITCONTROL"}
	case 0x0408:
		{return "CBEM_SETEXSTYLE"}
	case 0x0409:
		{return "CBEM_GETEXSTYLE"}
	case 0x040a:
		{return "CBEM_HASEDITCHANGED"}
	case 0x040b:
		{return "CBEM_INSERTITEMW"}
	case 0x040c:
		{return "CBEM_SETITEMW"}
	case 0x040d:
		{return "CBEM_GETITEMW"}
	case 0x040e:
		{return "CBEM_SETEXTENDEDSTYLE"}
	case 0x040f:
		{return "SB_SETICON"}
	case 0x0410:
		{return "PBM_SETSTATE"}
	case 0x0411:
		{return "PBM_GETSTATE"}
	case 0x0412:
		{return "RB_SETTOOLTIPS"}
	case 0x0413:
		{return "RB_SETBKCOLOR"}
	case 0x0414:
		{return "RB_GETBKCOLOR"}
	case 0x0415:
		{return "RB_SETTEXTCOLOR"}
	case 0x0416:
		{return "RB_GETTEXTCOLOR"}
	case 0x0417:
		{return "RB_SIZETORECT"}
	case 0x0418:
		{return "RB_BEGINDRAG"}
	case 0x0419:
		{return "RB_ENDDRAG"}
	case 0x041a:
		{return "RB_DRAGMOVE"}
	case 0x041b:
		{return "RB_GETBARHEIGHT"}
	case 0x041c:
		{return "RB_GETBANDINFOW"}
	case 0x041d:
		{return "RB_GETBANDINFOA"}
	case 0x041e:
		{return "RB_MINIMIZEBAND"}
	case 0x041f:
		{return "RB_MAXIMIZEBAND"}
	case 0x0420:
		{return "TBM_SETBUDDY"}
	case 0x0421:
		{return "MSG_FTS_JUMP_VA"}
	case 0x0422:
		{return "RB_GETBANDBORDERS"}
	case 0x0423:
		{return "MSG_FTS_JUMP_QWORD"}
	case 0x0424:
		{return "MSG_REINDEX_REQUEST"}
	case 0x0425:
		{return "MSG_FTS_WHERE_IS_IT"}
	case 0x0426:
		{return "RB_GETPALETTE"}
	case 0x0427:
		{return "RB_MOVEBAND"}
	case 0x0428:
		{return "TB_GETROWS"}
	case 0x0429:
		{return "TB_GETBITMAPFLAGS"}
	case 0x042a:
		{return "TB_SETCMDID"}
	case 0x042b:
		{return "RB_PUSHCHEVRON"}
	case 0x042c:
		{return "TB_GETBITMAP"}
	case 0x042d:
		{return "MSG_GET_DEFFONT"}
	case 0x042e:
		{return "TB_REPLACEBITMAP"}
	case 0x042f:
		{return "TB_SETINDENT"}
	case 0x0430:
		{return "TB_SETIMAGELIST"}
	case 0x0431:
		{return "TB_GETIMAGELIST"}
	case 0x0432:
		{return "TB_LOADIMAGES"}
	case 0x0433:
		{return "EM_DISPLAYBAND"}
	case 0x0434:
		{return "EM_EXGETSEL"}
	case 0x0435:
		{return "EM_EXLIMITTEXT"}
	case 0x0436:
		{return "EM_EXLINEFROMCHAR"}
	case 0x0437:
		{return "EM_EXSETSEL"}
	case 0x0438:
		{return "EM_FINDTEXT"}
	case 0x0439:
		{return "EM_FORMATRANGE"}
	case 0x043a:
		{return "EM_GETCHARFORMAT"}
	case 0x043b:
		{return "EM_GETEVENTMASK"}
	case 0x043c:
		{return "EM_GETOLEINTERFACE"}
	case 0x043d:
		{return "EM_GETPARAFORMAT"}
	case 0x043e:
		{return "EM_GETSELTEXT"}
	case 0x043f:
		{return "EM_HIDESELECTION"}
	case 0x0440:
		{return "EM_PASTESPECIAL"}
	case 0x0441:
		{return "EM_REQUESTRESIZE"}
	case 0x0442:
		{return "EM_SELECTIONTYPE"}
	case 0x0443:
		{return "EM_SETBKGNDCOLOR"}
	case 0x0444:
		{return "EM_SETCHARFORMAT"}
	case 0x0445:
		{return "EM_SETEVENTMASK"}
	case 0x0446:
		{return "EM_SETOLECALLBACK"}
	case 0x0447:
		{return "EM_SETPARAFORMAT"}
	case 0x0448:
		{return "EM_SETTARGETDEVICE"}
	case 0x0449:
		{return "EM_STREAMIN"}
	case 0x044a:
		{return "EM_STREAMOUT"}
	case 0x044b:
		{return "EM_GETTEXTRANGE"}
	case 0x044c:
		{return "EM_FINDWORDBREAK"}
	case 0x044d:
		{return "EM_SETOPTIONS"}
	case 0x044e:
		{return "EM_GETOPTIONS"}
	case 0x044f:
		{return "EM_FINDTEXTEX"}
	case 0x0450:
		{return "EM_GETWORDBREAKPROCEX"}
	case 0x0451:
		{return "EM_SETWORDBREAKPROCEX"}
	case 0x0452:
		{return "EM_SETUNDOLIMIT"}
	case 0x0453:
		{return "TB_GETMAXSIZE"}
	case 0x0454:
		{return "EM_REDO"}
	case 0x0455:
		{return "EM_CANREDO"}
	case 0x0456:
		{return "EM_GETUNDONAME"}
	case 0x0457:
		{return "EM_GETREDONAME"}
	case 0x0458:
		{return "EM_STOPGROUPTYPING"}
	case 0x0459:
		{return "EM_SETTEXTMODE"}
	case 0x045a:
		{return "EM_GETTEXTMODE"}
	case 0x045b:
		{return "EM_AUTOURLDETECT"}
	case 0x045c:
		{return "EM_GETAUTOURLDETECT"}
	case 0x045d:
		{return "EM_SETPALETTE"}
	case 0x045e:
		{return "EM_GETTEXTEX"}
	case 0x045f:
		{return "EM_GETTEXTLENGTHEX"}
	case 0x0460:
		{return "EM_SHOWSCROLLBAR"}
	case 0x0461:
		{return "EM_SETTEXTEX"}
	case 0x0463:
		{return "TAPI_REPLY"}
	case 0x0464:
		{return "ACM_OPENA"}
	case 0x0465:
		{return "ACM_PLAY"}
	case 0x0466:
		{return "ACM_STOP"}
	case 0x0467:
		{return "ACM_OPENW"}
	case 0x0468:
		{return "BFFM_SETSTATUSTEXTW"}
	case 0x0469:
		{return "CDM_HIDECONTROL"}
	case 0x046a:
		{return "CDM_SETDEFEXT"}
	case 0x046b:
		{return "EM_GETIMEOPTIONS"}
	case 0x046c:
		{return "EM_CONVPOSITION"}
	case 0x046d:
		{return "MCIWNDM_GETZOOM"}
	case 0x046e:
		{return "PSM_APPLY"}
	case 0x046f:
		{return "PSM_SETTITLEA"}
	case 0x0470:
		{return "PSM_SETWIZBUTTONS"}
	case 0x0471:
		{return "PSM_PRESSBUTTON"}
	case 0x0472:
		{return "PSM_SETCURSELID"}
	case 0x0473:
		{return "PSM_SETFINISHTEXTA"}
	case 0x0474:
		{return "PSM_GETTABCONTROL"}
	case 0x0475:
		{return "PSM_ISDIALOGMESSAGE"}
	case 0x0476:
		{return "MCIWNDM_REALIZE"}
	case 0x0477:
		{return "MCIWNDM_SETTIMEFORMATA"}
	case 0x0478:
		{return "EM_SETLANGOPTIONS"}
	case 0x0479:
		{return "EM_GETLANGOPTIONS"}
	case 0x047a:
		{return "EM_GETIMECOMPMODE"}
	case 0x047b:
		{return "EM_FINDTEXTW"}
	case 0x047c:
		{return "EM_FINDTEXTEXW"}
	case 0x047d:
		{return "EM_RECONVERSION"}
	case 0x047e:
		{return "EM_SETIMEMODEBIAS"}
	case 0x047f:
		{return "EM_GETIMEMODEBIAS"}
	case 0x0480:
		{return "MCIWNDM_GETERRORA"}
	case 0x0481:
		{return "PSM_HWNDTOINDEX"}
	case 0x0482:
		{return "PSM_INDEXTOHWND"}
	case 0x0483:
		{return "MCIWNDM_SETINACTIVETIMER"}
	case 0x0484:
		{return "PSM_INDEXTOPAGE"}
	case 0x0485:
		{return "DL_BEGINDRAG"}
	case 0x0486:
		{return "DL_DRAGGING"}
	case 0x0487:
		{return "DL_DROPPED"}
	case 0x0488:
		{return "DL_CANCELDRAG"}
	case 0x048c:
		{return "MCIWNDM_GET_SOURCE"}
	case 0x048d:
		{return "MCIWNDM_PUT_SOURCE"}
	case 0x048e:
		{return "MCIWNDM_GET_DEST"}
	case 0x048f:
		{return "MCIWNDM_PUT_DEST"}
	case 0x0490:
		{return "MCIWNDM_CAN_PLAY"}
	case 0x0491:
		{return "MCIWNDM_CAN_WINDOW"}
	case 0x0492:
		{return "MCIWNDM_CAN_RECORD"}
	case 0x0493:
		{return "MCIWNDM_CAN_SAVE"}
	case 0x0494:
		{return "MCIWNDM_CAN_EJECT"}
	case 0x0495:
		{return "MCIWNDM_CAN_CONFIG"}
	case 0x0496:
		{return "IE_GETINK"}
	case 0x0497:
		{return "IE_SETINK"}
	case 0x0498:
		{return "IE_GETPENTIP"}
	case 0x0499:
		{return "IE_SETPENTIP"}
	case 0x049a:
		{return "IE_GETERASERTIP"}
	case 0x049b:
		{return "IE_SETERASERTIP"}
	case 0x049c:
		{return "IE_GETBKGND"}
	case 0x049d:
		{return "IE_SETBKGND"}
	case 0x049e:
		{return "IE_GETGRIDORIGIN"}
	case 0x049f:
		{return "IE_SETGRIDORIGIN"}
	case 0x04a0:
		{return "IE_GETGRIDPEN"}
	case 0x04a1:
		{return "IE_SETGRIDPEN"}
	case 0x04a2:
		{return "IE_GETGRIDSIZE"}
	case 0x04a3:
		{return "IE_SETGRIDSIZE"}
	case 0x04a4:
		{return "IE_GETMODE"}
	case 0x04a5:
		{return "IE_SETMODE"}
	case 0x04a6:
		{return "IE_GETINKRECT"}
	case 0x04a7:
		{return "WM_CAP_GET_MCI_DEVICEW"}
	case 0x04b4:
		{return "WM_CAP_PAL_OPENW"}
	case 0x04b5:
		{return "WM_CAP_PAL_SAVEW"}
	case 0x04b8:
		{return "IE_GETAPPDATA"}
	case 0x04b9:
		{return "IE_SETAPPDATA"}
	case 0x04ba:
		{return "IE_GETDRAWOPTS"}
	case 0x04bb:
		{return "IE_SETDRAWOPTS"}
	case 0x04bc:
		{return "IE_GETFORMAT"}
	case 0x04bd:
		{return "IE_SETFORMAT"}
	case 0x04be:
		{return "IE_GETINKINPUT"}
	case 0x04bf:
		{return "IE_SETINKINPUT"}
	case 0x04c0:
		{return "IE_GETNOTIFY"}
	case 0x04c1:
		{return "IE_SETNOTIFY"}
	case 0x04c2:
		{return "IE_GETRECOG"}
	case 0x04c3:
		{return "IE_SETRECOG"}
	case 0x04c4:
		{return "IE_GETSECURITY"}
	case 0x04c5:
		{return "IE_SETSECURITY"}
	case 0x04c6:
		{return "IE_GETSEL"}
	case 0x04c7:
		{return "IE_SETSEL"}
	case 0x04c8:
		{return "CDM_LAST"}
	case 0x04c9:
		{return "EM_GETBIDIOPTIONS"}
	case 0x04ca:
		{return "EM_SETTYPOGRAPHYOPTIONS"}
	case 0x04cb:
		{return "EM_GETTYPOGRAPHYOPTIONS"}
	case 0x04cc:
		{return "EM_SETEDITSTYLE"}
	case 0x04cd:
		{return "EM_GETEDITSTYLE"}
	case 0x04ce:
		{return "IE_GETPDEVENT"}
	case 0x04cf:
		{return "IE_GETSELCOUNT"}
	case 0x04d0:
		{return "IE_GETSELITEMS"}
	case 0x04d1:
		{return "IE_GETSTYLE"}
	case 0x04db:
		{return "MCIWNDM_SETTIMEFORMATW"}
	case 0x04dc:
		{return "EM_OUTLINE"}
	case 0x04dd:
		{return "EM_GETSCROLLPOS"}
	case 0x04de:
		{return "EM_SETSCROLLPOS"}
	case 0x04df:
		{return "EM_SETFONTSIZE"}
	case 0x04e0:
		{return "EM_GETZOOM"}
	case 0x04e1:
		{return "EM_SETZOOM"}
	case 0x04e2:
		{return "EM_GETVIEWKIND"}
	case 0x04e3:
		{return "EM_SETVIEWKIND"}
	case 0x04e4:
		{return "EM_GETPAGE"}
	case 0x04e5:
		{return "EM_SETPAGE"}
	case 0x04e6:
		{return "EM_GETHYPHENATEINFO"}
	case 0x04e7:
		{return "EM_SETHYPHENATEINFO"}
	case 0x04eb:
		{return "EM_GETPAGEROTATE"}
	case 0x04ec:
		{return "EM_SETPAGEROTATE"}
	case 0x04ed:
		{return "EM_GETCTFMODEBIAS"}
	case 0x04ee:
		{return "EM_SETCTFMODEBIAS"}
	case 0x04f0:
		{return "EM_GETCTFOPENSTATUS"}
	case 0x04f1:
		{return "EM_SETCTFOPENSTATUS"}
	case 0x04f2:
		{return "EM_GETIMECOMPTEXT"}
	case 0x04f3:
		{return "EM_ISIME"}
	case 0x04f4:
		{return "EM_GETIMEPROPERTY"}
	case 0x050d:
		{return "EM_GETQUERYRTFOBJ"}
	case 0x050e:
		{return "EM_SETQUERYRTFOBJ"}
	case 0x0600:
		{return "FM_GETFOCUS"}
	case 0x0601:
		{return "FM_GETDRIVEINFOA"}
	case 0x0602:
		{return "FM_GETSELCOUNT"}
	case 0x0603:
		{return "FM_GETSELCOUNTLFN"}
	case 0x0604:
		{return "FM_GETFILESELA"}
	case 0x0605:
		{return "FM_GETFILESELLFNA"}
	case 0x0606:
		{return "FM_REFRESH_WINDOWS"}
	case 0x0607:
		{return "FM_RELOAD_EXTENSIONS"}
	case 0x0611:
		{return "FM_GETDRIVEINFOW"}
	case 0x0614:
		{return "FM_GETFILESELW"}
	case 0x0615:
		{return "FM_GETFILESELLFNW"}
	case 0x0659:
		{return "WLX_WM_SAS"}
	case 0x07e8:
		{return "SM_GETSELCOUNT"}
	case 0x07e9:
		{return "SM_GETSERVERSELA"}
	case 0x07ea:
		{return "SM_GETSERVERSELW"}
	case 0x07eb:
		{return "SM_GETCURFOCUSA"}
	case 0x07ec:
		{return "SM_GETCURFOCUSW"}
	case 0x07ed:
		{return "SM_GETOPTIONS"}
	case 0x07ee:
		{return "UM_GETCURFOCUSW"}
	case 0x07ef:
		{return "UM_GETOPTIONS"}
	case 0x07f0:
		{return "UM_GETOPTIONS2"}
	case 0x1000:
		{return "LVM_FIRST"}
	case 0x1001:
		{return "LVM_SETBKCOLOR"}
	case 0x1002:
		{return "LVM_GETIMAGELIST"}
	case 0x1003:
		{return "LVM_SETIMAGELIST"}
	case 0x1004:
		{return "LVM_GETITEMCOUNT"}
	case 0x1005:
		{return "LVM_GETITEMA"}
	case 0x1006:
		{return "LVM_SETITEMA"}
	case 0x1007:
		{return "LVM_INSERTITEMA"}
	case 0x1008:
		{return "LVM_DELETEITEM"}
	case 0x1009:
		{return "LVM_DELETEALLITEMS"}
	case 0x100a:
		{return "LVM_GETCALLBACKMASK"}
	case 0x100b:
		{return "LVM_SETCALLBACKMASK"}
	case 0x100c:
		{return "LVM_GETNEXTITEM"}
	case 0x100d:
		{return "LVM_FINDITEMA"}
	case 0x100e:
		{return "LVM_GETITEMRECT"}
	case 0x100f:
		{return "LVM_SETITEMPOSITION"}
	case 0x1010:
		{return "LVM_GETITEMPOSITION"}
	case 0x1011:
		{return "LVM_GETSTRINGWIDTHA"}
	case 0x1012:
		{return "LVM_HITTEST"}
	case 0x1013:
		{return "LVM_ENSUREVISIBLE"}
	case 0x1014:
		{return "LVM_SCROLL"}
	case 0x1015:
		{return "LVM_REDRAWITEMS"}
	case 0x1016:
		{return "LVM_ARRANGE"}
	case 0x1017:
		{return "LVM_EDITLABELA"}
	case 0x1018:
		{return "LVM_GETEDITCONTROL"}
	case 0x1019:
		{return "LVM_GETCOLUMNA"}
	case 0x101a:
		{return "LVM_SETCOLUMNA"}
	case 0x101b:
		{return "LVM_INSERTCOLUMNA"}
	case 0x101c:
		{return "LVM_DELETECOLUMN"}
	case 0x101d:
		{return "LVM_GETCOLUMNWIDTH"}
	case 0x101e:
		{return "LVM_SETCOLUMNWIDTH"}
	case 0x101f:
		{return "LVM_GETHEADER"}
	case 0x1021:
		{return "LVM_CREATEDRAGIMAGE"}
	case 0x1022:
		{return "LVM_GETVIEWRECT"}
	case 0x1023:
		{return "LVM_GETTEXTCOLOR"}
	case 0x1024:
		{return "LVM_SETTEXTCOLOR"}
	case 0x1025:
		{return "LVM_GETTEXTBKCOLOR"}
	case 0x1026:
		{return "LVM_SETTEXTBKCOLOR"}
	case 0x1027:
		{return "LVM_GETTOPINDEX"}
	case 0x1028:
		{return "LVM_GETCOUNTPERPAGE"}
	case 0x1029:
		{return "LVM_GETORIGIN"}
	case 0x102a:
		{return "LVM_UPDATE"}
	case 0x102b:
		{return "LVM_SETITEMSTATE"}
	case 0x102c:
		{return "LVM_GETITEMSTATE"}
	case 0x102d:
		{return "LVM_GETITEMTEXTA"}
	case 0x102e:
		{return "LVM_SETITEMTEXTA"}
	case 0x102f:
		{return "LVM_SETITEMCOUNT"}
	case 0x1030:
		{return "LVM_SORTITEMS"}
	case 0x1031:
		{return "LVM_SETITEMPOSITION32"}
	case 0x1032:
		{return "LVM_GETSELECTEDCOUNT"}
	case 0x1033:
		{return "LVM_GETITEMSPACING"}
	case 0x1034:
		{return "LVM_GETISEARCHSTRINGA"}
	case 0x1035:
		{return "LVM_SETICONSPACING"}
	case 0x1036:
		{return "LVM_SETEXTENDEDLISTVIEWSTYLE"}
	case 0x1037:
		{return "LVM_GETEXTENDEDLISTVIEWSTYLE"}
	case 0x1038:
		{return "LVM_GETSUBITEMRECT"}
	case 0x1039:
		{return "LVM_SUBITEMHITTEST"}
	case 0x103a:
		{return "LVM_SETCOLUMNORDERARRAY"}
	case 0x103b:
		{return "LVM_GETCOLUMNORDERARRAY"}
	case 0x103c:
		{return "LVM_SETHOTITEM"}
	case 0x103d:
		{return "LVM_GETHOTITEM"}
	case 0x103e:
		{return "LVM_SETHOTCURSOR"}
	case 0x103f:
		{return "LVM_GETHOTCURSOR"}
	case 0x1040:
		{return "LVM_APPROXIMATEVIEWRECT"}
	case 0x1041:
		{return "LVM_SETWORKAREAS"}
	case 0x1042:
		{return "LVM_GETSELECTIONMARK"}
	case 0x1043:
		{return "LVM_SETSELECTIONMARK"}
	case 0x1044:
		{return "LVM_SETBKIMAGEA"}
	case 0x1045:
		{return "LVM_GETBKIMAGEA"}
	case 0x1046:
		{return "LVM_GETWORKAREAS"}
	case 0x1047:
		{return "LVM_SETHOVERTIME"}
	case 0x1048:
		{return "LVM_GETHOVERTIME"}
	case 0x1049:
		{return "LVM_GETNUMBEROFWORKAREAS"}
	case 0x104a:
		{return "LVM_SETTOOLTIPS"}
	case 0x104b:
		{return "LVM_GETITEMW"}
	case 0x104c:
		{return "LVM_SETITEMW"}
	case 0x104d:
		{return "LVM_INSERTITEMW"}
	case 0x104e:
		{return "LVM_GETTOOLTIPS"}
	case 0x1053:
		{return "LVM_FINDITEMW"}
	case 0x1057:
		{return "LVM_GETSTRINGWIDTHW"}
	case 0x105f:
		{return "LVM_GETCOLUMNW"}
	case 0x1060:
		{return "LVM_SETCOLUMNW"}
	case 0x1061:
		{return "LVM_INSERTCOLUMNW"}
	case 0x1073:
		{return "LVM_GETITEMTEXTW"}
	case 0x1074:
		{return "LVM_SETITEMTEXTW"}
	case 0x1075:
		{return "LVM_GETISEARCHSTRINGW"}
	case 0x1076:
		{return "LVM_EDITLABELW"}
	case 0x108b:
		{return "LVM_GETBKIMAGEW"}
	case 0x108c:
		{return "LVM_SETSELECTEDCOLUMN"}
	case 0x108d:
		{return "LVM_SETTILEWIDTH"}
	case 0x108e:
		{return "LVM_SETVIEW"}
	case 0x108f:
		{return "LVM_GETVIEW"}
	case 0x1091:
		{return "LVM_INSERTGROUP"}
	case 0x1093:
		{return "LVM_SETGROUPINFO"}
	case 0x1095:
		{return "LVM_GETGROUPINFO"}
	case 0x1096:
		{return "LVM_REMOVEGROUP"}
	case 0x1097:
		{return "LVM_MOVEGROUP"}
	case 0x109a:
		{return "LVM_MOVEITEMTOGROUP"}
	case 0x109b:
		{return "LVM_SETGROUPMETRICS"}
	case 0x109c:
		{return "LVM_GETGROUPMETRICS"}
	case 0x109d:
		{return "LVM_ENABLEGROUPVIEW"}
	case 0x109e:
		{return "LVM_SORTGROUPS"}
	case 0x109f:
		{return "LVM_INSERTGROUPSORTED"}
	case 0x10a0:
		{return "LVM_REMOVEALLGROUPS"}
	case 0x10a1:
		{return "LVM_HASGROUP"}
	case 0x10a2:
		{return "LVM_SETTILEVIEWINFO"}
	case 0x10a3:
		{return "LVM_GETTILEVIEWINFO"}
	case 0x10a4:
		{return "LVM_SETTILEINFO"}
	case 0x10a5:
		{return "LVM_GETTILEINFO"}
	case 0x10a6:
		{return "LVM_SETINSERTMARK"}
	case 0x10a7:
		{return "LVM_GETINSERTMARK"}
	case 0x10a8:
		{return "LVM_INSERTMARKHITTEST"}
	case 0x10a9:
		{return "LVM_GETINSERTMARKRECT"}
	case 0x10aa:
		{return "LVM_SETINSERTMARKCOLOR"}
	case 0x10ab:
		{return "LVM_GETINSERTMARKCOLOR"}
	case 0x10ad:
		{return "LVM_SETINFOTIP"}
	case 0x10ae:
		{return "LVM_GETSELECTEDCOLUMN"}
	case 0x10af:
		{return "LVM_ISGROUPVIEWENABLED"}
	case 0x10b0:
		{return "LVM_GETOUTLINECOLOR"}
	case 0x10b1:
		{return "LVM_SETOUTLINECOLOR"}
	case 0x10b3:
		{return "LVM_CANCELEDITLABEL"}
	case 0x10b4:
		{return "LVM_MAPINDEXTOID"}
	case 0x10b5:
		{return "LVM_MAPIDTOINDEX"}
	case 0x10b6:
		{return "LVM_ISITEMVISIBLE"}
	case 0x10cc:
		{return "LVM_GETEMPTYTEXT"}
	case 0x10cd:
		{return "LVM_GETFOOTERRECT"}
	case 0x10ce:
		{return "LVM_GETFOOTERINFO"}
	case 0x10cf:
		{return "LVM_GETFOOTERITEMRECT"}
	case 0x10d0:
		{return "LVM_GETFOOTERITEM"}
	case 0x10d1:
		{return "LVM_GETITEMINDEXRECT"}
	case 0x10d2:
		{return "LVM_SETITEMINDEXSTATE"}
	case 0x10d3:
		{return "LVM_GETNEXTITEMINDEX"}
	case 0x1600:
		{return "BCM_FIRST"}
	case 0x1600 + 0x0006:
		{return "BCM_SETDROPDOWNSTATE"}
	case 0x1600 + 0x0007:
		{return "BCM_SETSPLITINFO"}
	case 0x1600 + 0x0008:
		{return "BCM_GETSPLITINFO"}
	case 0x1600 + 0x0009:
		{return "BCM_SETNOTE"}
	case 0x1600 + 0x000A:
		{return "BCM_GETNOTE"}
	case 0x1600 + 0x000B:
		{return "BCM_GETNOTELENGTH"}
	case 0x1600 + 0x000C:
		{return "BCM_SETSHIELD"}
	case 0x2000:
		{return "OCM__BASE"}
	case 0x2005:
		{return "LVM_SETUNICODEFORMAT"}
	case 0x2006:
		{return "LVM_GETUNICODEFORMAT"}
	case 0x2019:
		{return "OCM_CTLCOLOR"}
	case 0x202b:
		{return "OCM_DRAWITEM"}
	case 0x202c:
		{return "OCM_MEASUREITEM"}
	case 0x202d:
		{return "OCM_DELETEITEM"}
	case 0x202e:
		{return "OCM_VKEYTOITEM"}
	case 0x202f:
		{return "OCM_CHARTOITEM"}
	case 0x2039:
		{return "OCM_COMPAREITEM"}
	case 0x204e:
		{return "OCM_NOTIFY"}
	case 0x2111:
		{return "OCM_COMMAND"}
	case 0x2114:
		{return "OCM_HSCROLL"}
	case 0x2115:
		{return "OCM_VSCROLL"}
	case 0x2132:
		{return "OCM_CTLCOLORMSGBOX"}
	case 0x2133:
		{return "OCM_CTLCOLOREDIT"}
	case 0x2134:
		{return "OCM_CTLCOLORLISTBOX"}
	case 0x2135:
		{return "OCM_CTLCOLORBTN"}
	case 0x2136:
		{return "OCM_CTLCOLORDLG"}
	case 0x2137:
		{return "OCM_CTLCOLORSCROLLBAR"}
	case 0x2138:
		{return "OCM_CTLCOLORSTATIC"}
	case 0x2210:
		{return "OCM_PARENTNOTIFY"}
	case 0x8000:
		{return "WM_APP"}
	case 0xcccd:
		{return "WM_RASDIALEVENT"}
	case:
		{
			return "<UNKNOWN>"
		}
	}
}
