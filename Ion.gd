extends Node2D

export var radius_core : float = 12
export var radius_max : float = 24
export var mass_init : float = 10
export var damper : float = 120
export var charge_init : float = -18000
export var charge_limit : float = -4000
export var tension_var : float = 1200

var radius = radius_core
var charge = charge_init
var mass = mass_init

var screen_size

var target = Vector2()
var force = Vector2()
var velocity = Vector2()

var electrons_free := []
var electrons_catch := []

var prev_velocity = velocity

func being_hit(charge_delta: float, mass_delta: float):
    charge += charge_delta
    mass += mass_delta
    radius = (radius_max - radius_core) * ((charge_init - charge) / charge_init) + radius_core
    $IonVisual.color = $IonVisual.color.lightened(0.2)
    $IonVisual.color_core = $IonVisual.color_core.lightened(0.1)
    $IonVisual.update()

func _input(event):
    if event is InputEventMouseMotion:
        target = event.position

func _ready():
    screen_size = get_viewport_rect().size
    $Trail.width = radius * 2

func _process(delta):
    if Input.is_action_pressed("pointer_pressed"):
        force = (target - position) * tension_var
    else:
        force *= 0
    
    for e in electrons_free:
        var dist = position - e.position
        force += dist.normalized() * charge * e.charge / dist.length_squared()
         
    force -= velocity * damper
    
    velocity += (force / mass) * delta
    #velocity *= exp(-1 * damper * delta)
    position += (prev_velocity + velocity) * delta * 0.5
    position.x = clamp(position.x, 0, screen_size.x)
    position.y = clamp(position.y, 0, screen_size.y)
    
    prev_velocity = velocity
    
    $Trail.add_timept(position, delta)
    $Trail.position = -position
    



