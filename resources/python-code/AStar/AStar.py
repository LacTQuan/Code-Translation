from queue import PriorityQueue
class Node:
    def __init__(self, pos: tuple, g_cost: float, h_cost: float):
        self.pos = pos
        self.g_cost = g_cost
        self.h_cost = h_cost
        self.f_cost = self.g_cost + self.h_cost

        self.parent = None

    def __lt__(self, other):
        return self.f_cost < other.f_cost


class AStar:
    def __init__(self, map_grid, start_node, goal_node):
        self.open = PriorityQueue()
        self.visited = []
        self.map_grid = map_grid
        self.start_node = start_node
        self.goal_node = goal_node

    def search(self):
        self.open.put(self.start_node)

        while not self.open.empty():
            current_node = self.open.get()
            if current_node.pos in self.visited:
                continue

            self.visited.append(current_node.pos)

            if current_node.pos == self.goal_node.pos:
                print(f"Reached goal node: {current_node.parent.pos}")
                return self.reconstruct_path(current_node), current_node.f_cost

            neighbors = self.get_neighbors(current_node)

            for neighbor in neighbors:
                if neighbor.pos in self.visited:
                    continue

                g_cost = current_node.g_cost + self.map_grid[neighbor.pos]
                h_cost = self.heuristic(neighbor)
                
                existing_node = self.find_node_in_open(neighbor)
                if existing_node:
                    if g_cost < existing_node.g_cost:
                        self.update_node(existing_node, g_cost, h_cost, current_node)
                else:
                    self.update_node(neighbor, g_cost, h_cost, current_node)
                    self.open.put(neighbor)

        return None

    def find_node_in_open(self, node):
        for n in list(self.open.queue):
            if n.pos == node.pos:
                return n
        return None

    def get_neighbors(self, node):
        dirs = [[1, 0], [0, 1], [-1, 0], [0, -1]]
        neighbors = []

        for dir in dirs:
            neighbor_pos = (node.pos[0] + dir[0], node.pos[1] + dir[1])

            if (0 <= neighbor_pos[0] < self.map_grid.shape[0] and
                    0 <= neighbor_pos[1] < self.map_grid.shape[1]):

                if self.map_grid[neighbor_pos] != -1:
                    neighbors.append(Node(neighbor_pos, 0, 0))

        return neighbors

    def heuristic(self, node):
        d = abs(node.pos[0] - self.goal_node.pos[0]) + abs(node.pos[1] - self.goal_node.pos[1])
        return d
    
    
    def reconstruct_path(self, goal_node):
        path = [goal_node.pos]
        current = goal_node
        
        while current.parent.pos != self.start_node.pos:
            print(f"Backtracking from node: {current.pos} to parent: {current.parent.pos} with f_cost: {current.f_cost}")
            path.append(current.parent.pos)
            current = current.parent

        path.append(self.start_node.pos)

        return path[::-1]

    def update_node(self, node, g_cost, h_cost, current_node):
        node.g_cost = g_cost
        node.h_cost = h_cost
        node.f_cost = g_cost + h_cost
        node.parent = current_node

if __name__ == "__main__":
    import numpy as np
    
    map_grid = np.array([
        [ 0,  2, -1,  0,  2,  6,  5,  5,  4,  6],
        [ 5, -1, -1,  4,  1,  1,  1,  5,  3,  5],
        [ 2,  6,  8, -1,  5,  2,  8,  4,  0,  0],
        [ 1,  0,  5,  5, -1,  2,  2,  1,  0,  7],
        [ 0,  6,  5,  0,  6,  6,  7,  6,  0,  1],
        [ 4,  3,  8,  7,  3,  4,  8,  6,  4,  2],
        [ 1,  3,  5,  2,  6,  2,  4,  6,  8,  1],
        [ 2,  8,  0,  5,  7,  1,  6, -1,  8,  1],
        [ 7,  5,  0,  2,  4, -1,  0,  3,  0,  5],
        [ 3,  3,  6,  0,  6,  5,  7,  4,  6,  5]
    ])
    
    print("Map Grid:")
    print(map_grid)

    
    start_node = Node((0, 0), 0, 0)
    goal_node = Node((9, 9), 0, 0)

    astar = AStar(map_grid, start_node, goal_node)
    path = astar.search()
    if path:
        print("Path found:")
        for p in path:
            print(p)
    else:
        print("No path found.")
    
