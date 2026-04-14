extends BaseSnippet
class_name FireTrailSnippet

## Snippet: Fire Trail
## Al dash, istanzia particelle di fuoco lungo il percorso.

@export var fire_particles_scene: PackedScene
@export var trail_duration: float = 0.6

func _connect_signals() -> void:
	SnippetBus.on_dash.connect(_on_dash)

func _disconnect_signals() -> void:
	if SnippetBus.on_dash.is_connected(_on_dash):
		SnippetBus.on_dash.disconnect(_on_dash)

func _on_dash(player: Node2D, direction: Vector2) -> void:
	if fire_particles_scene == null:
		return

	SystemManager.add_instability(instability_cost)

	# Spawna particelle nella posizione attuale e le lascia dissolvere
	var particles: Node2D = fire_particles_scene.instantiate()
	player.get_parent().add_child(particles)
	particles.global_position = player.global_position

	# Auto-distruzione dopo trail_duration
	var timer := player.get_tree().create_timer(trail_duration)
	timer.timeout.connect(particles.queue_free)
