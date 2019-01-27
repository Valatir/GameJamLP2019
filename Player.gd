extends KinematicBody2D

var motion=Vector2()
var direction=0
export var life = 5
var dead = false
var can_take_damage = true
export var action_up="ui_up"
export var action_down="ui_down"
export var action_right="ui_right"
export var action_left="ui_left"
export var action_shoot="ui_accept"
export var ACCELERATION=50
export var MAX_SPEED=300
const FIRE_RATE=0.5
var can_shoot=true
var bullet_scene = preload ("res://Bullet.tscn")
signal health_changed(health)


func shoot_bullet():
	if can_shoot:
		can_shoot=false
		$fire_rate.start(FIRE_RATE)
		var bullet= bullet_scene.instance()
		get_parent().add_child(bullet)
		bullet.set_rotation(direction)
		bullet.direction=direction
		bullet.set_global_position(get_global_position())

func _physics_process(delta):

	if !dead:

		if Input.is_action_pressed(action_right):
			motion.x= min(motion.x + ACCELERATION, MAX_SPEED)
		elif Input.is_action_pressed(action_left):
			motion.x= max(motion.x - ACCELERATION, -MAX_SPEED)
		else:
			motion.x=lerp(motion.x,0,0.2)

		if Input.is_action_pressed(action_up):
			motion.y=max(motion.y - ACCELERATION, -MAX_SPEED)
		elif Input.is_action_pressed(action_down):
			motion.y=min(motion.y + ACCELERATION, MAX_SPEED)
		else:
			motion.y=lerp(motion.y,0,0.2)

		direction=motion.angle()

		if (motion.x<5 and motion.x >-5) and (motion.y<5 and motion.y >-5):
			$AnimatedSprite.play("idle")
		else:
			$AnimatedSprite.play("walk")
		
		if motion.x >0:
			$AnimatedSprite.flip_h=true
		else:
			$AnimatedSprite.flip_h=false
		
		if Input.is_action_pressed(action_shoot):
			$AnimatedSprite.play("attack")
			shoot_bullet()
			
		move_and_collide(motion * delta)
	else:
		$AnimatedSprite.play("dead")
		$CollisionShape2D.disabled = true


func _on_invul_timer_timeout():
	can_take_damage=true
	if !dead:
		modulate = Color(1,1,1,1)
	$CollisionShape2D.disabled = false



func take_damage():
	if can_take_damage:
		life-=1
		emit_signal("health_changed",life)
		can_take_damage = false
		$invul_timer.start(1.5)
		modulate = Color(1,1,1,0.3)
		$CollisionShape2D.disabled = true

	if life<=0:
		dead = true
		can_take_damage=false
		modulate= Color(1,1,1,1)
		$AnimatedSprite.flip_h=false
		#is now ded blep

func _on_Hitbox_area_shape_entered(area_id, area, area_shape, self_shape):
	pass

func _on_fire_rate_timeout():
	can_shoot=true
