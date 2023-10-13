package engine

import "core:strings"
import sdl "vendor:sdl2"
import vk "vendor:vulkan"

CTX: VulkanContext

@(private)
vulkan_renderer_backend_initialize :: proc(
	backend: ^RendererBackend,
	application_name: string,
	plat_state: ^PlatformState,
) -> b8 {
	CTX = {}
	vk.GetInstanceProcAddr =
	cast(vk.ProcGetInstanceProcAddr)platform_get_vkgetinstanceprocaddr_function()
	vk.CreateInstance = auto_cast vk.GetInstanceProcAddr(nil, "vkCreateInstance")

	vk.EnumerateInstanceExtensionProperties =
	auto_cast vk.GetInstanceProcAddr(nil, "vkEnumerateInstanceExtensionProperties")
	vk.EnumerateInstanceLayerProperties =
	auto_cast vk.GetInstanceProcAddr(nil, "vkEnumerateInstanceLayerProperties")
	vk.EnumerateInstanceVersion =
	auto_cast vk.GetInstanceProcAddr(nil, "vkEnumerateInstanceVersion")
	vk.DeviceMemoryReportCallbackEXT =
	auto_cast vk.GetInstanceProcAddr(nil, "vkDeviceMemoryReportCallbackEXT")

	app_info: vk.ApplicationInfo = {
		sType              = .APPLICATION_INFO,
		apiVersion         = vk.API_VERSION_1_2,
		pApplicationName   = plat_state.application_name,
		applicationVersion = vk.MAKE_VERSION(1, 0, 0),
		pEngineName        = plat_state.engine_name,
		engineVersion      = vk.MAKE_VERSION(0, 1, 0),
	}

	create_info: vk.InstanceCreateInfo = {
		sType                   = .INSTANCE_CREATE_INFO,
		pApplicationInfo        = &app_info,
		enabledExtensionCount   = 0,
		ppEnabledExtensionNames = nil,
		enabledLayerCount       = 0,
		ppEnabledLayerNames     = nil,
	}

	result := vk.CreateInstance(&create_info, CTX.allocator, &CTX.instance)

	if result != .SUCCESS {
		TERROR("vkCreateInstance failed with result: %v", result)
		return false
	}

	TINFO("Vulkan renderer initialized successfully.")
	return true
}

@(private)
vulkan_renderer_backend_shutdown :: proc(backend: ^RendererBackend) {}

@(private)
vulkan_renderer_backend_on_resized :: proc(backend: ^RendererBackend, width, height: u16) {}

@(private)
vulkan_renderer_backend_begin_frame :: proc(backend: ^RendererBackend, delta_time: f32) -> b8 {
	return true
}

@(private)
vulkan_renderer_backend_end_frame :: proc(backend: ^RendererBackend, delta_time: f32) -> b8 {
	return true
}
