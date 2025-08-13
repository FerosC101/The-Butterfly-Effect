extends Control
class_name ChartControl

var data: PackedFloat32Array = []
var y_min := 0.0
var y_max := 100.0

func set_series(arr: Array) -> void:
	data = PackedFloat32Array(arr)
	if data.size() > 0:
		y_min = minf(data.min(), y_min)
		y_max = maxf(data.max(), y_max)
	queue_redraw()

func _draw() -> void:
	if data.size() < 2: return
	var w := size.x
	var h := size.y
	var pts := PackedVector2Array()
	for i in data.size():
		var x := lerp(0.0, w, float(i) / float(data.size() - 1))
		var y := h - lerp(0.0, h, (data[i] - y_min) / max(0.0001, y_max - y_min))
		pts.append(Vector2(x, y))
	draw_polyline(pts, Color.WHITE, 2.0)
	draw_rect(Rect2(Vector2.ZERO, size), Color(1,1,1,0.1), false, 1.0)
