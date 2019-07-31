extends Node2D

export var radius : float = 6

export var mass : float = 1
export var damper : float = 1
export var charge : float = 2000

export var velocity_init : float = 1300
export var velocity_init_rand_var : float = 300
export var position_init_dist_ratio : float = 1.1
export var position_max_dist_ratio : float = 2

var screen_size
var screen_diagonal

var tar : Node2D
var fillers_ref := Array()
#var force := Vector2()
#var v2 := Vector2()


var will_reset := false

var position_prev : Vector2

onready var phy = $PointPhysics

#var v1
#var prev_delta = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
    screen_size = get_viewport_rect().size
    screen_diagonal = screen_size.length()
    tar = get_parent().get_node("Ion")
    position_prev = position
    #v1 = v2
    $Trail.width = radius * 2
    phy.charge = charge
    phy.damper = damper
    phy.mass = mass
    randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if will_reset:
        reset_pos()
        will_reset = false
        return
    
    
    $PointPhysics.update(delta)
#    force = calc_force()
#    # predict
#    v2 += (force / mass) * delta
#    var ptn = calc_path_point_count(v1, v2)
#    var dt = delta / ptn
#    v2 = v1
#    for i in range(ptn):
#        v2 += (force / mass) * dt
#        position += (v2 + v1) * dt * 0.5
#        $Trail.add_timept(position, dt)
#        force = calc_force()
#        v1 = v2
    
    
    #if dist.length() < radius + tar.radius:
    if line_cirle_collision(tar.position, 
            radius + tar.radius, position, position_prev):
        print("hit...", self)
        #reset_pos()
        will_reset = true
        tar.being_hit(charge, mass)
    else:
        will_reset = false
        
    position_prev = position
    
func calc_force() -> Vector2:
    var dist = position - tar.position
    
    if dist.length() > screen_diagonal * position_max_dist_ratio:
        reset_pos()
        
    var force = dist.normalized() * phy.charge * tar.charge / dist.length_squared()
    
    for f in fillers_ref:
        if f != self:
            var dist_f = position - f.position
            force += -dist_f.normalized() * phy.charge * phy.charge / dist_f.length_squared()
        
    force -= phy.v2 * phy.damper
    
    return force
    
func reset_pos():
    position = tar.position + polar2cartesian(
            screen_diagonal * position_init_dist_ratio, rand_range(0, 2 * PI))
    position_prev = position
    phy.v2 = (tar.position - position).normalized() * velocity_init
    phy.v2.x += rand_range(-velocity_init_rand_var, velocity_init_rand_var)
    phy.v2.y += rand_range(-velocity_init_rand_var, velocity_init_rand_var)
    print("reset ", self)
    
    $Trail.erase_all()
    
#func get_frame_tail(delta, ptn) -> PoolVector2Array:
#    var arr = PoolVector2Array()
#    if ptn <= 0:
#        return arr
#    var dt = delta / ptn
#    var a = force / mass
#    for i in range(ptn):
#        var pos = position_prev + v1 * (dt * i) + 0.5 * a * pow((dt * i), 2)
#        arr.append(pos)
#    return arr
    
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
    
        

