package engine

import vk "vendor:vulkan"

@(private)
VulkanContext :: struct {
	instance:  vk.Instance,
	allocator: ^vk.AllocationCallbacks,
}
