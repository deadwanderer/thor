// +build windows
package thor_windows

foreign import "system:Comctl32.lib"

@(default_calling_convention = "stdcall")
foreign Comctl32 {
	LoadIconWithScaleDown :: proc(hinst: HINSTANCE, pszName: PCWSTR, cx: c_int, cy: c_int, phico: ^HICON) -> HRESULT ---
}
