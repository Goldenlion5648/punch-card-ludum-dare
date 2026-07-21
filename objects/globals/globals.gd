extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func remove_all_children_of(parent: Node):
    for child in parent.get_children():
        parent.remove_child(child)
        child.queue_free()

func remove_and_queue_free(to_remove: Node):
    to_remove.get_parent().remove_child(to_remove)
    to_remove.queue_free()

func get_random_color():
    return Color(randf(), randf(), randf())
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
