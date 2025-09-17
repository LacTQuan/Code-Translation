#include <iostream>
#include <vector>
#include <queue>
#include <algorithm>
#include <memory>
#include <cmath>

class DataPoint {
public:
    std::pair<int, int> coordinates;
    float weight_a;
    float weight_b;
    float total_weight;
    std::shared_ptr<DataPoint> predecessor;

    DataPoint(std::pair<int, int> coords, float w_a, float w_b) 
        : coordinates(coords), weight_a(w_a), weight_b(w_b), total_weight(w_a + w_b), predecessor(nullptr) {}
};

class BFS {
private:
    std::vector<std::shared_ptr<DataPoint>> pending_queue;
    std::vector<std::pair<int, int>> processed;
    std::vector<std::vector<int>> data_matrix;
    std::shared_ptr<DataPoint> initial_point;
    std::shared_ptr<DataPoint> target_point;

    struct CompareDataPoint {
        bool operator()(const std::shared_ptr<DataPoint>& a, const std::shared_ptr<DataPoint>& b) const {
            return a->total_weight > b->total_weight;
        }
    };

public:
    BFS(const std::vector<std::vector<int>>& matrix, 
        std::shared_ptr<DataPoint> init, 
        std::shared_ptr<DataPoint> target) 
        : data_matrix(matrix), initial_point(init), target_point(target) {
        pending_queue.push_back(initial_point);
        std::push_heap(pending_queue.begin(), pending_queue.end(), CompareDataPoint());
    }

    std::pair<std::vector<std::pair<int, int>>, float> execute() {
        while (!pending_queue.empty()) {
            std::pop_heap(pending_queue.begin(), pending_queue.end(), CompareDataPoint());
            auto current_element = pending_queue.back();
            pending_queue.pop_back();

            if (std::find(processed.begin(), processed.end(), current_element->coordinates) != processed.end()) {
                continue;
            }
            processed.push_back(current_element->coordinates);

            if (current_element->coordinates == target_point->coordinates) {
                return std::make_pair(find_list(current_element), current_element->total_weight);
            }

            auto adjacent_elements = reverse_string(current_element);
            for (auto& element : adjacent_elements) {
                if (std::find(processed.begin(), processed.end(), element->coordinates) != processed.end()) {
                    continue;
                }

                float weight_a = current_element->weight_a + data_matrix[element->coordinates.first][element->coordinates.second];
                float weight_b = swap_elements(element);

                int existing_index = calculate_sum(element);
                if (existing_index != -1) {
                    auto existing_element = pending_queue[existing_index];
                    if (weight_a < existing_element->weight_a) {
                        insert_element(existing_element, weight_a, weight_b, current_element);
                    }
                } else {
                    insert_element(element, weight_a, weight_b, current_element);
                    pending_queue.push_back(element);
                    std::push_heap(pending_queue.begin(), pending_queue.end(), CompareDataPoint());
                }
            }
        }
        return std::make_pair(std::vector<std::pair<int, int>>(), 0.0f);
    }

    int calculate_sum(std::shared_ptr<DataPoint> element) {
        for (int i = 0; i < pending_queue.size(); i++) {
            if (pending_queue[i]->coordinates == element->coordinates) {
                return i;
            }
        }
        return -1;
    }

    std::vector<std::shared_ptr<DataPoint>> reverse_string(std::shared_ptr<DataPoint> element) {
        std::vector<std::pair<int, int>> directions = {{1,0}, {0,1}, {-1,0}, {0,-1}};
        std::vector<std::shared_ptr<DataPoint>> adjacent;

        for (auto& dir : directions) {
            std::pair<int, int> adjacent_coords = {element->coordinates.first + dir.first, element->coordinates.second + dir.second};
            if (adjacent_coords.first >= 0 && adjacent_coords.first < data_matrix.size() &&
                adjacent_coords.second >= 0 && adjacent_coords.second < data_matrix[0].size()) {
                if (data_matrix[adjacent_coords.first][adjacent_coords.second] != -1) {
                    adjacent.push_back(std::make_shared<DataPoint>(adjacent_coords, 0, 0));
                }
            }
        }
        return adjacent;
    }

    float swap_elements(std::shared_ptr<DataPoint> element) {
        int dx = std::abs(element->coordinates.first - target_point->coordinates.first);
        int dy = std::abs(element->coordinates.second - target_point->coordinates.second);
        return dx + dy;
    }

    std::vector<std::pair<int, int>> find_list(std::shared_ptr<DataPoint> final_element) {
        std::vector<std::pair<int, int>> sequence;
        auto current = final_element;
        while (current->predecessor != nullptr && current->predecessor->coordinates != initial_point->coordinates) {
            std::cout << "Tracing back from: (" << current->coordinates.first << "," << current->coordinates.second 
                      << ") to predecessor: (" << current->predecessor->coordinates.first << "," 
                      << current->predecessor->coordinates.second << ") with weight: " << current->total_weight << std::endl;
            sequence.push_back(current->coordinates);
            current = current->predecessor;
        }
        sequence.push_back(initial_point->coordinates);
        std::reverse(sequence.begin(), sequence.end());
        return sequence;
    }

    void insert_element(std::shared_ptr<DataPoint> element, float weight_a, float weight_b, std::shared_ptr<DataPoint> current_element) {
        element->weight_a = weight_a;
        element->weight_b = weight_b;
        element->total_weight = weight_a + weight_b;
        element->predecessor = current_element;
    }
};

int main() {
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

    auto start_node = std::make_shared<DataPoint>(std::make_pair(0,0), 0, 0);
    auto goal_node = std::make_shared<DataPoint>(std::make_pair(9,9), 0, 0);

    BFS bfs(map_grid, start_node, goal_node);
    auto result = bfs.execute();
    if (!result.first.empty()) {
        std::cout << "Path found:" << std::endl;
        for (const auto& p : result.first) {
            std::cout << "(" << p.first << "," << p.second << ")" << std::endl;
        }
    } else {
        std::cout << "No path found." << std::endl;
    }

    return 0;
}
// Model: deepseek/deepseek-reasoner
// Temperature: 0.7
// Response Time: 429545 ms
// Timestamp: 9/10/2025, 10:07:32 PM
// Prompt Tokens: 1483
// Completion Tokens: 8674
// Total Tokens: 10157
// Cost: $0.0198