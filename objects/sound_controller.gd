extends Node2D

@onready var playing_sounds_holder: Node2D = $playing_sounds_holder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    playing_sounds_holder.child_entered_tree.connect(func(_x): remove_oldest_sound())
    
func remove_oldest_sound():
    if playing_sounds_holder.get_child_count() > 5:
        Globals.remove_and_queue_free(playing_sounds_holder.get_child(0))

func dupe_and_play(some_sound : AudioStreamPlayer2D):
    var new_sound = some_sound.duplicate()
    playing_sounds_holder.add_child(new_sound)
    new_sound.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass        
    
