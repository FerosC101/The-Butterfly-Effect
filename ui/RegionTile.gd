extends Button
class_name RegionTile

var region: RegionData

func setup(r: RegionData) -> void:
	region = r
	text = r.name
	refresh()

func refresh() -> void:
	var t := clamp(region.happiness / 100.0, 0.0, 1.0)
	modulate = Color(1.0 - t, t, 0.3) # red→green
