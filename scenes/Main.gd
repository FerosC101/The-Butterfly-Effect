extends Control
class_name Main

# === Preloads / Types ===
const RegionData = preload("res://scripts/sim/RegionData.gd")

# === UI Nodes ===
@onready var lbl_time: Label = $HUD/TopBar/HBoxContainer/WorldTime
@onready var lbl_dib: Label = $HUD/TopBar/HBoxContainer/DIBPanel/DIBValue
@onready var btn_rain: Button = $HUD/HSplitContainer/LeftPanel/ActionsVbox/BtnRain
@onready var btn_tax: Button = $HUD/HSplitContainer/LeftPanel/ActionsVbox/BtnTax
@onready var grid: GridContainer = $HUD/HSplitContainer/RightPanel/MapView/GridContainer
@onready var event_feed: RichTextLabel = $HUD/HSplitContainer/RightPanel/EventsFeed

# === Simulation Variables ===
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var regions: Array[RegionData] = []
var time_months: float = 0.0
var sim_accum: float = 0.0
var SIM_STEP: float = 1.0 # months per logical sim step
var dib: int = 5
var selected_idx: int = -1

# === READY ===
func _ready() -> void:
	rng.randomize()
	generate_world(rng.randi(), 36)
	build_map()
	_update_ui()
	btn_rain.pressed.connect(_on_btn_rain_pressed)
	btn_tax.pressed.connect(_on_btn_tax_pressed)

# === WORLD GENERATION ===
func generate_world(seed: int, count: int = 36) -> void:
	rng.seed = seed
	regions.clear()

	for i in range(count):
		var r: RegionData = RegionData.new()
		r.id = i
		r.name = "R%02d" % i
		r.population = rng.randf_range(50_000, 2_000_000)
		r.temperature = rng.randf_range(5.0, 32.0)
		r.rainfall = clamp(rng.randf_range(800.0, 2000.0), 200.0, 3000.0)  # random rainfall instead of FastNoise
		r.crop_yield = max(0.0, (r.rainfall - 1000.0) * 0.3 - max(0.0, r.temperature - 25.0) * 4.0)
		r.internet_speed = rng.randf_range(5.0, 150.0)
		r.tax_rate = rng.randf_range(8.0, 28.0)
		r.gdp = r.population * rng.randf_range(300.0, 1200.0)
		r.happiness = rng.randf_range(45.0, 80.0)
		r.stability = rng.randf_range(40.0, 90.0)
		r.culture_index = rng.randf_range(10.0, 90.0)
		regions.append(r)

# === BUILD UI MAP ===
func build_map() -> void:
	if grid == null:
		push_error("GridContainer node not found!")
		return
	
	# Clear previous buttons safely
	for child in grid.get_children():
		child.queue_free()
	
	grid.columns = 6
	
	for i in range(regions.size()):
		var r: RegionData = regions[i]
		var btn: Button = Button.new()
		
		btn.name = "RegionBtn_%d" % i
		btn.text = r.name
		btn.set_meta("region_idx", i)
		
		# Godot 4 proper way to set button minimum size
		btn.custom_minimum_size = Vector2(100, 100)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		refresh_region_button(btn, r)
		btn.pressed.connect(func(b = btn): _on_region_pressed(b))
		grid.add_child(btn)

func refresh_region_button(btn: Button, r: RegionData) -> void:
	var t: float = clamp(r.happiness / 100.0, 0.0, 1.0)
	var col: Color = Color(1.0 - t, t, 0.2)
	btn.modulate = col

func refresh_all_buttons() -> void:
	if grid == null:
		return
	for child in grid.get_children():
		var idx: int = child.get_meta("region_idx")
		if typeof(idx) == TYPE_INT and idx >= 0 and idx < regions.size():
			refresh_region_button(child, regions[idx])

# === UI CALLBACKS ===
func _on_region_pressed(btn: Button) -> void:
	selected_idx = btn.get_meta("region_idx")
	if selected_idx < 0 or selected_idx >= regions.size():
		return
	var r: RegionData = regions[selected_idx]
	if event_feed:
		event_feed.append_text("Selected %s\n" % r.name)
	_update_ui()

func _on_btn_rain_pressed() -> void:
	if selected_idx < 0 or selected_idx >= regions.size():
		if event_feed:
			event_feed.append_text("Select a region first\n")
		return
	if dib < 1:
		if event_feed:
			event_feed.append_text("Not enough DIB\n")
		return
	regions[selected_idx].rainfall = clamp(regions[selected_idx].rainfall + 50.0, 100.0, 3000.0)
	dib -= 1
	if event_feed:
		event_feed.append_text("Added +50 rainfall to %s\n" % regions[selected_idx].name)
	refresh_all_buttons()
	_update_ui()

func _on_btn_tax_pressed() -> void:
	if selected_idx < 0 or selected_idx >= regions.size():
		if event_feed:
			event_feed.append_text("Select a region first\n")
		return
	if dib < 2:
		if event_feed:
			event_feed.append_text("Not enough DIB\n")
		return
	regions[selected_idx].tax_rate = 18.0
	dib -= 2
	if event_feed:
		event_feed.append_text("Set tax 18%% in %s\n" % regions[selected_idx].name)
	refresh_all_buttons()
	_update_ui()

# === SIMULATION LOOP ===
func _process(delta: float) -> void:
	sim_accum += delta
	if sim_accum >= 0.25:
		sim_accum = 0.0
		step_sim(SIM_STEP)
		_update_ui()

func step_sim(months: float) -> void:
	time_months += months
	for r in regions:
		var season: float = sin(time_months / 12.0 * TAU)
		r.rainfall = clamp(r.rainfall + season * 2.0, 100.0, 3000.0)
		r.crop_yield = max(
			0.0,
			r.crop_yield + 0.1 * (r.rainfall - 1200.0) * (months / 12.0) - max(0.0, r.temperature - 25.0) * 2.0 * (months / 12.0)
		)
		var g_growth: float = 0.015 * (months / 12.0) + clamp(r.crop_yield / 20000.0, -0.02, 0.02) * (months / 12.0)
		r.gdp *= (1.0 + g_growth)
		var delta_h: float = clamp(r.internet_speed / 20.0, 0.0, 5.0) - (r.tax_rate - 15.0) * 0.2
		r.happiness = clamp(r.happiness + delta_h * 0.02 * months, 0.0, 100.0)
		var pressure: float = clamp(50.0 - r.happiness, 0.0, 50.0)
		r.stability = clamp(r.stability - pressure * 0.01 * months, 0.0, 100.0)

	if rng.randf() < 0.01 and regions.size() > 0:
		var idx: int = int(rng.randi() % regions.size())
		regions[idx].culture_index = clamp(regions[idx].culture_index + rng.randf_range(5.0, 15.0), 0.0, 100.0)
		if event_feed:
			event_feed.append_text("[Event] Cultural wave in %s\n" % regions[idx].name)

	if int(time_months) % 12 == 0:
		dib = min(dib + 3, 10)

# === UI UPDATE ===
func _update_ui() -> void:
	if lbl_time:
		lbl_time.text = "Months: %d" % int(time_months)
	if lbl_dib:
		lbl_dib.text = "DIB: %d" % dib
