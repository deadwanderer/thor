package engine


engine_main :: proc(
	game_inst: ^Game,
	create_game: proc(out_game: ^Game) -> b8,
	shutdown_game: proc(out_game: ^Game),
) {
	initialize_memory()
	initialize_logging()

	successful := create_game(game_inst)
	if !successful {
		TFATAL("Failed to initialze game instance!")
	}

	if game_inst.render == nil ||
	   game_inst.update == nil ||
	   game_inst.initialize == nil ||
	   game_inst.on_resize == nil {
		TFATAL("The game's function pointers must be assigned!")
	}


	if !application_create(game_inst) {
		TFATAL("Application failed to create!")
	}

	if !application_run() {
		TINFO("Application did not shut down gracefully.")
	}

	shutdown_game(game_inst)

	shutdown_logging()
	shutdown_memory()
}
