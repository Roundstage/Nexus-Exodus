pathfinder/astar
	var/max_expansions = 10000

	search(start, end)
		if(!start || !end) return
		if(start == end) return list()
		var
			PriorityQueue/open = new/PriorityQueue(/pathnode/proc/cmp)
			list/closed = list()
			list/g_score = list()
			expansions = 0

			pathnode/node = new(start, null, 0, distance(start, end))

		g_score[start] = 0
		open.Enqueue(node)

		while(!open.IsEmpty())
			node = open.Dequeue()
			if(closed[node.source]) continue
			if(node.g != g_score[node.source]) continue

			if(node.source == end)	// finished
				var/list/L = new

				while(node && node.parent)
					L += node.source
					node = node.parent

				var/half_len = L.len/2
				for(var/i=1, i<=half_len, ++i)
					L.Swap(i, L.len-i+1)

				return L

			closed[node.source] = TRUE
			expansions++
			if(expansions >= max_expansions) return

			for(var/d in neighbors(node.source))
				var/tentative_g = node.g + distance(node.source, d)
				if(!isnull(g_score[d]) && tentative_g >= g_score[d]) continue
				g_score[d] = tentative_g
				if(closed[d]) closed -= d
				var/pathnode/new_node = new(d, node, tentative_g, distance(d, end))
				open.Enqueue(new_node)
