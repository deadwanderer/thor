package game

import e "../engine"
import "core:fmt"
import "core:mem"

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

shutdown_game :: proc(game: ^e.Game) {
	e.tfree(game.state, size_of(GameState), .Game)
}

main :: proc() {
	tracking_allocator: mem.Tracking_Allocator
	mem.tracking_allocator_init(&tracking_allocator, context.allocator)
	context.allocator = mem.tracking_allocator(&tracking_allocator)

	reset_tracking_allocator :: proc(a: ^mem.Tracking_Allocator) {
		for key, value in a.allocation_map {
			fmt.printf("%v: Leaked %v bytes\n", value.location, value.size)
		}
		for bad_free in a.bad_free_array {
			fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
		}
		mem.tracking_allocator_clear(a)
	}

	game_inst: e.Game = {}
	e.engine_main(&game_inst, create_game, shutdown_game)

	reset_tracking_allocator(&tracking_allocator)
	mem.tracking_allocator_destroy(&tracking_allocator)
}
