extends Node
class_name RNG

var rng := RandomNumberGenerator.new()

func seed(s: int) -> void:
	rng.seed = s

func randf_range(a: float, b: float) -> float:
	return rng.randf_range(a, b)

func randi() -> int:
	return rng.randi()

func chance(p: float) -> bool:
	return rng.randf() < p
