extends CanvasLayer

## Terminal UI — interfaccia di manipolazione Snippet in slow-motion.

signal terminal_closed
signal snippet_equipped(snippet: BaseSnippet)
signal snippet_unequipped(snippet: BaseSnippet)

@onready var snippet_list:     ItemList   = %SnippetList
@onready var equipped_list:    ItemList   = %EquippedList
@onready var desc_label:       Label      = %DescLabel
@onready var instability_bar:  ProgressBar = %InstabilityBar
@onready var container:        Control    = %Container

var _available_snippets: Array[BaseSnippet] = []
var _player: Node2D = null

func _ready() -> void:
	container.hide()
	SystemManager.instability_changed.connect(_on_instability_changed)

# ---------------------------------------------------------------------------
# Apri / Chiudi
# ---------------------------------------------------------------------------
func open() -> void:
	_refresh_lists()
	container.show()

func close() -> void:
	container.hide()
	Engine.time_scale = 1.0
	emit_signal("terminal_closed")

func _input(event: InputEvent) -> void:
	if container.visible and event.is_action_pressed("ui_cancel"):
		close()

# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------
func _refresh_lists() -> void:
	snippet_list.clear()
	equipped_list.clear()

	for s in _available_snippets:
		snippet_list.add_item(s.snippet_name)

	for s in SystemManager.equipped_snippets:
		equipped_list.add_item(s.snippet_name)

func _on_SnippetList_item_selected(index: int) -> void:
	var s: BaseSnippet = _available_snippets[index]
	desc_label.text = "%s\nInstability cost: %.1f\n\n%s" % [s.snippet_name, s.instability_cost, s.description]

func _on_EquipButton_pressed() -> void:
	var idx := snippet_list.get_selected_items()
	if idx.is_empty():
		return
	var s: BaseSnippet = _available_snippets[idx[0]]

	if SystemManager.equipped_snippets.size() >= SystemManager.get_max_snippet_slots():
		desc_label.text = "RAM piena! Rimuovi uno Snippet prima."
		return

	SystemManager.equipped_snippets.append(s)
	if _player:
		s.equip(_player)
	emit_signal("snippet_equipped", s)
	_refresh_lists()

func _on_UnequipButton_pressed() -> void:
	var idx := equipped_list.get_selected_items()
	if idx.is_empty():
		return
	var s: BaseSnippet = SystemManager.equipped_snippets[idx[0]]
	SystemManager.equipped_snippets.erase(s)
	s.unequip()
	emit_signal("snippet_unequipped", s)
	_refresh_lists()

func _on_instability_changed(value: float) -> void:
	instability_bar.value = value

# ---------------------------------------------------------------------------
# Setup
# ---------------------------------------------------------------------------
func set_player(player: Node2D) -> void:
	_player = player

func set_available_snippets(snippets: Array[BaseSnippet]) -> void:
	_available_snippets = snippets
	_refresh_lists()
