extends Button
# Removed class_name to avoid potential autoload/type conflicts
# If you want class_name, you can keep it as long as it does not conflict with autoloads

# Preload the RegionData resource type
const RegionData = preload("res://scripts/sim/RegionData.gd")

var region: RegionData = null  # explicitly typed and initialized

func setup(r: RegionData) -> void:
	region = r
	text = r.name
	refresh()

func refresh() -> void:
	if region == null:
		return
	var t: float = clamp(region.happiness / 100.0, 0.0, 1.0)
	modulate = Color(1.0 - t, t, 0.3) # red→green
