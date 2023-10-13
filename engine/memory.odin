package engine

import "core:fmt"
import "core:strings"

MemoryTag :: enum {
	Unknown,
	Array,
	DynArray,
	Dict,
	RingQueue,
	BinarySearchTree,
	String,
	Application,
	Job,
	Texture,
	MaterialInstance,
	Renderer,
	Game,
	Transform,
	Entity,
	EntityNode,
	Scene,
	MaxTags,
}

@(private = "file")
MemoryStats :: struct {
	total_allocated:    u64,
	tagged_allocations: [int(MemoryTag.MaxTags)]u64,
}

@(private = "file")
_memory_tag_strings: [int(MemoryTag.MaxTags)]string = {
	"         Unknown",
	"           Array",
	"        DynArray",
	"            Dict",
	"       RingQueue",
	"BinarySearchTree",
	"          String",
	"     Application",
	"             Job",
	"         Texture",
	"MaterialInstance",
	"        Renderer",
	"            Game",
	"       Transform",
	"          Entity",
	"      EntityNode",
	"           Scene",
}

@(private = "file")
STATS: MemoryStats

@(export)
initialize_memory :: proc() {
	STATS = {}
	// platform_zero_memory(&STATS, size_of(STATS))
}

@(export)
shutdown_memory :: proc() {}

@(export)
tallocate :: proc(size: u64, tag: MemoryTag) -> rawptr {
	if tag == .Unknown {
		TWARN("tallocate() called with tag Unknown. Re-class this allocation.")
	}

	TTRACE("Allocating %d bytes for %s", size, tag)

	STATS.total_allocated += size
	STATS.tagged_allocations[tag] += size

	block := platform_allocate(size, false)
	platform_zero_memory(block, size)
	return block
}

@(export)
tfree :: proc(block: rawptr, size: u64, tag: MemoryTag) {
	if tag == .Unknown {
		TWARN("tfree() called with tag Unknown. Re-class this allocation.")
	}

	STATS.total_allocated -= size
	STATS.tagged_allocations[tag] -= size

	platform_free(block, false)
}

@(export)
tzero_memory :: proc(block: rawptr, size: u64) -> rawptr {
	return platform_zero_memory(block, size)
}

@(export)
tcopy_memory :: proc(dest, source: rawptr, size: u64) -> rawptr {
	return platform_copy_memory(dest, source, size)
}

@(export)
tset_memory :: proc(dest: rawptr, value: i32, size: u64) -> rawptr {
	return platform_set_memory(dest, value, size)
}

@(private = "file")
KIB :: 1024
@(private = "file")
MIB :: KIB * 1024
@(private = "file")
GIB :: MIB * 1024

@(export)
get_memory_usage_str :: proc() -> string {
	sb := strings.builder_make()
	defer strings.builder_destroy(&sb)
	strings.write_string(&sb, "System memory use (tagged):\n")
	unit: string
	amount: f32
	for tag, index in MemoryTag {
		if tag == .MaxTags {
			continue
		}
		if STATS.tagged_allocations[index] == 0 {
			continue
		}
		unit, amount = unit_and_amount(STATS.tagged_allocations[index])

		strings.write_string(
			&sb,
			fmt.tprintf("\t%s: %.2f %s\n", _memory_tag_strings[tag], amount, unit),
		)
	}
	unit, amount = unit_and_amount(STATS.total_allocated)
	strings.write_string(&sb, fmt.tprintf("Total memory used: %.2f %s\n", amount, unit))
	return strings.to_string(sb)
}

@(private = "file")
unit_and_amount :: proc(value: u64) -> (unit: string, amount: f32) {
	if value >= GIB {
		unit = "GiB"
		amount = f32(f64(value) / f64(GIB))
	} else if value >= MIB {
		unit = "MiB"
		amount = f32(f64(value) / f64(MIB))
	} else if value >= KIB {
		unit = "KiB"
		amount = f32(f64(value) / f64(KIB))
	} else {
		unit = "B"
		amount = f32(f64(value))
	}
	return
}
