#include <iostream>
#include <vector>
#include <queue> // Not directly used for CustomPriorityQueue, but could be for std::priority_queue
#include <utility> // For std::pair
#include <algorithm> // For std::reverse, std::find, std::push_heap, std::pop_heap
#include <cmath> // For std::abs
#include <memory> // For std::shared_ptr
#include <optional> // For std::optional return type

// Forward declaration
class DataPoint;

// DataPoint class
class DataPoint {
public:
    std::pair<int, int> coordinates;
    double weight_a;
    double weight_b;
    double total_weight;
    std::shared_ptr<DataPoint> predecessor; // Using shared_ptr for predecessor

    DataPoint(std::pair<int, int> coords, double wa, double wb)
        : coordinates(coords), weight_a(wa), weight_b(wb), predecessor(nullptr) {
        this->total_weight = this->weight_a + this->weight_b;
    }

    // Python's __lt__ method for comparison in PriorityQueue
    // For min-priority queue, smaller total_weight means higher priority.
    // This is used by the CustomPriorityQueue's heap operations.
    bool operator<(const DataPoint& other) const {
        return this->total_weight < other.total_weight;
    }
    // Define operator> for use in heap operations for min-heap logic
    bool operator>(const DataPoint& other) const {
        return this->total_weight > other.total_weight;
    }
};

// Custom PriorityQueue to mimic Python's behavior, especially the ability to iterate its internal elements.
// This is implemented as a min-priority queue.
class CustomPriorityQueue {
private:
    std::vector<std::shared_ptr<DataPoint>> heap; // The underlying list (vector)

public:
    CustomPriorityQueue() = default;

    void put(std::shared_ptr<DataPoint> item) {
        heap.push_back(item);
        // std::push_heap builds a max-heap by default. To make it a min-heap,
        // we provide a custom comparator that defines "greater than" as having a larger total_weight.
        // So, `a->total_weight > b->total_weight` means `a` is "greater" than `b` (lower priority).
        // `push_heap` will then place the element with the smallest total_weight at the front.
        std::push_heap(heap.begin(), heap.end(), [](const std::shared_ptr<DataPoint>& a, const std::shared_ptr<DataPoint>& b) {
            return a->total_weight > b->total_weight;
        });
    }

    std::shared_ptr<DataPoint> get() {
        if (empty()) {
            return nullptr; // Python's PriorityQueue.get() would block or raise an exception if empty.
                            // Returning nullptr is a C++ way to signal no element.
        }
        // std::pop_heap moves the element with the highest priority (smallest total_weight) to the end.
        std::pop_heap(heap.begin(), heap.end(), [](const std::shared_ptr<DataPoint>& a, const std::shared_ptr<DataPoint>& b) {
            return a->total_weight > b->total_weight;
        });
        std::shared_ptr<DataPoint> item = heap.back();
        heap.pop_back();
        return item;
    }

    bool empty() const {
        return heap.empty();
    }

    // Mimics Python's `list(self.pending_queue.queue)` by exposing the underlying vector.
    const std::vector<std::shared_ptr<DataPoint>>& get_queue_list() const {
        return heap;
    }
};


class BFS {
public:
    CustomPriorityQueue pending_queue;
    std::vector<std::pair<int, int>> processed;
    std::vector<std::vector<int>> data_matrix;
    std::shared_ptr<DataPoint> initial_point;
    std::shared_ptr<DataPoint> target_point;

    BFS(std::vector<std::vector<int>> data_matrix, std::shared_ptr<DataPoint> initial_point, std::shared_ptr<DataPoint> target_point)
        : data_matrix(std::move(data_matrix)), initial_point(std::move(initial_point)), target_point(std::move(target_point)) {}

    // Python returns a tuple of (list, float). C++ equivalent is std::optional<std::pair<std::vector<std::pair<int, int>>, double>>.
    std::optional<std::pair<std::vector<std::pair<int, int>>, double>> execute() {
        this->pending_queue.put(this->initial_point);

        while (!this->pending_queue.empty()) {
            std::shared_ptr<DataPoint> current_element = this->pending_queue.get();

            // Python's `in` for list is O(N). `std::find` on `std::vector` is O(N).
            bool already_processed = false;
            for (const auto& coords : this->processed) {
                if (coords == current_element->coordinates) {
                    already_processed = true;
                    break;
                }
            }
            if (already_processed) {
                continue;
            }

            this->processed.push_back(current_element->coordinates);

            if (current_element->coordinates == this->target_point->coordinates) {
                return std::make_pair(this->find_list(current_element), current_element->total_weight);
            }

            std::vector<std::shared_ptr<DataPoint>> adjacent_elements = this->reverse_string(current_element);

            for (std::shared_ptr<DataPoint> element : adjacent_elements) {
                bool element_processed = false;
                for (const auto& coords : this->processed) {
                    if (coords == element->coordinates) {
                        element_processed = true;
                        break;
                    }
                }
                if (element_processed) {
                    continue;
                }

                double weight_a = current_element->weight_a + this->data_matrix[element->coordinates.first][element->coordinates.second];
                double weight_b = this->swap_elements(element);
                
                std::shared_ptr<DataPoint> existing_element = this->calculate_sum(element);
                if (existing_element) {
                    // Python code updates the object in place, but does not re-heapify the PriorityQueue.
                    // This is a potential inefficiency/bug in the Python logic, which must be preserved.
                    if (weight_a < existing_element->weight_a) {
                        this->insert_element(existing_element, weight_a, weight_b, current_element);
                        // No explicit re-insertion or re-heapify call, mirroring Python's behavior.
                    }
                } else {
                    this->insert_element(element, weight_a, weight_b, current_element);
                    this->pending_queue.put(element);
                }
            }
        }

        return std::nullopt; // Python's `return None`
    }

    // Python's `calculate_sum` (misleading name, means find_in_queue)
    std::shared_ptr<DataPoint> calculate_sum(std::shared_ptr<DataPoint> element) {
        // Python: `for e in list(self.pending_queue.queue):`
        // Using `get_queue_list()` from CustomPriorityQueue to access the underlying vector.
        for (std::shared_ptr<DataPoint> e : this->pending_queue.get_queue_list()) {
            if (e->coordinates == element->coordinates) {
                return e;
            }
        }
        return nullptr; // Python's `return None`
    }

    // Python's `reverse_string` (misleading name, means get_adjacent_elements)
    std::vector<std::shared_ptr<DataPoint>> reverse_string(std::shared_ptr<DataPoint> element) {
        std::vector<std::pair<int, int>> directions = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}};
        std::vector<std::shared_ptr<DataPoint>> adjacent;

        int num_rows = this->data_matrix.size();
        int num_cols = this->data_matrix.empty() ? 0 : this->data_matrix[0].size();

        for (const auto& direction : directions) {
            std::pair<int, int> adjacent_coords = {element->coordinates.first + direction.first,
                                                   element->coordinates.second + direction.second};

            if ((0 <= adjacent_coords.first && adjacent_coords.first < num_rows) &&
                (0 <= adjacent_coords.second && adjacent_coords.second < num_cols)) {

                if (this->data_matrix[adjacent_coords.first][adjacent_coords.second] != -1) {
                    adjacent.push_back(std::make_shared<DataPoint>(adjacent_coords, 0.0, 0.0));
                }
            }
        }
        return adjacent;
    }

    // Python's `swap_elements` (misleading name, means calculate_heuristic_distance)
    double swap_elements(std::shared_ptr<DataPoint> element) {
        double distance = std::abs(static_cast<double>(element->coordinates.first - this->target_point->coordinates.first)) +
                          std::abs(static_cast<double>(element->coordinates.second - this->target_point->coordinates.second));
        return distance;
    }
    
    // Python's `find_list` (misleading name, means reconstruct_path)
    std::vector<std::pair<int, int>> find_list(std::shared_ptr<DataPoint> final_element) {
        std::vector<std::pair<int, int>> sequence;
        sequence.push_back(final_element->coordinates);
        std::shared_ptr<DataPoint> current = final_element;
        
        // Loop while current's predecessor is not null AND current's predecessor is not the initial point.
        // This handles cases where `final_element` is `initial_point` (if `initial_point.predecessor` is `nullptr`)
        // without crashing, mirroring Python's `AttributeError` for `None.coordinates` if `final_element`
        // was `initial_point` and its `predecessor` was `None`.
        while (current->predecessor != nullptr && current->predecessor->coordinates != this->initial_point->coordinates) {
            std::cout << "Tracing back from: (" << current->coordinates.first << ", " << current->coordinates.second
                      << ") to predecessor: (" << current->predecessor->coordinates.first << ", " << current->predecessor->coordinates.second
                      << ") with weight: " << current->total_weight << std::endl;
            sequence.push_back(current->predecessor->coordinates);
            current = current->predecessor;
        }
        
        sequence.push_back(this->initial_point->coordinates);

        std::reverse(sequence.begin(), sequence.end());
        return sequence;
    }

    void insert_element(std::shared_ptr<DataPoint> element, double weight_a, double weight_b, std::shared_ptr<DataPoint> current_element) {
        element->weight_a = weight_a;
        element->weight_b = weight_b;
        element->total_weight = weight_a + weight_b;
        element->predecessor = current_element;
    }
};

// Function to print std::pair<int, int> for convenience in main
std::ostream& operator<<(std::ostream& os, const std::pair<int, int>& p) {
    os << "(" << p.first << ", " << p.second << ")";
    return os;
}

int main() {
    // Mimic numpy array initialization
    std::vector<std::vector<int>> map_grid = {
        { 0,  2, -1,  0,  2,  6,  5,  5,  4,  6},
        { 5, -1, -1,  4,  1,  1,  1,  5,  3,  5},
        { 2,  6,  8, -1,  5,  2,  8,  4,  0,  0},
        { 1,  0,  5,  5, -1,  2,  2,  1,  0,  7},
        { 0,  6,  5,  0,  6,  6,  7,  6,  0,  1},
        { 4,  3,  8,  7,  3,  4,  8,  6,  4,  2},
        { 1,  3,  5,  2,  6,  2,  4,  6,  8,  1},
        { 2,  8,  0,  5,  7,  1,  6, -1,  8,  1},
        { 7,  5,  0,  2,  4, -1,  0,  3,  0,  5},
        { 3,  3,  6,  0,  6,  5,  7,  4,  6,  5}
    };

    std::cout << "Map Grid:" << std::endl;
    for (const auto& row : map_grid) {
        for (int val : row) {
            std::cout << val << " ";
        }
        std::cout << std::endl;
    }

    std::shared_ptr<DataPoint> start_node = std::make_shared<DataPoint>(std::make_pair(0, 0), 0.0, 0.0);
    std::shared_ptr<DataPoint> goal_node = std::make_shared<DataPoint>(std::make_pair(9, 9), 0.0, 0.0);

    BFS bfs(map_grid, start_node, goal_node);
    std::optional<std::pair<std::vector<std::pair<int, int>>, double>> path_result = bfs.execute();
    if (path_result.has_value()) {
        std::cout << "Path found:" << std::endl;
        for (const auto& p : path_result->first) {
            std::cout << p << std::endl;
        }
        std::cout << "Total weight: " << path_result->second << std::endl;
    } else {
        std::cout << "No path found." << std::endl;
    }

    return 0;
}
// Model: gemini/gemini-2.5-flash
// Temperature: 0.7
// Response Time: 94212 ms
// Timestamp: 9/12/2025, 10:38:55 PM
// Prompt Tokens: 1727
// Completion Tokens: 18020
// Total Tokens: 19747
// Cost: $0.0456
