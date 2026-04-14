extends Node

## Gestisce lo stato globale del sistema: Instabilità, valute e sessione di run.

signal instability_changed(new_value: float)
signal kernel_panic_threshold_reached(threshold: int)
signal run_ended(success: bool)

# --- Instabilità ---
const MAX_INSTABILITY := 100.0
const THRESHOLDS := [25, 50, 75, 100]

var instability := 0.0 : set = _set_instability
var _last_threshold_triggered := 0

# --- Valuta meta-game ---
var data_fragments := 0

# --- Upgrade Hub (persistenti tra run) ---
var ram_level := 0       # slot snippet equipaggiabili
var cpu_level := 0       # riduce cooldown abilità attive
var firmware_level := 0  # riduce velocità crescita instabilità

# --- Stato run corrente ---
var current_run_depth := 0
var equipped_snippets: Array[Resource] = []

func _ready() -> void:
	_load_persistent_data()

# ---------------------------------------------------------------------------
# Instabilità
# ---------------------------------------------------------------------------

func _set_instability(value: float) -> void:
	instability = clampf(value, 0.0, MAX_INSTABILITY)
	emit_signal("instability_changed", instability)
	_check_thresholds()
	if instability >= MAX_INSTABILITY:
		emit_signal("kernel_panic_threshold_reached", 100)

func add_instability(amount: float) -> void:
	var modifier := 1.0 - (firmware_level * 0.1)
	instability += amount * modifier

func reduce_instability(amount: float) -> void:
	instability -= amount

func _check_thresholds() -> void:
	for t in THRESHOLDS:
		if instability >= t and _last_threshold_triggered < t:
			_last_threshold_triggered = t
			emit_signal("kernel_panic_threshold_reached", t)

func reset_instability() -> void:
	instability = 0.0
	_last_threshold_triggered = 0

# ---------------------------------------------------------------------------
# Upgrade (meta-game)
# ---------------------------------------------------------------------------

func get_max_snippet_slots() -> int:
	return 3 + ram_level

func get_cooldown_multiplier() -> float:
	return 1.0 - (cpu_level * 0.1)

# ---------------------------------------------------------------------------
# Valuta
# ---------------------------------------------------------------------------

func add_fragments(amount: int) -> void:
	data_fragments += amount

func spend_fragments(amount: int) -> bool:
	if data_fragments >= amount:
		data_fragments -= amount
		return true
	return false

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------

func start_run() -> void:
	reset_instability()
	current_run_depth = 0
	equipped_snippets.clear()

func end_run(success: bool) -> void:
	emit_signal("run_ended", success)
	_save_persistent_data()

# ---------------------------------------------------------------------------
# Persistenza (semplice con ConfigFile)
# ---------------------------------------------------------------------------

const SAVE_PATH := "user://save.cfg"

func _save_persistent_data() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "data_fragments", data_fragments)
	cfg.set_value("upgrades", "ram", ram_level)
	cfg.set_value("upgrades", "cpu", cpu_level)
	cfg.set_value("upgrades", "firmware", firmware_level)
	cfg.save(SAVE_PATH)

func _load_persistent_data() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return
	data_fragments = cfg.get_value("meta", "data_fragments", 0)
	ram_level      = cfg.get_value("upgrades", "ram", 0)
	cpu_level      = cfg.get_value("upgrades", "cpu", 0)
	firmware_level = cfg.get_value("upgrades", "firmware", 0)
