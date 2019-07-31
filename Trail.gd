# Time-based Trail System

extends Line2D

#var root = get_tree().get_root()
export var life_max := 0.2
var deltas := PoolRealArray()
var life := 0.0

#func _ready():
#    pass
    
func add_timept(pos: Vector2, delta):
    add_point(pos)
    #points.append(pos)
    deltas.append(delta)
    life += delta
    
func erase_exceeded():
    while life > life_max:
        life -= deltas[0]
        remove_point(0)
        deltas.remove(0)
        
func erase_all():
    clear_points()
    deltas.resize(0)
    life = 0.0
        
func _process(delta):
    position = -(get_parent().position)
    erase_exceeded()
