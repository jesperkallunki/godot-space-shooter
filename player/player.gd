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
onready var shield_sprite = $shield/sprite

export var collision_radius = 100;
export var collision_heigth = 100;

var shielding = false

onready var beam = $beam
onready var beam_line = $beam/line
onready var beam_particles = $beam/particles

export var beam_charge = 100

var beaming = false

func _ready():
	collision.shape.set_radius(collision_radius);
	collision.shape.set_height(collision_heigth);
	
	hitbox_collision.shape.set_radius(collision.shape.get_radius());
	hitbox_collision.shape.set_height(collision.shape.get_height());
	
	shield_collision.shape.set_radius(collision.shape.get_radius() + 20);
	shield_collision.shape.set_height(collision.shape.get_height());
	shield_sprite.set_scale(Vector2(1, 1.4));
	shield.visible = false;
	shield.set_process(false);
	
	beam_line.points[1] = Vector2.ZERO;
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED);

func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit();
	
	var direction = Vector2();
	if Input.is_action_pressed("up"):
		direction.y -= 1;
	if Input.is_action_pressed("down"):
		direction.y += 1;
	if Input.is_action_pressed("left"):
		direction.x -= 1;
	if Input.is_action_pressed("right"):
		direction.x += 1;
	
	velocity = lerp(velocity, direction * speed, acceleration * delta);
	
	velocity = move_and_slide(velocity);
	
	if Input.is_action_just_pressed("shield") and shield_health > 0:
		if shielding:
			yield(get_tree().create_timer(1), "timeout");
			collision.shape.set_radius(collision_radius);
			shield.visible = false;
			shield.set_process(false);
			shielding = false;
		else:
			yield(get_tree().create_timer(1), "timeout");
			collision.shape.set_radius(shield_collision.shape.get_radius());
			shield.visible = true;
			shield.set_process(true);
			shielding = true;
	
	print(beam_charge);
	beam_charge = clamp(beam_charge + 5 * delta, 0, 100);
	beam.visible = false;
	beam.set_process(false);
	beaming = false;
	if Input.is_action_pressed("fire") and beam_charge > 0:
		beam.cast_to = get_local_mouse_position();
		beam.force_raycast_update();
		beam_charge = clamp(beam_charge - 20 * delta, 0, 100);
		beam.visible = true;
		beam.set_process(true);
		beaming = true;
		if beam.is_colliding():
			beam_line.points[1] = beam.get_collision_point() - beam.global_position;
			beam_particles.position = beam.get_collision_point() - beam.global_position;
			beam_particles.global_rotation = beam.get_collision_normal().angle();
			beam_particles.visible = true;
			beam_particles.set_process(true);
			var beam_collider = beam.get_collider();
			if beam_collider.is_in_group("hitbox"):
				var beam_collider_parent = beam_collider.get_parent();
				print(beam_collider_parent);
		else:
			beam_line.points[1] = beam.cast_to;
			beam_particles.visible = false;
			beam_particles.set_process(false);
