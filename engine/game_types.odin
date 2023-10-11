package engine

Game :: struct {
	app_config: ApplicationConfig,
	initialize: proc(game_inst: ^Game) -> b8,
	update:     proc(game_inst: ^Game, delta_time: f32) -> b8,
	render:     proc(game_inst: ^Game, delta_time: f32) -> b8,
	on_resize:  proc(game_inst: ^Game, width, height: u32),
	state:      rawptr,
}
