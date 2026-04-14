extends Node
class_name RoomGenerator

## Generatore procedurale di stanze.
## Ogni "cartella" del filesystem virtuale è una scena .tscn caricata dinamicamente.

enum RoomType { COMBAT, REWARD, BOSS }

const ROOM_SCENES := {
	RoomType.COMBAT: "res://scenes/rooms/CombatRoom.tscn",
	RoomType.REWARD: "res://scenes/rooms/RewardRoom.tscn",
	RoomType.BOSS:   "res://scenes/rooms/BossRoom.tscn",
}

# Pesi di spawn per tipo di stanza (BOSS solo ogni N stanze)
const WEIGHTS := {
	RoomType.COMBAT: 70,
	RoomType.REWARD: 30,
}

const BOSS_INTERVAL := 5  # Boss ogni 5 stanze

var _current_room: Node = null
var _room_count   := 0

@onready var room_container: Node = $RoomContainer

func _ready() -> void:
	load_next_room()

# ---------------------------------------------------------------------------
# Genera prossima stanza
# ---------------------------------------------------------------------------
func load_next_room() -> void:
	if _current_room:
		_current_room.queue_free()
		_current_room = null

	_room_count += 1
	SystemManager.current_run_depth = _room_count

	var type := _pick_room_type()
	var scene_path: String = ROOM_SCENES[type]
	var packed: PackedScene = load(scene_path)
	_current_room = packed.instantiate()
	room_container.add_child(_current_room)

	SnippetBus.emit_room_entered(_room_type_to_string(type))

func _pick_room_type() -> RoomType:
	if _room_count % BOSS_INTERVAL == 0:
		return RoomType.BOSS

	var total_weight := 0
	for w in WEIGHTS.values():
		total_weight += w

	var roll := randi() % total_weight
	var cumulative := 0
	for type in WEIGHTS:
		cumulative += WEIGHTS[type]
		if roll < cumulative:
			return type

	return RoomType.COMBAT

func _room_type_to_string(type: RoomType) -> String:
	match type:
		RoomType.COMBAT: return "Combat.exe"
		RoomType.REWARD: return "Reward.zip"
		RoomType.BOSS:   return "Boss_Daemon.sh"
	return "Unknown"
