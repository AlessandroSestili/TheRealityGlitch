extends CharacterBody2D
class_name BaseEnemy

## Nemico base. Sovrascrivere _think() per comportamenti diversi.

signal died(enemy: Node2D, position: Vector2)

@export var max_hp    := 50.0
@export var speed     := 80.0
@export var damage    := 10.0
@export var xp_value  := 1   # Frammenti di dati rilasciati

var hp := max_hp
var _player: Node2D = null

func _ready() -> void:
	SystemManager.instability_changed.connect(_on_instability_changed)
	add_to_group("enemy")
	_player = get_tree().get_first_node_in_group("player")
	var shape := Polygon2D.new()
	shape.polygon = PackedVector2Array([Vector2(-10, -11), Vector2(10, -11), Vector2(10, 11), Vector2(-10, 11)])
	shape.color = Color(0.85, 0.2, 0.2, 1)
	add_child(shape)

func _physics_process(delta: float) -> void:
	_think(delta)
	move_and_slide()

# ---------------------------------------------------------------------------
# Virtuale — logica AI
# ---------------------------------------------------------------------------
func _think(_delta: float) -> void:
	if _player == null:
		return
	var dir := (_player.global_position - global_position).normalized()
	velocity = dir * speed

# ---------------------------------------------------------------------------
# Danno
# ---------------------------------------------------------------------------
func take_damage(amount: float) -> void:
	hp -= amount
	if hp <= 0:
		_die()

func _die() -> void:
	SystemManager.add_fragments(xp_value)
	SnippetBus.emit_enemy_killed(self, global_position)
	emit_signal("died", self, global_position)
	queue_free()

# ---------------------------------------------------------------------------
# Reazione all'Instabilità (cambia comportamento a soglie)
# ---------------------------------------------------------------------------
func _on_instability_changed(value: float) -> void:
	if value >= 50.0:
		speed = (max_hp / hp) * 80.0 + 40.0  # Nemici più veloci con instabilità alta
	if value >= 75.0:
		_teleport_near_player()

func _teleport_near_player() -> void:
	if _player == null or randf() > 0.005:  # Bassa probabilità per frame
		return
	var offset := Vector2(randf_range(-80, 80), randf_range(-80, 80))
	global_position = _player.global_position + offset
