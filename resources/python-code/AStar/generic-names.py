from queue import PriorityQueue
class ClassA:
    def __init__(self, coordinates: tuple, weight_a: float, weight_b: float):
        self.coordinates = coordinates
        self.weight_a = weight_a
        self.weight_b = weight_b
        self.total_weight = self.weight_a + self.weight_b

        self.predecessor = None

    def __lt__(self, other):
        return self.total_weight < other.total_weight


class ClassB:
    def __init__(self, data_matrix, initial_point, target_point):
        self.pending_queue = PriorityQueue()
        self.processed = []
        self.data_matrix = data_matrix
        self.initial_point = initial_point
        self.target_point = target_point

    def function1(self):
        self.pending_queue.put(self.initial_point)

        while not self.pending_queue.empty():
            current_element = self.pending_queue.get()
            if current_element.coordinates in self.processed:
                continue

            self.processed.append(current_element.coordinates)

            if current_element.coordinates == self.target_point.coordinates:
                return self.function5(current_element), current_element.total_weight

            adjacent_elements = self.function3(current_element)

            for element in adjacent_elements:
                if element.coordinates in self.processed:
                    continue

                weight_a = current_element.weight_a + self.data_matrix[element.coordinates]
                weight_b = self.function4(element)
                
                existing_element = self.function2(element)
                if existing_element:
                    if weight_a < existing_element.weight_a:
                        self.function6(existing_element, weight_a, weight_b, current_element)
                else:
                    self.function6(element, weight_a, weight_b, current_element)
                    self.pending_queue.put(element)

        return None

    def function2(self, element):
        for e in list(self.pending_queue.queue):
            if e.coordinates == element.coordinates:
                return e
        return None

    def function3(self, element):
        directions = [[1, 0], [0, 1], [-1, 0], [0, -1]]
        adjacent = []

        for direction in directions:
            adjacent_coords = (element.coordinates[0] + direction[0], element.coordinates[1] + direction[1])

            if (0 <= adjacent_coords[0] < self.data_matrix.shape[0] and
                    0 <= adjacent_coords[1] < self.data_matrix.shape[1]):

                if self.data_matrix[adjacent_coords] != -1:
                    adjacent.append(ClassA(adjacent_coords, 0, 0))

        return adjacent

    def function4(self, element):
        distance = abs(element.coordinates[0] - self.target_point.coordinates[0]) + abs(element.coordinates[1] - self.target_point.coordinates[1])
        return distance
    
    
    def function5(self, final_element):
        sequence = [final_element.coordinates]
        current = final_element
        
        while current.predecessor.coordinates != self.initial_point.coordinates:
            print(f"Tracing back from: {current.coordinates} to predecessor: {current.predecessor.coordinates} with weight: {current.total_weight}")
            sequence.append(current.predecessor.coordinates)
            current = current.predecessor

        sequence.append(self.initial_point.coordinates)

        return sequence[::-1]

    def function6(self, element, weight_a, weight_b, current_element):
        element.weight_a = weight_a
        element.weight_b = weight_b
        element.total_weight = weight_a + weight_b
        element.predecessor = current_element

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


    start_node = ClassA((0, 0), 0, 0)
    goal_node = ClassA((9, 9), 0, 0)

    classb = ClassB(map_grid, start_node, goal_node)
    path = classb.function1()
    if path:
        print("Path found:")
        for p in path:
            print(p)
    else:
        print("No path found.")
