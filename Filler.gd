extends Node2D

export var radius : float = 6
export var mass : float = 1
export var damper : float = 1
export var charge : float = 2000

export var velocity_init : float = 1300
export var velocity_init_rand_var : float = 300
export var position_init_dist_ratio : float = 1.1
export var position_max_dist_ratio : float = 2

export var tail_line_length : int = 30

var screen_size
var screen_diagonal

var target_ref : Node2D
var fillers_ref := Array()
var force := Vector2()
var velocity := Vector2()


var will_reset := false

var prev_position
var prev_velocity
var prev_delta = 0.0
var ptn

# Called when the node enters the scene tree for the first time.
func _ready():
    screen_size = get_viewport_rect().size
    screen_diagonal = screen_size.length()
    target_ref = get_parent().get_node("Ion")
    prev_position = position
    prev_velocity = velocity
    $Line2D.width = radius * 2
    randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
    if will_reset:
        reset_pos()
        will_reset = false
        return
    
    var dist = position - target_ref.position
    if dist.length() > screen_diagonal * position_max_dist_ratio:
        reset_pos()
        
    force = dist.normalized() * charge * target_ref.charge / dist.length_squared()
    
    for f in fillers_ref:
        if f != self:
            var dist_f = position - f.position
            force += dist_f.normalized() * charge * charge / dist_f.length_squared()
        
    force -= velocity * damper
    velocity += (force / mass) * delta
    position += (velocity + prev_velocity) * delta * 0.5
    
    ptn = calc_path_point_count(prev_velocity, velocity)
    #if ptn > 0: print("ptn: ", ptn)
    var arr = get_frame_tail(prev_delta, ptn)
    #$Line2D.points.append_array(arr)
    for pt in arr:
        $Line2D.add_point(pt)
    $Line2D.position = -position
    #print(arr, $Line2D.points)
    while $Line2D.get_point_count() > tail_line_length:
        $Line2D.remove_point(0)
    
    #if dist.length() < radius + target_ref.radius:
    if line_cirle_collision(target_ref.position, 
            radius + target_ref.radius, position, prev_position):
        print("hit...", self)
        #reset_pos()
        will_reset = true
        target_ref.being_hit(charge, mass)
    else:
        will_reset = false
        
    prev_position = position
    prev_velocity = velocity
    prev_delta = delta
    
func reset_pos():
    position = target_ref.position + polar2cartesian(
            screen_diagonal * position_init_dist_ratio, rand_range(0, 2 * PI))
    prev_position = position
    velocity = (target_ref.position - position).normalized() * velocity_init
    velocity.x += rand_range(-velocity_init_rand_var, velocity_init_rand_var)
    velocity.y += rand_range(-velocity_init_rand_var, velocity_init_rand_var)
    print("reset ", self)
    
    $Line2D.clear_points()
    
func get_frame_tail(delta, ptn) -> PoolVector2Array:
    var arr = PoolVector2Array()
    if ptn <= 0:
        return arr
    var dt = delta / ptn
    var a = force / mass
    for i in range(ptn):
        var pos = prev_position + prev_velocity * (dt * i) + 0.5 * a * pow((dt * i), 2)
        arr.append(pos)
    return arr
    
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
        
static func calc_path_point_count(v1, v2) -> int:
    var k = 0.002
    var th1 = cartesian2polar(v1.x, v1.y)
    var th2 = cartesian2polar(v2.x, v2.y)
    
    var a = abs(th1.y - th2.y)
    a = a if a <= 180 else 2 * PI - a
    
    var point_density = (th1.x + th2.x) * a 
    return int(point_density * k) + 1
    
        

