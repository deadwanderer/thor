package engine

import "core:intrinsics"

THOR_ASSERTIONS_ENABLED :: true

// TODO: Use Odin's built-in assert, or our custom one?
// - Pro's of custom:
// - - Added procedure name
// - Con's of custom:
// - - Custom...

// @(disabled = !THOR_ASSERTIONS_ENABLED)
// TASSERT :: proc(expr: b32) {
// 	if expr {} else {
// 		report_assertion_failure("Assertion failed", "", #file, #procedure, #line)
// 		intrinsics.debug_trap()
// 	}
// }

// @(disabled = !THOR_ASSERTIONS_ENABLED)
// TASSERT_MESSAGE :: proc(expr: b32, message: string) {
// 	if expr {} else {
// 		report_assertion_failure("Assertion failed", message, #file, #procedure, #line)
// 		intrinsics.debug_trap()
// 	}
// }

// @(disabled = !ODIN_DEBUG || !THOR_ASSERTIONS_ENABLED)
// TASSERT_DEBUG :: proc(expr: b32) {
// 	if expr {} else {
// 		report_assertion_failure("Assertion failed", "", #file, #procedure, #line)
// 		intrinsics.debug_trap()
// 	}
// }

when ODIN_DEBUG {
	assert_debug :: proc(expr: bool) {assert(expr)}
} else {
	assert_debug :: proc(_: ..any) {}
}
