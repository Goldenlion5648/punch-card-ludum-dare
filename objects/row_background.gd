extends ColorRect
class_name SingleRow
@onready var items_holder: HBoxContainer = $items_holder

signal mouse_hovered(index)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    mouse_entered.connect(func():
        mouse_hovered.emit(get_index())         
        print("mouse"))

func add_element(new):
    items_holder.add_child(new)

func get_elements():
    return items_holder.get_children()

func show_as_selected_row():
    color.a8 = 99

func show_as_unselected_row():
    color.a8 = 0

func _input(event: InputEvent) -> void:
    if event is InputEventMouseMotion:
        if get_rect().has_point(get_global_mouse_position()):
            mouse_hovered.emit(get_index()) 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
