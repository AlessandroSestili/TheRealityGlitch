extends Resource
class_name BaseSnippet

## Classe base per tutti gli Snippet (Pattern Strategy).
## Ogni Snippet concreto sovrascrive i metodi virtuali e si collega
## ai segnali di SnippetBus per iniettare comportamento.

@export var snippet_name: String = "Unnamed Snippet"
@export var description:  String = ""
@export var instability_cost: float = 5.0  # aggiunto all'instabilità quando attivato

var _owner_node: Node2D = null

# Chiamato quando lo Snippet viene equipaggiato dal Player
func equip(owner_node: Node2D) -> void:
	_owner_node = owner_node
	_connect_signals()

# Chiamato quando viene de-equipaggiato
func unequip() -> void:
	_disconnect_signals()
	_owner_node = null

# ---------------------------------------------------------------------------
# Virtuali — sovrascrivere nei Snippet concreti
# ---------------------------------------------------------------------------

func _connect_signals() -> void:
	pass

func _disconnect_signals() -> void:
	pass
