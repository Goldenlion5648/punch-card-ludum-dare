@tool
extends VBoxContainer
class_name SingleSectionContainer

var cur_file_name = "":
    set(val):
        cur_file_name = val
        file_name_label.text = "[b]%s[/b]" % val
        
const SINGLE_QUICK_OPEN_RESULT = preload("uid://csowm63k0r6dc")
@onready var file_name_label: RichTextLabel = $file_name_label

func get_contained_matches_count():
    return get_child_count() - 1
    
func get_match_0_indexed(index):
    return get_child(index + 1)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func set_file(new_file_name):
    cur_file_name = new_file_name
    
func add_match(res):
    var new_match_in_current_file = SINGLE_QUICK_OPEN_RESULT.instantiate() as SingleQuickOpenResult
    add_child(new_match_in_current_file)
    new_match_in_current_file.setup(res)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
