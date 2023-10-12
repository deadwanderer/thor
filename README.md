# Thor

So far, it's just [Kohi](https://github.com/travisvroman/kohi) in Odin, but who knows...?

## # ***\*NOTE\****
Using the Windows platform currently requires manually editing a few files in `<ODIN_ROOT>/core/sys/windows` to include `A` versions of several functions that Odin only imports `W` versions of by default. This process can usually just be copy/pasting the `W` function, and tweaking a couple elements.

In general, the difference is `<FuncName>A` instead of `<FuncName>W`, and change all strings from wide to regular (e.g. `LPCWSTR` -> `LPCSTR`)

### `<ODIN_ROOT>/core/sys/windows/user32.odin`:

Add `RegisterClassA :: proc(lpWndClass: ^WNDCLASSA) -> ATOM ---`

Uncomment or add `MessageBoxA :: proc(hWnd: HWND, lpText: LPCSTR, lpCaption: LPCSTR, uType: UINT) -> c_int ---`

Add `CreateWindowExA :: proc(dwExStyle: DWORD, lpClassName: LPCSTR,	lpWindowName: LPCSTR, dwStyle: DWORD, X: c_int, Y: c_int, nWidth: c_int, nHeight: c_int, hWndParent: HWND, hMenu: HMENU, hInstance: HINSTANCE, lpParam: LPVOID,) -> HWND ---`

Add `DispatchMessageA :: proc(lpMsg: ^MSG) -> LRESULT ---`

### `<ODIN_ROOT>/core/sys/windows/kernel32.odin`:

Add `WriteConsoleA :: proc(hConsoleOutput: HANDLE, lpBuffer: LPCVOID, nNumberOfCharsToWrite: DWORD, lpNumberOfCharsWritten: LPDWORD, lpReserved: LPVOID) -> BOOL ---`