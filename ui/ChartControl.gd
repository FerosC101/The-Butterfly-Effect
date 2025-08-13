extends Control
class_name ChartControl

var data: PackedFloat32Array = PackedFloat32Array()
var y_min: float = 0.0
var y_max: float = 100.0

func set_series(arr: Array) -> void:
	# Convert Array to PackedFloat32Array
	data = PackedFloat32Array(arr)
	if data.size() > 0:
		# Compute min/max manually
		y_min = data[0]
		y_max = data[0]
		for v in data:
			if v < y_min:
				y_min = v
			if v > y_max:
				y_max = v
	queue_redraw()

func _draw() -> void:
	if data.size() < 2:
		return
	var w: float = size.x
	var h: float = size.y
	var pts: PackedVector2Array = PackedVector2Array()
	for i in range(data.size()):
		var x: float = lerp(0.0, w, float(i) / float(data.size() - 1))
		var y: float = h - lerp(0.0, h, (data[i] - y_min) / max(0.0001, y_max - y_min))
		pts.append(Vector2(x, y))
	draw_polyline(pts, Color(1,1,1), 2.0)
	draw_rect(Rect2(Vector2.ZERO, size), Color(1,1,1,0.1), false, 1.0)
