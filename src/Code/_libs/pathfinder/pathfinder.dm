pathfinder
	proc
		search()

		weight(turf/t)
			return 1

		isPassable(turf/t)
			if(!t || t.density) return FALSE
			for(var/obj/o in t)
				if(o.density) return FALSE
			return TRUE

		distance(turf/a, turf/b)	// the distance heuristic between a and b
			if(!a || !b) return 1.#INF
			var/dx = abs(a.x - b.x)
			var/dy = abs(a.y - b.y)
			if(max(dx, dy) == 1)
				var/step_distance = dx && dy ? 1.41421356237 : 1
				return step_distance * (weight(a) + weight(b)) / 2
			return max(dx, dy) + min(dx, dy) * 0.41421356237


		neighbors(turf/a)	// return a heterogenous list of neighboring objects
			. = new/list
			if(!a) return

			for(var/turf/t in oview(1, a))
				if(!isPassable(t)) continue
				var/delta_x = t.x - a.x
				var/delta_y = t.y - a.y
				if(delta_x && delta_y)
					var/turf/x_side = locate(a.x + delta_x, a.y, a.z)
					var/turf/y_side = locate(a.x, a.y + delta_y, a.z)
					if(!isPassable(x_side) || !isPassable(y_side)) continue
				. += t
