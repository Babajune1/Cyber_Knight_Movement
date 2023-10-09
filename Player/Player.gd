extends CharacterBody2D

var SPEED = 500.0 # X movement speed
var JUMP_VELOCITY = -500.0# Y movement speed. In Godot going up is negative
var DASH_VELOCITY = 4500.0 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var anim = get_node("AnimationPlayer")
var dashing = false
var can_dash = true
var action_direction = -1
var slashing = false
var can_slash = true
var shooting = false

func ready(): 
	$DashCollisionShape2D.disabled = true
	$CollisionShape2D.disabled = false

	
func shoot():
	if Input.is_action_just_pressed("shoot") and is_on_floor():
		anim.current_animation = "Shoot"

func slash():
	if Input.is_action_just_pressed("slash") and is_on_floor() and can_slash:
		anim.current_animation = ("Slash")

func dash():
	$CollisionShape2D.disabled = true
	$DashCollisionShape2D.disabled = false
	if Input.is_action_pressed("ui_left"):
		action_direction = -1
	if Input.is_action_pressed("ui_right"):
		action_direction = 1
	if Input.is_action_just_pressed("ui_accept") and not is_on_floor() and can_dash:
		can_dash = false
		velocity.x = DASH_VELOCITY * action_direction
		anim.play("Dash")
	$DashCollisionShape2D.disabled = true
	$CollisionShape2D.disabled = false
		
func _physics_process(delta):
	var direction = Input.get_axis("ui_left", "ui_right")
	# Add the gravity.
	if not is_on_floor() and not dashing:
		velocity.y += gravity * delta
		
	dash()
	shoot()
	slash()
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		can_dash = true
		if not dashing:
			velocity.y = JUMP_VELOCITY
		anim.play("Jump")
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if direction == -1:
		$AnimatedSprite2D.flip_h = false
	elif direction == 1:
		$AnimatedSprite2D.flip_h = true
	if direction and not dashing:
		velocity.x = direction * SPEED
		if velocity.y == 0:
			anim.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0 and not slashing and not shooting:
				anim.play("Idle")
	if velocity.y > 0 and not dashing:
		anim.play("Fall")
	move_and_slide()




func _on_animation_player_animation_started(anim_name):
	if anim_name == "Shoot":
		print("shooting")
		shooting = true
		
	if anim_name == "Slash":
		slashing = true
	
	if anim_name == "Dash":
		dashing = true



func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Shoot":
		print("shot")
		shooting = false
		
	if anim_name == "Slash":
		slashing = false
	
	if anim_name == "Dash":
		dashing = false
