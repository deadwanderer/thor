package engine

import vk "vendor:vulkan"


@(private)
AssertSuccess :: proc(result: vk.Result) {
	assert(result == .SUCCESS)
}

@(private)
VulkanContext :: struct {
	instance:        vk.Instance,
	allocator:       ^vk.AllocationCallbacks,
	debug_messenger: vk.DebugUtilsMessengerEXT,
	surface:         vk.SurfaceKHR,
}
