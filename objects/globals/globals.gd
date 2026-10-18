extends Node

var column_count = 4
var row_count = 8

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
    
func read_file(path):
    return FileAccess.open(path, FileAccess.READ).get_as_text()
    
func is_running_in_web():
    return OS.has_feature("webgl")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if OS.has_feature("editor"):
        if Input.is_action_just_pressed("quit"):
            get_tree().quit()
        if Input.is_action_just_pressed("reload_scene"):
            get_tree().reload_current_scene()
