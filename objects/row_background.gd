extends ColorRect
class_name RowBackground

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func show_as_selected_row():
    color.a8 = 99

func show_as_unselected_row():
    color.a8 = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
