extends Node2D
class_name CombatRoom

const ENEMY_SCENE := preload("res://scenes/enemies/BaseEnemyScene.tscn")
const ENEMY_COUNT := 3

@onready var exit_door:  Area2D = $ExitDoor
@onready var exit_label: Label  = $ExitDoor/ExitLabel

var _alive := 0

func _ready() -> void:
	exit_door.body_entered.connect(_on_exit_body_entered)
	_spawn_enemies()

func _spawn_enemies() -> void:
	var spawns := $EnemySpawns.get_children()
	spawns.shuffle()
	var count := mini(ENEMY_COUNT, spawns.size())
	for i in count:
		var e: CharacterBody2D = ENEMY_SCENE.instantiate()
		add_child(e)
		e.global_position = spawns[i].global_position
		e.died.connect(_on_enemy_died)
		_alive += 1

func _on_enemy_died(_e: Node2D, _pos: Vector2) -> void:
	_alive -= 1
	if _alive <= 0:
		exit_label.visible = true

func _on_exit_body_entered(body: Node) -> void:
	if body.is_in_group("player") and _alive <= 0:
		# room_container > RoomGenerator
		get_parent().get_parent().load_next_room()
