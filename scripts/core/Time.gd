extends Node
class_name Time

signal tick(months: float)

var paused := false
var speed := 1.0
var _accum := 0.0
const STEP := 0.25  # months per sim step

func _process(delta: float) -> void:
	if paused: return
	_accum += delta * speed
	while _accum >= 0.03:
		_accum -= 0.03
		World.step(STEP)
		emit_signal("tick", STEP)
