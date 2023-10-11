package game

import e "../engine"
GameState :: struct {
	delta_time: f32,
}

game_initialize :: proc(game_inst: ^e.Game) -> b8 {
	e.TDEBUG("game_initialize() called")
	return true
}

game_update :: proc(game_inst: ^e.Game, delta_time: f32) -> b8 {
	return true
}

game_render :: proc(game_inst: ^e.Game, delta_time: f32) -> b8 {
	return true
}

game_on_resize :: proc(game_inst: ^e.Game, width, height: u32) {}
