package engine

Clock :: struct {
	start_time: f64,
	elapsed:    f64,
}

clock_update :: proc(clock: ^Clock) {
	if clock.start_time != 0.0 {
		clock.elapsed = platform_get_absolute_time() - clock.start_time
	}
}

clock_start :: proc(clock: ^Clock) {
	clock.start_time = platform_get_absolute_time()
	clock.elapsed = 0.0
}

clock_stop :: proc(clock: ^Clock) {
	clock.start_time = 0.0
}
