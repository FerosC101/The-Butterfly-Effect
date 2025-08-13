extends Node

signal event(text: String)

func push(t: String) -> void:
		emit_signal("event", t)
	
