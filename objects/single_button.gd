extends CheckButton

@onready var button_sound: AudioStreamPlayer2D = $button_sound

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    toggled.connect(func(_x):
        button_sound.play()
    )



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
