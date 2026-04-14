extends Node

## KernelHub — scena di meta-game tra le run.
## Gestisce acquisto upgrade con Frammenti di Dati.

@onready var fragments_label: Label  = %FragmentsLabel
@onready var ram_label:       Label  = %RamLabel
@onready var cpu_label:       Label  = %CpuLabel
@onready var firmware_label:  Label  = %FirmwareLabel

const UPGRADE_COSTS := {
	"ram":      [100, 200, 400],
	"cpu":      [150, 300, 600],
	"firmware": [120, 250, 500],
}

func _ready() -> void:
	_refresh_ui()

func _refresh_ui() -> void:
	fragments_label.text = "Data Fragments: %d" % SystemManager.data_fragments
	ram_label.text      = "RAM Lv.%d — Slots: %d" % [SystemManager.ram_level, SystemManager.get_max_snippet_slots()]
	cpu_label.text      = "CPU Lv.%d — Cooldown: %.0f%%" % [SystemManager.cpu_level, SystemManager.get_cooldown_multiplier() * 100]
	firmware_label.text = "Firmware Lv.%d — Instability ×%.1f" % [SystemManager.firmware_level, 1.0 - SystemManager.firmware_level * 0.1]

# ---------------------------------------------------------------------------
# Upgrade handlers (collegati ai bottoni nell'editor)
# ---------------------------------------------------------------------------
func _on_UpgradeRAM_pressed() -> void:
	_try_upgrade("ram")

func _on_UpgradeCPU_pressed() -> void:
	_try_upgrade("cpu")

func _on_UpgradeFirmware_pressed() -> void:
	_try_upgrade("firmware")

func _try_upgrade(type: String) -> void:
	var level: int = SystemManager.get(type + "_level")
	var costs: Array = UPGRADE_COSTS[type]

	if level >= costs.size():
		return  # Già al massimo

	var cost: int = costs[level]
	if SystemManager.spend_fragments(cost):
		SystemManager.set(type + "_level", level + 1)
		_refresh_ui()

func _on_StartRun_pressed() -> void:
	SystemManager.start_run()
	get_tree().change_scene_to_file("res://scenes/rooms/RunScene.tscn")
