extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var color_init = Color(0xff666699)
var color = color_init
var color_core_init = Color(0xff6666ff)
var color_core = color_core_init

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.
    
func _draw():
    draw_circle(Vector2(0,0), get_parent().radius, color)
    draw_circle(Vector2(0,0), get_parent().radius_core, color_core)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    pass
