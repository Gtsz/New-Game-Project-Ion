extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var res_filler := preload("res://Filler.tscn")

var screen_size : Vector2
var screen_diagonal : float

var time_scale : float = 1

func _ready():
    screen_size = get_viewport_rect().size
    screen_diagonal = screen_size.length()
    $TimerFillerSpawn.start()
    randomize()

func _process(delta):
    pass


func _on_TimerFillerSpawn_timeout():
    var filler = res_filler.instance()
    add_child(filler)
    $Ion.electrons_free.append(filler)
    filler.fillers_ref = $Ion.electrons_free
    filler.reset_pos()
    print("spawn ", filler)
    if get_child_count() > 50:
        $TimerFillerSpawn.stop()
    
func game_begin():
    $TimerFillerSpawn.start()
    
func game_end():
    $TimerFillerSpawn.stop()


func _on_Filler_hit():
    print("hit!")


func _on_Filler_area_entered(area):
    print("hitds!")
