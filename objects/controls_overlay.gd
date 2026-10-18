extends CanvasLayer
class_name ControlsOverlay

@onready var row_holder: VBoxContainer = $row_holder
@onready var button_sound: AudioStreamPlayer2D = $audio_holder/button_sound
const SINGLE_BUTTON_ROW = preload("uid://c7ofg6pwql4vg")
@onready var add_row_button: Button = %add_row_button
@onready var row_backgrounds: VBoxContainer = $row_backgrounds
const ROW_BACKGROUND = preload("uid://fscb7kg4pr5t")

var row_targeted = 0
# Called when the node enters the scene tree for the first time.
var row_count = 0:
    get:
        return row_holder.get_child_count()

func _ready() -> void:
    pass

func get_pattern():
    var ret = []
    for child in row_holder.get_children():
        ret.append([])
        for button in child.get_children():
            if button is CheckButton:
                ret[-1].append(int(button.button_pressed))
            pass
    return ret

func _on_add_row_button_pressed() -> void:
    if row_holder.get_child_count() >= 4:
#        TODO: play deny sound
        return
    var new_row = SINGLE_BUTTON_ROW.instantiate() as HBoxContainer
    row_holder.add_child(new_row)
    var new_color_background = ROW_BACKGROUND.instantiate()
    row_backgrounds.add_child(new_color_background)
    row_targeted = row_backgrounds.get_child_count() - 1
    update_row_background_colors()

func update_row_background_colors():
    for i, child: RowBackground in enumerate(row_backgrounds.get_children()):
        if i == row_targeted:
            child.show_as_selected_row()
        else:
            child.show_as_unselected_row()
            
    #add_row_button.reparent(new_row, false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    for i in range(Globals.column_count):
        if Input.is_action_just_pressed("punch" + str(i)):
            var cur_button = (row_holder.get_child(row_targeted).get_child(i) as CheckButton)
            cur_button.button_pressed = not cur_button.button_pressed
            button_sound.play()
    if Input.is_action_just_pressed("down_one_row"):
        row_targeted += 1
    if Input.is_action_just_pressed("up_one_row"):
        row_targeted -= 1
    row_targeted = clamp(row_targeted, 0, row_count - 1)
    update_row_background_colors()
    if Input.is_action_just_pressed("add_new_row"):
        add_row_button.pressed.emit()
    

