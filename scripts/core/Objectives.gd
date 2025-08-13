extends Node

signal completed(desc: String)
signal failed(desc: String)

var active := {
	"desc": "Double total GDP in 10 years while keeping avg happiness ≥ 70.",
	"deadline_months": 120.0,
	"start_gdp": 0.0,
	"min_happy": 70.0
}

func start() -> void:
	active.start_gdp = World._sum_gdp()

func update_check() -> void:
	if World.time_months >= active.deadline_months:
		var ok_gdp: bool = World._sum_gdp() >= active.start_gdp * 2.0
		var ok_happy: bool = World._avg_happiness() >= float(active.min_happy)
		
		if ok_gdp and ok_happy:
			emit_signal("completed", active.desc)
			EventBus.push("[Objective] Completed.")
		else:
			emit_signal("failed", active.desc)
			EventBus.push("[Objective] Failed.")
