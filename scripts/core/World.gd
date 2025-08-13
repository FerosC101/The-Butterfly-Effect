extends Node
class_name World

var time_months: float = 0.0
var regions: Array[RegionData] = []
var history := {
	"gdp": [],
	"happiness": []
}

func reset() -> void:
	time_months = 0.0
	regions.clear()
	history = {"gdp": [], "happiness": []}

func step(months: float) -> void:
	time_months += months
	EnvironmentSystem.process(self, months)
	EconomySystem.process(self, months)
	SocietySystem.process(self, months)
	PoliticsSystem.process(self, months)
	EventsSystem.process(self, months)
	_record_history()

func _record_history() -> void:
	history["gdp"].append(_sum_gdp())
	history["happiness"].append(_avg_happiness())

func _sum_gdp() -> float:
	var s := 0.0
	for r in regions: s += r.gdp
	return s

func _avg_happiness() -> float:
	var s := 0.0
	for r in regions: s += r.happiness
	return s / max(1, regions.size())
