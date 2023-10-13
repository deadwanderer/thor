package engine

import "core:runtime"
import "core:strings"

import sdl "vendor:sdl2"
import vk "vendor:vulkan"

@(private = "file")
CTX: VulkanContext

@(private = "file")
VALIDATION_LAYERS :: []cstring{"VK_LAYER_KHRONOS_validation"}

@(private)
vulkan_renderer_backend_initialize :: proc(
	backend: ^RendererBackend,
	application_name: string,
	plat_state: ^PlatformState,
) -> b8 {
	CTX = {}
	_load_vulkan_instance_functions()

	app_info: vk.ApplicationInfo = {
		sType              = .APPLICATION_INFO,
		apiVersion         = vk.API_VERSION_1_2,
		pApplicationName   = plat_state.application_name,
		applicationVersion = vk.MAKE_VERSION(1, 0, 0),
		pEngineName        = plat_state.engine_name,
		engineVersion      = vk.MAKE_VERSION(0, 1, 0),
	}


	required_extensions: [dynamic]cstring
	defer delete(required_extensions)
	plat_extensions := platform_get_required_extension_names(plat_state)
	defer delete(plat_extensions)
	append(&required_extensions, ..plat_extensions[:])
	when THOR_DEBUG {
		append(&required_extensions, vk.EXT_DEBUG_UTILS_EXTENSION_NAME)
		shrink(&required_extensions)
		TDEBUG("Required extensions:")
		for item in required_extensions {
			TDEBUG("%s", item)
		}

		TINFO("Validation layers enabled. Enumerating...")

		available_layer_count: u32 = 0
		AssertSuccess(vk.EnumerateInstanceLayerProperties(&available_layer_count, nil))
		available_layers := make([]vk.LayerProperties, available_layer_count)
		defer delete(available_layers)
		AssertSuccess(
			vk.EnumerateInstanceLayerProperties(
				&available_layer_count,
				raw_data(available_layers),
			),
		)

		for layer in VALIDATION_LAYERS {
			TINFO("Searching for layer: %s...", layer)
			found := false
			for &av_layer in available_layers {
				if layer == cstring(&av_layer.layerName[0]) {
					found = true
					TINFO("Found")
					break
				}
			}
			if !found {
				TFATAL("Required validation layer is missing: %s", layer)
				return false
			}
		}
		TINFO("All validation layers are present.")
	} else {
		shrink(&required_extensions)
	}

	create_info: vk.InstanceCreateInfo = {
		sType                   = .INSTANCE_CREATE_INFO,
		pApplicationInfo        = &app_info,
		enabledExtensionCount   = u32(len(required_extensions)),
		ppEnabledExtensionNames = raw_data(required_extensions),
		enabledLayerCount       = u32(len(VALIDATION_LAYERS)) when THOR_DEBUG else 0,
		ppEnabledLayerNames     = raw_data(VALIDATION_LAYERS) when THOR_DEBUG else nil,
	}

	result := vk.CreateInstance(&create_info, CTX.allocator, &CTX.instance)
	if result != .SUCCESS {
		TERROR("vkCreateInstance failed with result: %v", result)
		return false
	}
	TINFO("Vulkan instance created.")
	vk.load_proc_addresses_instance(CTX.instance)

	CTX.debug_messenger = 0
	when THOR_DEBUG {
		TDEBUG("Creating Vulkan debugger...")
		log_severity: vk.DebugUtilsMessageSeverityFlagsEXT = {.ERROR, .WARNING, .INFO} //, .VERBOSE}
		message_type: vk.DebugUtilsMessageTypeFlagsEXT = {.GENERAL, .PERFORMANCE, .VALIDATION}

		debug_create_info: vk.DebugUtilsMessengerCreateInfoEXT = {
			sType           = .DEBUG_UTILS_MESSENGER_CREATE_INFO_EXT,
			messageSeverity = log_severity,
			messageType     = message_type,
			pfnUserCallback = cast(vk.ProcDebugUtilsMessengerCallbackEXT)vk_debug_callback,
		}
		func := cast(vk.ProcCreateDebugUtilsMessengerEXT)vk.GetInstanceProcAddr(
			CTX.instance,
			"vkCreateDebugUtilsMessengerEXT",
		)
		if func == nil {
			TERROR("Failed to load Vulkan debug messenger function")
			return false
		}
		AssertSuccess(func(CTX.instance, &debug_create_info, CTX.allocator, &CTX.debug_messenger))
		TDEBUG("Vulkan debugger created.")
	}

	// Surface
	TDEBUG("Creating Vulkan surface...")
	if !platform_create_vulkan_surface(plat_state, &CTX) {
		TERROR("Failed to create platform surface!")
		return false
	}

	TINFO("Vulkan renderer initialized successfully.")
	return true
}

@(private)
vulkan_renderer_backend_shutdown :: proc(backend: ^RendererBackend) {
	TDEBUG("Destroying Vulkan surface...")
	vk.DestroySurfaceKHR(CTX.instance, CTX.surface, nil)
	if CTX.debug_messenger != 0 {
		TDEBUG("Destroying Vulkan debugger...")
		func := cast(vk.ProcDestroyDebugUtilsMessengerEXT)vk.GetInstanceProcAddr(
			CTX.instance,
			"vkDestroyDebugUtilsMessengerEXT",
		)
		func(CTX.instance, CTX.debug_messenger, CTX.allocator)
	}

	TDEBUG("Destroying Vulkan instance...")
	vk.DestroyInstance(CTX.instance, CTX.allocator)
}

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

@(private = "file")
vk_debug_callback :: proc "stdcall" (
	message_severity: vk.DebugUtilsMessageSeverityFlagEXT,
	message_types: vk.DebugUtilsMessageTypeFlagEXT,
	callback_data: ^vk.DebugUtilsMessengerCallbackDataEXT,
	user_data: rawptr,
) -> b32 {
	context = runtime.default_context()
	switch message_severity {
	case .ERROR:
		{
			TERROR("%s", callback_data.pMessage)
		}
	case .WARNING:
		{
			TWARN("%s", callback_data.pMessage)
		}
	case .INFO:
		{
			TINFO("%s", callback_data.pMessage)
		}
	case .VERBOSE:
		{
			TTRACE("%s", callback_data.pMessage)
		}
	}
	return false
}

@(private = "file")
_load_vulkan_instance_functions :: proc() {
	vk.GetInstanceProcAddr =
	cast(vk.ProcGetInstanceProcAddr)platform_get_vkgetinstanceprocaddr_function()
	vk.CreateInstance = cast(vk.ProcCreateInstance)vk.GetInstanceProcAddr(nil, "vkCreateInstance")

	// vk.EnumerateInstanceExtensionProperties =
	// cast(vk.ProcEnumerateInstanceExtensionProperties)vk.GetInstanceProcAddr(
	// 	nil,
	// 	"vkEnumerateInstanceExtensionProperties",
	// )
	vk.EnumerateInstanceLayerProperties =
	cast(vk.ProcEnumerateInstanceLayerProperties)vk.GetInstanceProcAddr(
		nil,
		"vkEnumerateInstanceLayerProperties",
	)
	// vk.EnumerateInstanceVersion =
	// cast(vk.ProcEnumerateInstanceVersion)vk.GetInstanceProcAddr(nil, "vkEnumerateInstanceVersion")
	// vk.DeviceMemoryReportCallbackEXT =
	// cast(vk.ProcDeviceMemoryReportCallbackEXT)vk.GetInstanceProcAddr(
	// 	nil,
	// 	"vkDeviceMemoryReportCallbackEXT",
	// )
}

@(private = "file")
_load_vulkan_functions_from_instance :: proc(inst: vk.Instance) {
	vk.DestroyInstance =
	cast(vk.ProcDestroyInstance)vk.GetInstanceProcAddr(inst, "vkDestroyInstance")
	vk.DestroySurfaceKHR =
	cast(vk.ProcDestroySurfaceKHR)vk.GetInstanceProcAddr(inst, "vkDestroySurfaceKHR")
	vk.CreateWin32SurfaceKHR =
	cast(vk.ProcCreateWin32SurfaceKHR)vk.GetInstanceProcAddr(inst, "vkCreateWin32SurfaceKHR")
}
