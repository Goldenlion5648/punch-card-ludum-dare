extends VBoxContainer

const SINGLE_BUTTON_ROW = preload("uid://c7ofg6pwql4vg")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func reset_to_default():
    Globals.remove_all_children_of(self)
    var new_row = SINGLE_BUTTON_ROW.instantiate()
    add_child(new_row)
    

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
