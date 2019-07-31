extends Node

export var mass : float
export var damper : float
export var charge : float

onready var par = get_parent()
var v1 := Vector2()
var v2 := Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
    pass # Replace with function body.

func update(delta):
    var force = par.calc_force()
    # predict
    v2 += (force / mass) * delta
    var ptn = calc_path_point_count(v1, v2)
    var dt = delta / ptn
    v2 = v1
    for i in range(ptn):
        v2 += (force / mass) * dt
        par.position += (v2 + v1) * dt * 0.5
        get_node("../Trail").add_timept(par.position, dt)
        force = par.calc_force()
        v1 = v2
        
static func line_cirle_collision(center:Vector2, r:float, p1:Vector2, p2:Vector2) -> bool:
    if (p2-p1).length() < 100:
        return (p1-center).length() < r
    
    if p1 == p2:
        return false
    
    var A = p1.y - p2.y
    var B = p2.x - p1.x
    var C = p1.x * p2.y - p2.x * p1.y
    var d = abs(A * center.x + B * center.y + C) / sqrt(A * A + B * B)
    #print(A, " ", B, " ", C, " ", center, " ", r, " ", p1, " ", p2, " ", d)
    return d <= r
        
static func calc_path_point_count(v1, v2) -> int: # in [1,inf)
    var k = 0.002
    var th1 = cartesian2polar(v1.x, v1.y)
    var th2 = cartesian2polar(v2.x, v2.y)
    
    var a = abs(th1.y - th2.y)
    a = a if a <= 180 else 2 * PI - a
    
    var point_density = (th1.x + th2.x) * a
    return int(point_density * k) + 1
