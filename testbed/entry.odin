package game

import e "../engine"

create_game :: proc(out_game: ^e.Game) -> b8 {
	out_game.app_config.start_pos_x = 100
	out_game.app_config.start_pos_y = 100
	out_game.app_config.start_width = 1280
	out_game.app_config.start_height = 720
	out_game.app_config.name = "Thor Engine Testbed"
	out_game.update = game_update
	out_game.render = game_render
	out_game.on_resize = game_on_resize
	out_game.initialize = game_initialize

	out_game.state = e.tallocate(size_of(GameState), .Game)

	return true
}

main :: proc() {
	game_inst: e.Game = {}
	e.engine_main(&game_inst, create_game)
}
