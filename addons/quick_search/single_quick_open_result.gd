@tool
extends RichTextLabel
class_name SingleQuickOpenResult

@onready var color_rect: ColorRect = $ColorRect

var is_selected = false:
    set(val):
        is_selected = val
        if is_selected:
            color_rect.color = Color(0.301960796117783,
                                    0.576470613479614,
                                    0.937254905700684,
                                    0.490196079015732)
        else:
            color_rect.color.a = 0


var linked_path
var linked_line_num
var linked_start_col

# Called when the node enters the scene tree for the first time.X
func _ready() -> void:
    is_selected = false

func setup(res):
    var file_name = res[0]
    var line_num = res[1]
    var line_content = res[2]
    var col = res[3]
    var string_to_find = res[4]
    var trimmed_start = max(0, col - 20)
    var trimmed_end = col + 40
    var trimmed_line_content = line_content.substr(trimmed_start, trimmed_end - trimmed_start).replace("[", "[lb]")
    var trimmed_col = col - trimmed_start
    text = "\t\t%s[u][b]%s[/b][/u]%s" % [
        trimmed_line_content.substr(0, trimmed_col),
        trimmed_line_content.substr(trimmed_col, len(string_to_find)),
        trimmed_line_content.substr(trimmed_col + len(string_to_find)),
    ]
    is_selected = false
    linked_path = file_name
    linked_line_num = line_num
    linked_start_col = col

func open_linked_script():
    if ResourceLoader.exists(linked_path):
        var res: Resource = load(linked_path)
        EditorInterface.edit_script(res, linked_line_num, linked_start_col + 1)
    
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
