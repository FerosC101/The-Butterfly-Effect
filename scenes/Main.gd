extends Control

@onready var lbl_time: Label = $HUD/TopBar/HBoxContainer/WorldTime
@onready var dib_value: Label = $HUD/TopBar/HBoxContainer/DIBPanel/DIBValue
@onready var actions_box: VBoxContainer = $HUD/HSplitContainer/LeftPanel/ActionsVBox
@onready var map_grid: GridContainer = $HUD/HSplitContainer/RightPanel/MapView/Grid
@onready var chart: ChartControl = $HUD/HSplitContainer/RightPanel/ChartsDock/Chart
@onready var event_feed: RichTextLabel = $HUD/HSplitContainer/RightPanel/EventFeed

var selected: RegionData = null
var dib: int = 5
var tiles: Array[RegionTile] = []

func _ready() -> void:
	# Generate world
	var gen := WorldGen.new()
	add_child(gen)
	gen.generate(12345, 36) # 6x6

	Objectives.start()

	# Build map
	map_grid.columns = 6
	for r in World.regions:
		var tile := RegionTile.new()
		tile.setup(r)
		tile.pressed.connect(func():
			selected = r
			EventBus.push("Selected %s" % r.name)
		)
		map_grid.add_child(tile)
		tiles.append(tile)

	# Actions
	_add_action_button("Rain +50mm (cost 1)", func():
		if not _check_action(1): return
		selected.rainfall = clampf(selected.rainfall + 50.0, 100.0, 3000.0)
		EventBus.push("Adjusted rainfall +50 in %s" % selected.name)
		_after_action()
	)
	_add_action_button("Set Tax 18% (cost 2)", func():
		if not _check_action(2): return
		selected.tax_rate = 18.0
		EventBus.push("Set tax to 18%% in %s" % selected.name)
		_after_action()
	)

	# Hooks
	Time.tick.connect(_on_tick)
	EventBus.event.connect(func(t): _push_event(t))

	_refresh_ui()

func _add_action_button(txt: String, cb: Callable) -> void:
	var b := Button.new()
	b.text = txt
	b.pressed.connect(cb)
	actions_box.add_child(b)

func _check_action(cost: int) -> bool:
	if selected == null:
		_push_event("Select a region first.")
		return false
	if dib < cost:
		_push_event("Not enough DIB.")
		return false
	dib -= cost
	_refresh_ui()
	return true

func _after_action() -> void:
	for t in tiles: t.refresh()
	_refresh_ui()

func _on_tick(months: float) -> void:
	lbl_time.text = "Month %.0f" % World.time_months
	Objectives.update_check()
	chart.set_series(World.history["gdp"])
	# Refill DIB every 12 months (simple rule)
	if int(World.time_months) % 12 == 0:
		dib = min(dib + 3, 10)
	_refresh_ui()

func _refresh_ui() -> void:
	dib_value.text = str(dib)

func _push_event(t: String) -> void:
	event_feed.append_text(t + "\n")
