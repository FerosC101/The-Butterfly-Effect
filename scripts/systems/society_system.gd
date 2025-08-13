extends Node
class_name SocietySystem

static func process(world: World, months: float) -> void:
	for r in world.regions:
		var delta := 0.0
		delta += clampf(r.internet_speed / 20.0, 0.0, 5.0)
		delta -= (r.tax_rate - 15.0) * 0.2
		r.happiness = clampf(r.happiness + delta * 0.02 * months, 0.0, 100.0)
