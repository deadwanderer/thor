package engine

THOR_DEBUG :: ODIN_DEBUG
THOR_RELEASE :: !ODIN_DEBUG
THOR_ERROR :: #config(THOR_ERROR, true)
THOR_PLATFORM_WINDOWS :: #config(THOR_PLATFORM_WINDOWS, true)
THOR_PLATFORM_SDL :: #config(THOR_PLATFORM_SDL, true)

ThorPlatform :: enum {
	Windows,
	SDL,
}

THOR_PLATFORM: ThorPlatform : .Windows when THOR_PLATFORM_WINDOWS else .SDL
