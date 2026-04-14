extends BaseSnippet
class_name RicochetSnippet

## Snippet: Ricochet
## I proiettili sparati rimbalzano sulle pareti N volte.

@export var max_bounces: int = 2

func _connect_signals() -> void:
	SnippetBus.on_shoot.connect(_on_shoot)

func _disconnect_signals() -> void:
	if SnippetBus.on_shoot.is_connected(_on_shoot):
		SnippetBus.on_shoot.disconnect(_on_shoot)

func _on_shoot(player: Node2D, bullet: Node2D) -> void:
	SystemManager.add_instability(instability_cost)
	if bullet.has_method("set_bounces"):
		bullet.set_bounces(max_bounces)
