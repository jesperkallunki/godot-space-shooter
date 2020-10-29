extends KinematicBody2D

export var acceleration = 100
export var speed = 100

var velocity = Vector2()

export var health = 100
export var shield_health = 100

onready var collision = $collision
onready var hitbox = $hitbox
onready var hitbox_collision = $hitbox/collision
onready var shield = $shield
onready var shield_collision = $shield/collision

export var collision_radius = 100;
export var collision_heigth = 100;

var shielding = false

onready var beam = $beam

export var beam_charge = 100

var firing = false

func _ready():
	collision.shape.set_radius(collision_radius);
	collision.shape.set_height(collision_heigth);
	
	hitbox_collision.shape.set_radius(collision.shape.get_radius());
	hitbox_collision.shape.set_height(collision.shape.get_height());
	
	shield_collision.shape.set_radius(collision.shape.get_radius() + 20);
	shield_collision.shape.set_height(collision.shape.get_height());
	shield.visible = false;
	shield.set_process(false);
	
	beam.visible = false;
	beam.set_process(false);
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED);

func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	
	var direction = Vector2();
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	
	velocity = lerp(velocity, direction * speed, acceleration * delta)
	
	velocity = move_and_slide(velocity)
	
	if Input.is_action_just_pressed("shield"):
		if shielding:
			yield(get_tree().create_timer(1), "timeout")
			collision.shape.set_radius(collision_radius);
			shield.visible = false;
			shield.set_process(false);
			shielding = false;
		else:
			yield(get_tree().create_timer(1), "timeout")
			collision.shape.set_radius(shield_collision.shape.get_radius());
			shield.visible = true;
			shield.set_process(true);
			shielding = true;
	
	if not firing:
		beam_charge = clamp(beam_charge + 5 * delta, 0, 100)
	print(beam_charge);
	beam.visible = false;
	beam.set_process(false);
	firing = false;
	if Input.is_action_pressed("fire") and beam_charge > 0:
		beam.cast_to = Vector2(get_local_mouse_position());
		beam.force_raycast_update();
		beam_charge = clamp(beam_charge - 20 * delta, 0, 100)
		beam.visible = true;
		beam.set_process(true);
		firing = true;
		if beam.is_colliding():
			var beam_collider = beam.get_collider()
			print(beam_collider);
