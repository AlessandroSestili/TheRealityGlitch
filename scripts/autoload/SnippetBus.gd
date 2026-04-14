extends Node

## Bus di eventi per il sistema Snippet (Pattern Observer).
## I Snippet si connettono qui per reagire a segnali del Player/Arena
## senza accoppiamento diretto.

signal on_dash(player: Node2D, direction: Vector2)
signal on_shoot(player: Node2D, bullet: Node2D)
signal on_hit_taken(player: Node2D, damage: float)
signal on_enemy_killed(enemy: Node2D, position: Vector2)
signal on_room_entered(room_type: String)

func emit_dash(player: Node2D, direction: Vector2) -> void:
	emit_signal("on_dash", player, direction)

func emit_shoot(player: Node2D, bullet: Node2D) -> void:
	emit_signal("on_shoot", player, bullet)

func emit_hit_taken(player: Node2D, damage: float) -> void:
	emit_signal("on_hit_taken", player, damage)

func emit_enemy_killed(enemy: Node2D, position: Vector2) -> void:
	emit_signal("on_enemy_killed", enemy, position)

func emit_room_entered(room_type: String) -> void:
	emit_signal("on_room_entered", room_type)
