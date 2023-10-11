package engine

// create_game_proc: proc(out_game: ^Game) -> b8

engine_main :: proc(game_inst: ^Game) {
	if game_inst.render == nil ||
	   game_inst.update == nil ||
	   game_inst.initialize == nil ||
	   game_inst.on_resize == nil {
		TFATAL("The game's function pointers must be assigned!")
	}

	if !application_create(game_inst) {
		TINFO("Application failed to create!")
	}

	if !application_run() {
		TINFO("Application did not shut down gracefully.")
	}
}
