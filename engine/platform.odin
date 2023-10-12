package engine

import "core:fmt"

PlatformState :: struct {
	internal_state: InternalState,
}

@(export)
platform_startup :: proc(
	plat_state: ^PlatformState,
	application_name: string,
	x, y, width, height: i32,
) -> b8 {
	TINFO("Starting up with platform %s", THOR_PLATFORM)
	return _platform_startup(plat_state, application_name, x, y, width, height)
}

@(export)
platform_shutdown :: proc(plat_state: ^PlatformState) {
	_platform_shutdown(plat_state)
}

@(export)
platform_pump_messages :: proc(plat_state: ^PlatformState) -> b8 {
	return _platform_pump_messages(plat_state)
}

platform_allocate :: proc(size: u64, aligned: b8) -> rawptr {
	return _platform_allocate(size, aligned)
}

platform_free :: proc(block: rawptr, aligned: b8) {
	_platform_free(block, aligned)
}

platform_zero_memory :: proc(block: rawptr, size: u64) -> rawptr {
	return _platform_zero_memory(block, size)
}

platform_copy_memory :: proc(dest, src: rawptr, size: u64) -> rawptr {
	return _platform_copy_memory(dest, src, size)
}

platform_set_memory :: proc(dest: rawptr, value: i32, size: u64) -> rawptr {
	return _platform_set_memory(dest, value, size)
}

@(export)
platform_console_write :: proc(message: string, level: LogLevel) {
	_platform_console_write(message, level)
}

@(export)
platform_console_write_error :: proc(message: string, level: LogLevel) {
	_platform_console_write_error(message, level)
}

@(export)
platform_get_absolute_time :: proc() -> f64 {
	return _platform_get_absolute_time()
}

@(export)
platform_sleep :: proc(ms: u64) {
	_platform_sleep(ms)
}
