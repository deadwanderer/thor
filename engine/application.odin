package engine

ApplicationConfig :: struct {
	start_pos_x, start_pos_y:  i32,
	start_width, start_height: i32,
	name:                      string,
}

@(private = "file")
ApplicationState :: struct {
	game_inst:                ^Game,
	is_running, is_suspended: b8,
	platform:                 PlatformState,
	width, height:            i16,
	clock:                    Clock,
	last_time:                f64,
}

@(private = "file")
INITIALIZED: b8

@(private = "file")
APP_STATE: ApplicationState

@(export)
application_create :: proc(game_inst: ^Game) -> b8 {
	if INITIALIZED {
		TERROR("application_create() called more than once.")
		return false
	}
	APP_STATE = {}

	APP_STATE.game_inst = game_inst


	// TFATAL("A test message: %.2f", 3.14)
	// TERROR("A test message: %f", 3.14)
	// TWARN("A test message: %f", 3.14)
	// TINFO("A test message: %f", 3.14)
	// TDEBUG("A test message: %f", 3.14)
	// TTRACE("A test message: %f", 3.14)


	if !event_initialize() {
		TERROR("Event system failed to initialize. Application cannot continue.")
		return false
	}

	input_initialize()

	APP_STATE.is_running = true
	APP_STATE.is_suspended = false


	event_register(.ApplicationQuit, nil, application_on_event)
	event_register(.KeyPressed, nil, application_on_key)
	event_register(.KeyReleased, nil, application_on_key)

	if !platform_startup(
		   &APP_STATE.platform,
		   game_inst.app_config.name,
		   game_inst.app_config.start_pos_x,
		   game_inst.app_config.start_pos_y,
		   game_inst.app_config.start_width,
		   game_inst.app_config.start_height,
	   ) {
		return false
	}

	if !renderer_initialize(APP_STATE.game_inst.app_config.name, &APP_STATE.platform) {
		TFATAL("Failed to initialize renderer. Aborting application.")
		return false
	}

	if !APP_STATE.game_inst.initialize(APP_STATE.game_inst) {
		TFATAL("Game failed to initialize.")
		return false
	}

	APP_STATE.game_inst.on_resize(APP_STATE.game_inst, u32(APP_STATE.width), u32(APP_STATE.height))

	INITIALIZED = true

	return true
}

@(export)
application_run :: proc() -> b8 {
	clock_start(&APP_STATE.clock)
	clock_update(&APP_STATE.clock)
	APP_STATE.last_time = APP_STATE.clock.elapsed
	running_time: f64 = 0
	frame_count: u64 = 0
	target_frame_seconds: f64 = 1.0 / 60.0

	TINFO(get_memory_usage_str())

	for APP_STATE.is_running {
		if !platform_pump_messages(&APP_STATE.platform) {
			APP_STATE.is_running = false
		}

		if !APP_STATE.is_suspended {
			clock_update(&APP_STATE.clock)
			current_time: f64 = APP_STATE.clock.elapsed
			delta: f64 = current_time - APP_STATE.last_time
			frame_start_time := platform_get_absolute_time()
			if !APP_STATE.game_inst.update(APP_STATE.game_inst, f32(delta)) {
				TFATAL("Game update failed, shutting down")
				APP_STATE.is_running = false
				break
			}

			if !APP_STATE.game_inst.render(APP_STATE.game_inst, f32(delta)) {
				TFATAL("Game render failed, shutting down")
				APP_STATE.is_running = false
				break
			}

			packet: RenderPacket = {}
			packet.delta_time = f32(delta)
			renderer_draw_frame(&packet)

			frame_end_time := platform_get_absolute_time()
			frame_elapsed_time := frame_end_time - frame_start_time
			running_time += frame_elapsed_time
			remaining_seconds := target_frame_seconds - frame_elapsed_time
			// TTRACE(
			// 	"Frame elapsed time: %v, remaining time: %v",
			// 	frame_elapsed_time * 1000.0,
			// 	remaining_seconds * 1000.0,
			// )

			if remaining_seconds > 0 {
				remaining_ms := u64(remaining_seconds * 1000.0)

				limit_frames: b8 = true
				if remaining_ms > 0 && limit_frames {
					// TTRACE("Sleeping for %v ms", remaining_ms)
					platform_sleep(remaining_ms)
				}
			}
			frame_count += 1

			input_update(delta)

			APP_STATE.last_time = current_time
		}
	}

	platform_shutdown(&APP_STATE.platform)

	event_unregister(.ApplicationQuit, nil, application_on_event)
	event_unregister(.KeyPressed, nil, application_on_key)
	event_unregister(.KeyReleased, nil, application_on_key)

	renderer_shutdown()
	input_shutdown()
	event_shutdown()

	return true
}

application_on_event :: proc(
	code: SystemEventCode,
	sender: rawptr,
	listener_inst: rawptr,
	ctx: EventContext,
) -> b8 {
	#partial switch code {
	case .ApplicationQuit:
		{
			TINFO("ApplicationQuit event received, shutting down.")
			APP_STATE.is_running = false
			return true
		}
	}
	return false
}

application_on_key :: proc(
	code: SystemEventCode,
	sender: rawptr,
	listener_inst: rawptr,
	ctx: EventContext,
) -> b8 {
	#partial switch code {
	case .KeyPressed:
		{
			#partial switch ctx.data.key {
			case .Escape:
				{
					data: EventContext = {}
					event_fire(.ApplicationQuit, nil, data)
					return true
				}
			case .A:
				{
					// TDEBUG("Explicit - 'A' key pressed!")
				}
			case:
				{
					// TDEBUG("'%v' key pressed in window.", ctx.data.key)
				}
			}
		}
	case .KeyReleased:
		{
			#partial switch ctx.data.key {
			case .B:
				{
					// TDEBUG("Explicit - 'B' key released!")
				}
			case:
				{
					// TDEBUG("'%v' key released in window.", ctx.data.key)
				}
			}
		}
	}
	return false
}
