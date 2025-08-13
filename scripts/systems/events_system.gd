extends Node
class_name EventsSystem

static func process(world: World, months: float) -> void:
	if world.regions.is_empty(): return
	if RNG.chance(0.005 * months):
		var idx := RNG.randi() % world.regions.size()
		var r := world.regions[idx]
		r.culture_index = clampf(r.culture_index + RNG.randf_range(5.0, 15.0), 0.0, 100.0)
		EventBus.push("[Event] Cultural wave in %s." % r.name)
