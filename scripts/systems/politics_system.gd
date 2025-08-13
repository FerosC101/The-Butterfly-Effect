extends Node
class_name PoliticsSystem

static func process(world: World, months: float) -> void:
	for r in world.regions:
		var pressure := clampf(50.0 - r.happiness, 0.0, 50.0)
		r.stability = clampf(r.stability - pressure * 0.01 * months, 0.0, 100.0)
