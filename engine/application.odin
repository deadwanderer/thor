package engine

ApplicationConfig :: struct {
	start_pos_x, start_pos_y:  i32,
	start_width, start_height: i32,
	name:                      string,
}

ApplicationState :: struct {
	game_inst:                ^Game,
	is_running, is_suspended: b8,
	platform:                 PlatformState,
	width, height:            i16,
	last_time:                f64,
}

INITIALIZED: b8

APP_STATE: ApplicationState

@(export)
application_create :: proc(game_inst: ^Game) -> b8 {
	if INITIALIZED {
		TERROR("application_create() called more than once.")
		return false
	}
	APP_STATE = {}

	APP_STATE.game_inst = game_inst

	initialize_logging()

	TFATAL("A test message: %.2f", 3.14)
	TERROR("A test message: %f", 3.14)
	TWARN("A test message: %f", 3.14)
	TINFO("A test message: %f", 3.14)
	TDEBUG("A test message: %f", 3.14)
	TTRACE("A test message: %f", 3.14)

	APP_STATE.is_running = true
	APP_STATE.is_suspended = false

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
	for APP_STATE.is_running {
		if !platform_pump_messages(&APP_STATE.platform) {
			APP_STATE.is_running = false
		}

		if !APP_STATE.is_suspended {
			if !APP_STATE.game_inst.update(APP_STATE.game_inst, 0.0) {
				TFATAL("Game update failed, shutting down")
				APP_STATE.is_running = false
				break
			}

			if !APP_STATE.game_inst.render(APP_STATE.game_inst, 0.0) {
				TFATAL("Game render failed, shutting down")
				APP_STATE.is_running = false
				break
			}
		}
	}

	platform_shutdown(&APP_STATE.platform)

	return true
}
