extends Node

var rng := RandomNumberGenerator.new()

func _init():
	rng.randomize()

func process(world, months):
	if world == null:
		return
	if world.regions.is_empty():  # Fixed from 'empty()'
		return
	# small chance of a cultural event per call
	if rng.randf() < 0.005 * months:
		var idx = int(rng.randi() % world.regions.size())
		var r = world.regions[idx]
		r.culture_index = clamp(r.culture_index + rng.randf_range(5.0, 15.0), 0.0, 100.0)
		if world.has_method("push_event"):
			world.push_event("[Event] Cultural wave in %s." % r.name)
