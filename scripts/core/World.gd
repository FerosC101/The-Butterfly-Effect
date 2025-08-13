extends Node

# Update these preload paths to match your actual folder structure.
# You can either create these folders or put the files in your current folder and adjust paths.
const RegionData = preload("res://scripts/sim/RegionData.gd")
const EnvironmentSystemScript = preload("res://scripts/systems/economy_system.gd")
const EconomySystemScript = preload("res://scripts/systems/economy_system.gd")
const SocietySystemScript = preload("res://scripts/systems/society_system.gd")
const PoliticsSystemScript = preload("res://scripts/systems/politics_system.gd")
const EventsSystemScript = preload("res://scripts/systems/events_system.gd")

var time_months: float = 0.0
var regions: Array = []
var history: Dictionary = {
	"gdp": [],
	"happiness": []
}
var events: Array = []

# system instances (explicit typing as Node to avoid null-type errors)
var _env_system: Node = null
var _econ_system: Node = null
var _soc_system: Node = null
var _pol_system: Node = null
var _evt_system: Node = null

func _ready() -> void:
	_env_system = EnvironmentSystemScript.new()
	_econ_system = EconomySystemScript.new()
	_soc_system = SocietySystemScript.new()
	_pol_system = PoliticsSystemScript.new()
	_evt_system = EventsSystemScript.new()

func reset() -> void:
	time_months = 0.0
	regions.clear()
	history = {"gdp": [], "happiness": []}
	events.clear()

func step(months: float) -> void:
	time_months += months
	if _env_system: _env_system.process(self, months)
	if _econ_system: _econ_system.process(self, months)
	if _soc_system: _soc_system.process(self, months)
	if _pol_system: _pol_system.process(self, months)
	if _evt_system: _evt_system.process(self, months)
	_record_history()

func _record_history() -> void:
	history["gdp"].append(_sum_gdp())
	history["happiness"].append(_avg_happiness())

func _sum_gdp() -> float:
	var s: float = 0.0
	for r in regions:
		s += r.gdp
	return s

func _avg_happiness() -> float:
	if regions.is_empty():
		return 0.0
	var s: float = 0.0
	for r in regions:
		s += r.happiness
	return s / float(max(1, regions.size()))

func push_event(text: String) -> void:
	events.append(text)
	if events.size() > 200:
		events.remove_at(0)

func create_region_from_seed(idx: int, rng: RandomNumberGenerator, noise: FastNoiseLite) -> Resource:
	var r = RegionData.new()
	r.id = idx
	r.name = "R%02d" % idx
	r.population = rng.randf_range(50000.0, 2000000.0)
	r.temperature = rng.randf_range(5.0, 32.0)
	r.rainfall = clamp(1200.0 + noise.get_noise_1d(idx) * 400.0, 200.0, 3000.0)
	r.crop_yield = max(0.0, (r.rainfall - 1000.0) * 0.3 - max(0.0, r.temperature - 25.0) * 4.0)
	r.internet_speed = rng.randf_range(5.0, 150.0)
	r.tax_rate = rng.randf_range(8.0, 28.0)
	r.gdp = r.population * rng.randf_range(300.0, 1200.0)
	r.happiness = rng.randf_range(45.0, 80.0)
	r.stability = rng.randf_range(40.0, 90.0)
	r.culture_index = rng.randf_range(10.0, 90.0)
	return r

func generate_seeded_world(seed: int = 12345, count: int = 36) -> void:
	var rng = RandomNumberGenerator.new()
	rng.seed = seed
	var noise := FastNoiseLite.new()
	noise.seed = seed
	noise.frequency = 0.0625

	regions.clear()
	for i in range(count):
		var reg = create_region_from_seed(i, rng, noise)
		regions.append(reg)
