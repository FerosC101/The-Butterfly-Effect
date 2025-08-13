extends Node

func process(world, months):
	if world == null:
		return
	for r in world.regions:
		var g = 0.015 * (months / 12.0) + clamp(r.crop_yield / 20000.0, -0.02, 0.02) * (months / 12.0)
		r.gdp *= (1.0 + g)
