#define element .
proc
	//separates a string separated by any symbol into a list and returns it
    parse(string, separator)
        var
            length = length(string)
            list/words = list()
            position = 1
        element = findtext(string, separator, position)
        while(position <= length)
            if(element > position || element == 0)
                words += copytext(string, position, element)
            if(element)
                position = element + 1
                element = findtext(string, separator, position)
            else position = length + 1
        return words

mob
	proc
		ClientColorFlick(rgb)
			if(!client) return
			var/c = client.color
			client.color = rgb
			sleep(5)
			client.color = c

		ClientColorInvertFlick()
			if(!client) return
			var/c = client.color
			client.color = list(-1,0,0,0, 0,-1,0,0, 0,0,-1,0, 0,0,0,1, 1,1,1,0)
			sleep(5)
			client.color = c

atom/var/transform_size = 1

atom/proc/SetTransformSize(n = 1)
	var/mult = n / transform_size
	transform *= mult
	transform_size = n
	if(light_obj) light_obj.SetTransformSize(light_obj.transform_size * mult)

//This is from the library Screen Arrows by Kaiochao, but I have modified it
mob
	proc/PointArrow(obj/Arrow, atom/Target, MinDistance, ArrowDistance, instant_update = 0, dist_mod = 1, do_rotation = 1)

		if(!client) return

		if(!MinDistance) MinDistance = client.bound_height * 0.4
		if(!ArrowDistance) ArrowDistance = client.bound_height * 0.33 * dist_mod

		var/dx = Target.Cx() - Cx()
		var/dy = Target.Cy() - Cy()
		var/dot = dx*dx + dy*dy

		if(dot < MinDistance * MinDistance)
			Arrow.screen_loc = null
			return
		Arrow.screen_loc = "CENTER"

		var/matrix/m = new
		m *= Arrow.transform_size
		if(do_rotation)
			m.Translate(0, ArrowDistance)
			m.Turn(dx > 0 ? arccos(dy / sqrt(dot)) : -arccos(dy / sqrt(dot)))
		else
			var
				ang = get_global_angle(src,Target)
				x_offset = ArrowDistance * cos(ang)
				y_offset = ArrowDistance * sin(ang)
			m.Translate(y_offset, x_offset)

		if(instant_update) Arrow.transform = m //initial(Arrow.transform) * m
		else
			animate(Arrow)
			animate(Arrow, transform = m, time = sense_arrow_update_rate)


/*proc/MoveByAngle(mob/m, ang=0, spd=5)
	var
		vx = spd * cos(ang)
		vy = spd * -sin(ang)
	m.Move(m.loc, 0, m.step_x + vx, m.step_y + vy)*/

atom/movable/var/tmp
	fraction_x=0
	fraction_y=0
	vector_fraction_x=0
	vector_fraction_y=0
	vector_speed=0
	last_vector_move_requested_x=0
	last_vector_move_requested_y=0
	last_vector_move_actual_x=0
	last_vector_move_actual_y=0
	last_vector_move_attempted=0
	last_vector_move_complete=1

datum/NexusVectorKinematics
	var
		velocity_x = 0
		velocity_y = 0
		max_velocity = 0
		acceleration = 0

	New(new_max_velocity = 32, new_acceleration = 32, initial_direction, initial_speed_ratio = 0)
		max_velocity = max(0, new_max_velocity)
		acceleration = max(0, new_acceleration)
		if(initial_direction && initial_speed_ratio > 0)
			var/initial_angle = dir_to_angle_0_360(initial_direction)
			var/initial_speed = max_velocity * Clamp(initial_speed_ratio, 0, 1)
			velocity_x = sin(initial_angle) * initial_speed
			velocity_y = cos(initial_angle) * initial_speed
		. = ..()

	proc/steerToward(delta_x, delta_y, duration_deciseconds = 1)
		var/delta_magnitude = sqrt(delta_x ** 2 + delta_y ** 2)
		var/desired_x = 0
		var/desired_y = 0
		if(delta_magnitude)
			desired_x = delta_x / delta_magnitude * max_velocity
			desired_y = delta_y / delta_magnitude * max_velocity
		var/change_x = desired_x - velocity_x
		var/change_y = desired_y - velocity_y
		var/change_magnitude = sqrt(change_x ** 2 + change_y ** 2)
		var/max_change = acceleration * max(0, duration_deciseconds)
		if(change_magnitude > max_change && change_magnitude)
			var/change_scale = max_change / change_magnitude
			change_x *= change_scale
			change_y *= change_scale
		velocity_x += change_x
		velocity_y += change_y
		var/current_velocity = sqrt(velocity_x ** 2 + velocity_y ** 2)
		if(current_velocity > max_velocity && current_velocity)
			var/velocity_scale = max_velocity / current_velocity
			velocity_x *= velocity_scale
			velocity_y *= velocity_scale
			current_velocity = max_velocity
		return current_velocity

	proc/steerTowardAtom(atom/movable/subject, atom/movable/target, duration_deciseconds = 1, move_away = FALSE)
		if(!subject || !target) return
		var/delta_x = (target.bound_center_x() - subject.bound_center_x()) * world.icon_size
		var/delta_y = (target.bound_center_y() - subject.bound_center_y()) * world.icon_size
		if(move_away)
			delta_x = -delta_x
			delta_y = -delta_y
		return steerToward(delta_x, delta_y, duration_deciseconds)

	proc/distanceToAtom(atom/movable/subject, atom/movable/target)
		if(!subject || !target) return 0
		var/delta_x = (target.bound_center_x() - subject.bound_center_x()) * world.icon_size
		var/delta_y = (target.bound_center_y() - subject.bound_center_y()) * world.icon_size
		return sqrt(delta_x ** 2 + delta_y ** 2)

	proc/steerTowardDirection(movement_direction, duration_deciseconds = 1)
		if(!movement_direction) return steerToward(0, 0, duration_deciseconds)
		var/angle = dir_to_angle_0_360(movement_direction)
		return steerToward(sin(angle), cos(angle), duration_deciseconds)

	proc/advance(atom/movable/subject, duration_deciseconds = 1, maximum_distance = -1)
		if(!subject || duration_deciseconds <= 0) return
		var/movement_x = velocity_x * duration_deciseconds
		var/movement_y = velocity_y * duration_deciseconds
		var/movement_magnitude = sqrt(movement_x ** 2 + movement_y ** 2)
		if(maximum_distance >= 0 && movement_magnitude > maximum_distance && movement_magnitude)
			var/distance_scale = maximum_distance / movement_magnitude
			movement_x *= distance_scale
			movement_y *= distance_scale
		if(!movement_x && !movement_y) return
		var/physical_direction = XYtoDir(movement_x, movement_y)
		if(physical_direction) subject.dir = physical_direction
		var/moved = vector_step(subject, requested_x = movement_x, requested_y = movement_y, movement_direction = physical_direction)
		if(subject && subject.last_vector_move_attempted)
			if(subject.last_vector_move_requested_x != subject.last_vector_move_actual_x)
				velocity_x = 0
				subject.vector_fraction_x = 0
			if(subject.last_vector_move_requested_y != subject.last_vector_move_actual_y)
				velocity_y = 0
				subject.vector_fraction_y = 0
		return moved

atom/movable/proc/MoveByAngle(ang=0)
	var
		xx = cos(ang)
		yy = -sin(ang)

	if(xx > 0)
		fraction_x += xx - round(xx)
		xx = round(xx)
	else
		fraction_x += xx - (-round(-xx))
		xx = -round(-xx)

	if(yy > 0)
		fraction_y += yy - round(yy)
		yy = round(yy)
	else
		fraction_y += yy - (-round(-yy))
		yy = -round(-yy)

	Move(loc, dir, step_x + xx, step_y + yy)

proc/vector_step_toward(mob/a,mob/b,step_speed)
	if(!step_speed && a) step_speed = a.vector_speed
	if(!step_speed) return
	var/ang = get_global_angle(a,b)
	return vector_step(a,ang,step_speed)

proc/vector_step(atom/movable/a, ang = 0, step_speed, requested_x, requested_y, movement_direction)
	if(!a) return
	var/has_component_override = isnum(requested_x) && isnum(requested_y)
	if(!has_component_override)
		if(!step_speed) step_speed = a.vector_speed
		if(!step_speed) return
	a.last_vector_move_requested_x = 0
	a.last_vector_move_requested_y = 0
	a.last_vector_move_actual_x = 0
	a.last_vector_move_actual_y = 0
	a.last_vector_move_attempted = 0
	a.last_vector_move_complete = 1
	var/dx
	var/dy
	if(has_component_override)
		dx = requested_x
		dy = requested_y
	else
		dx = step_speed * sin(ang)
		dy = step_speed * cos(ang)
	if(!dx && !dy) return

	var/max_step = 32
	var/max_component = max(abs(dx), abs(dy))
	var/steps = 1
	if(max_component > max_step)
		steps = round(max_component / max_step)
		if(steps < 1) steps = 1
		if(steps * max_step < max_component) steps++
	var/step_dx = dx / steps
	var/step_dy = dy / steps
	var/moved
	for(var/i in 1 to steps)
		a.vector_fraction_x += step_dx
		a.vector_fraction_y += step_dy
		var/xx = round(a.vector_fraction_x)
		var/yy = round(a.vector_fraction_y)
		a.vector_fraction_x -= xx
		a.vector_fraction_y -= yy
		if(xx || yy)
			a.last_vector_move_attempted = 1
			a.last_vector_move_requested_x += xx
			a.last_vector_move_requested_y += yy
			var/start_x = a.Px(0)
			var/start_y = a.Py(0)
			var/physical_direction = movement_direction || a.dir
			moved = a.Move(a.loc, physical_direction, a.step_x + xx, a.step_y + yy)
			var/actual_x = round(a.Px(0) - start_x)
			var/actual_y = round(a.Py(0) - start_y)
			a.last_vector_move_actual_x += actual_x
			a.last_vector_move_actual_y += actual_y
			if(actual_x != xx || actual_y != yy)
				a.last_vector_move_complete = 0
			if(!moved) return moved
	return moved

proc/vector_step_dir(atom/movable/a, d, step_speed)
	if(!a || !d) return
	return vector_step(a, dir_to_angle_0_360(d), step_speed)
	//a.dir = angle_to_dir(ang)

//where north is 0 and it goes clockwise to 360. if b is directly above a then it will be 0
proc/get_global_angle(mob/a,mob/b)
	if(!a || !b) return 0
	var/ang = arctanD(b.bound_center_y() - a.bound_center_y(), b.bound_center_x() - a.bound_center_x())
	ang += 360
	if(ang > 360) ang -= 360
	return abs(ang)

proc/arctanD(x,y)
	if(!x && !y) return 0
	var/n = arccos(x / sqrt(x * x + y * y))
	if(y >= 0) return n
	else return -n
