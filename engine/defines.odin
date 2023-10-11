package engine

THOR_DEBUG :: ODIN_DEBUG
THOR_RELEASE :: !THOR_DEBUG
THOR_ERROR :: #config(THOR_ERROR, true)
THOR_PLATFORM_WINDOWS :: #config(THOR_PLATFORM_WINDOWS, false)
THOR_PLATFORM_SDL :: #config(THOR_PLATFORM_SDL, true)

ThorPlatform :: enum {
	Windows,
	SDL,
}

THOR_PLATFORM: ThorPlatform : .SDL when THOR_PLATFORM_SDL else .Windows
