// +build windows
package thor_windows

foreign import ntdll_lib "system:ntdll.lib"

@(default_calling_convention = "stdcall")
foreign ntdll_lib {
	RtlGetVersion :: proc(lpVersionInformation: ^OSVERSIONINFOEXW) -> NTSTATUS ---
}
