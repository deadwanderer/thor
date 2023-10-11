package engine

import "core:fmt"

LOG_WARN_ENABLED :: true
LOG_INFO_ENABLED :: true

when THOR_RELEASE {
	LOG_DEBUG_ENABLED :: false
	LOG_TRACE_ENABLED :: false
} else {
	LOG_DEBUG_ENABLED :: true
	LOG_TRACE_ENABLED :: true
}

LogLevel :: enum {
	Fatal = 0,
	Error = 1,
	Warn  = 2,
	Info  = 3,
	Debug = 4,
	Trace = 5,
}

initialize_logging :: proc() -> b8 {return true}

shutdown_logging :: proc() {}

log_output :: proc(level: LogLevel, message: string, args: ..any) {
	level_strings: [6]string = {
		"[FATAL]: ",
		"[ERROR]: ",
		"[WARN]: ",
		"[INFO]: ",
		"[DEBUG]: ",
		"[TRACE]: ",
	}
	is_error: b8 = level < LogLevel.Warn

	formatted_message := fmt.tprintf(message, ..args)
	out_message := fmt.tprintf("%s%s\n", level_strings[level], formatted_message)
	if is_error {
		platform_console_write_error(out_message, u8(level))
	} else {

	}
	// fmt.printf("%s%s\n", level_strings[level], out_message)
}

@(export)
report_assertion_failure :: proc(
	expression: string,
	message: string,
	file: string,
	procedure: string,
	line: i32,
) {
	log_output(
		.Fatal,
		"Assertion failure: {}, message: '%v', in file: %v, procedure: %v, line: %v\n",
		expression,
		message,
		file,
		procedure,
		line,
	)
}

TFATAL :: proc(message: string, args: ..any) {
	log_output(.Fatal, message, ..args)
}

@(disabled = THOR_ERROR == false)
TERROR :: proc(message: string, args: ..any) {
	log_output(.Error, message, ..args)
}

@(disabled = LOG_WARN_ENABLED == false)
TWARN :: proc(message: string, args: ..any) {
	log_output(.Warn, message, ..args)
}

@(disabled = LOG_INFO_ENABLED == false)
TINFO :: proc(message: string, args: ..any) {
	log_output(.Info, message, ..args)
}

@(disabled = LOG_DEBUG_ENABLED == false)
TDEBUG :: proc(message: string, args: ..any) {
	log_output(.Debug, message, ..args)
}

@(disabled = LOG_TRACE_ENABLED == false)
TTRACE :: proc(message: string, args: ..any) {
	log_output(.Trace, message, ..args)
}
