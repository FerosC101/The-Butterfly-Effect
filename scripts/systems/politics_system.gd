extends Node

func process(world, months):
	if world == null:
		return
	for r in world.regions:
		var pressure = clamp(50.0 - r.happiness, 0.0, 50.0)
		r.stability = clamp(r.stability - pressure * 0.01 * months, 0.0, 100.0)
