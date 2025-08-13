extends Node
class_name WorldGen

func generate(seed: int, count: int = 36) -> void:
	RNG.seed(seed)
	World.reset()
	var noise := OpenSimplexNoise.new()
	noise.seed = seed
	noise.period = 32.0

	for i in count:
		var r := RegionData.new()
		r.id = i
		r.name = "R%02d" % i
		r.population = RNG.randf_range(50_000.0, 2_000_000.0)
		r.temperature = RNG.randf_range(5.0, 32.0)
		r.rainfall = clampf(1200.0 + noise.get_noise_1d(i) * 400.0, 200.0, 3000.0)
		r.crop_yield = maxf(0.0, (r.rainfall - 1000.0) * 0.3 - maxf(0.0, r.temperature - 25.0) * 4.0)
		r.internet_speed = RNG.randf_range(5.0, 150.0)
		r.tax_rate = RNG.randf_range(8.0, 28.0)
		r.gdp = r.population * RNG.randf_range(300.0, 1200.0) # monthly proxy
		r.happiness = RNG.randf_range(45.0, 80.0)
		r.stability = RNG.randf_range(40.0, 90.0)
		r.culture_index = RNG.randf_range(10.0, 90.0)
		World.regions.append(r)
