extends CanvasLayer
class_name ControlsOverlay

@onready var row_holder: VBoxContainer = $row_holder
@onready var button_sound: AudioStreamPlayer2D = $audio_holder/button_sound
const SINGLE_BUTTON_ROW = preload("uid://c7ofg6pwql4vg")
@onready var add_row_button: Button = %add_row_button
@onready var remove_row_button: Button = %remove_row_button
const ROW_BACKGROUND = preload("uid://fscb7kg4pr5t")

var row_targeted = 0:
    set(val):
        row_targeted = val
        update_row_background_colors()
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
    for child: SingleRow in row_holder.get_children():
        child.mouse_hovered.connect(func(index):
            row_targeted = index)

func reset_holder():
    row_holder.reset_to_default()

func get_pattern():
    var ret = []
    for child in row_holder.get_children():
        ret.append([])
        for button in child.get_elements():
            if button is CheckButton:
                ret[-1].append(int(button.button_pressed))
            pass
    return ret

func _on_remove_row_button_pressed() -> void:
    if row_holder.get_child_count() <= 1:
        return
    print("row_targeted", row_targeted)
    var to_remove = row_holder.get_child(row_targeted)
    row_holder.remove_child(to_remove)
    to_remove.queue_free()
    row_targeted = row_holder.get_child_count() - 1
    
func _on_add_row_button_pressed() -> void:
    if row_holder.get_child_count() >= 4:
#        TODO: play deny sound
        return
    var new_row = SINGLE_BUTTON_ROW.instantiate() as SingleRow
    row_holder.add_child(new_row)
    row_targeted = row_holder.get_child_count() - 1

func update_row_background_colors():
    for i, child: ColorRect in enumerate(row_holder.get_children()):
        if i == row_targeted:
            child.show_as_selected_row()
        else:
            child.show_as_unselected_row()
            
    #add_row_button.reparent(new_row, false)
func game_end():
    row_holder.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if not row_holder.visible:
        return
    for i in range(Globals.column_count):
        if Input.is_action_just_pressed("punch" + str(i)):
            var cur_button = (row_holder.get_child(row_targeted).get_child(0).get_child(i) as CheckButton)
            cur_button.button_pressed = not cur_button.button_pressed
            
    if Input.is_action_just_pressed("down_one_row"):
        row_targeted += 1
        row_targeted = min(row_targeted, row_holder.get_child_count() - 1)
    if Input.is_action_just_pressed("up_one_row"):
        row_targeted -= 1
        row_targeted = max(row_targeted, 0)
    update_row_background_colors()
    if Input.is_action_just_pressed("add_new_row"):
        add_row_button.pressed.emit()
    if Input.is_action_just_pressed("remove_row"):
        remove_row_button.pressed.emit()
    



