package engine

RenderPacket :: struct {
	delta_time: f32,
}

@(private = "file")
BACKEND: ^RendererBackend

@(export)
renderer_initialize :: proc(application_name: string, plat_state: ^PlatformState) -> b8 {
	BACKEND = transmute(^RendererBackend)tallocate(size_of(RendererBackend), .Renderer)

	renderer_backend_create(.Vulkan, plat_state, BACKEND)
	BACKEND.frame_number = 0

	if !BACKEND.initialize(BACKEND, application_name, plat_state) {
		TFATAL("Renderer backend failed to initialize. Shutting down.")
		return false
	}
	return true
}

@(export)
renderer_shutdown :: proc() {
	BACKEND.shutdown(BACKEND)
	tfree(BACKEND, size_of(RendererBackend), .Renderer)
}

// @(export)
renderer_on_resized :: proc(width, height: u16) {
	BACKEND.on_resized(BACKEND, width, height)
}

renderer_begin_frame :: proc(delta_time: f32) -> b8 {
	return BACKEND.begin_frame(BACKEND, delta_time)
}

renderer_end_frame :: proc(delta_time: f32) -> b8 {
	result := BACKEND.end_frame(BACKEND, delta_time)
	BACKEND.frame_number += 1
	return result
}

@(export)
renderer_draw_frame :: proc(packet: ^RenderPacket) -> b8 {
	if renderer_begin_frame(packet.delta_time) {
		success := renderer_end_frame(packet.delta_time)
		if !success {
			TERROR("renderer_draw_frame(): Failed to end frame. Application shutting down...")
			return false
		}
	}
	return true
}

// RENDERER BACKEND

RendererBackendType :: enum {
	Vulkan,
}

@(private)
backend_initialize_func :: proc(
	backend: ^RendererBackend,
	application_name: string,
	plat_state: ^PlatformState,
) -> b8
@(private)
backend_shutdown_func :: proc(backend: ^RendererBackend)
@(private)
backend_on_resized_func :: proc(backend: ^RendererBackend, width, height: u16)
@(private)
backend_begin_frame_func :: proc(backend: ^RendererBackend, delta_time: f32) -> b8
@(private)
backend_end_frame_func :: proc(backend: ^RendererBackend, delta_time: f32) -> b8

@(private)
RendererBackend :: struct {
	plat_state:   ^PlatformState,
	frame_number: u64,
	initialize:   backend_initialize_func,
	shutdown:     backend_shutdown_func,
	on_resized:   backend_on_resized_func,
	begin_frame:  backend_begin_frame_func,
	end_frame:    backend_end_frame_func,
}

@(private)
renderer_backend_create :: proc(
	type: RendererBackendType,
	plat_state: ^PlatformState,
	out_renderer_backend: ^RendererBackend,
) -> b8 {
	out_renderer_backend.plat_state = plat_state

	if type == .Vulkan {
		out_renderer_backend.initialize = vulkan_renderer_backend_initialize
		out_renderer_backend.shutdown = vulkan_renderer_backend_shutdown
		out_renderer_backend.begin_frame = vulkan_renderer_backend_begin_frame
		out_renderer_backend.end_frame = vulkan_renderer_backend_end_frame
		out_renderer_backend.on_resized = vulkan_renderer_backend_on_resized
		return true
	}
	return false
}

@(private)
renderer_backend_destroy :: proc(renderer_backend: ^RendererBackend) {
	renderer_backend.initialize = nil
	renderer_backend.shutdown = nil
	renderer_backend.begin_frame = nil
	renderer_backend.end_frame = nil
	renderer_backend.on_resized = nil
}
