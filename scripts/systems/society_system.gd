extends Node

func process(world, months):
	if world == null:
		return
	for r in world.regions:
		var delta = clamp(r.internet_speed / 20.0, 0.0, 5.0) - (r.tax_rate - 15.0) * 0.2
		r.happiness = clamp(r.happiness + delta * 0.02 * months, 0.0, 100.0)
