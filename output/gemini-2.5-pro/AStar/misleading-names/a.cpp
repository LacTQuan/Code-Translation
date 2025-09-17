#include <iostream>
#include <vector>
#include <queue>
#include <memory>
#include <utility>
#include <set>
#include <optional>
#include <cmath>
#include <algorithm>
#include <functional>
#include <iomanip>

struct DataPoint {
    std::pair<int, int> coordinates;
    double weight_a;
    double weight_b;
    double total_weight;
    std::shared_ptr<DataPoint> predecessor;

    DataPoint(std::pair<int, int> coords, double w_a, double w_b)
        : coordinates(coords), weight_a(w_a), weight_b(w_b), total_weight(w_a + w_b), predecessor(nullptr) {}
};

struct DataPointCompare {
    bool operator()(const std::shared_ptr<DataPoint>& a, const std::shared_ptr<DataPoint>& b) const {
        return a->total_weight > b->total_weight;
    }
};

template<
    class T,
    class Container = std::vector<T>,
    class Compare = std::less<typename Container::value_type>
>
class PQueue : public std::priority_queue<T, Container, Compare> {
public:
    const Container& get_container() const {
        return this->c;
    }
};


class BFS {
private:
    PQueue<std::shared_ptr<DataPoint>, std::vector<std::shared_ptr<DataPoint>>, DataPointCompare> pending_queue;
    std::set<std::pair<int, int>> processed;
    std::vector<std::vector<int>> data_matrix;
    std::shared_ptr<DataPoint> initial_point;
    std::shared_ptr<DataPoint> target_point;

public:
    BFS(const std::vector<std::vector<int>>& data_matrix, std::shared_ptr<DataPoint> initial_point, std::shared_ptr<DataPoint> target_point)
        : data_matrix(data_matrix), initial_point(initial_point), target_point(target_point) {}

    std::optional<std::pair<std::vector<std::pair<int, int>>, double>> execute() {
        pending_queue.push(this->initial_point);

        while (!pending_queue.empty()) {
            std::shared_ptr<DataPoint> current_element = pending_queue.top();
            pending_queue.pop();

            if (processed.count(current_element->coordinates)) {
                continue;
            }

            processed.insert(current_element->coordinates);

            if (current_element->coordinates == this->target_point->coordinates) {
                return std::make_pair(this->find_list(current_element), current_element->total_weight);
            }

            std::vector<std::shared_ptr<DataPoint>> adjacent_elements = this->reverse_string(current_element);

            for (auto& element : adjacent_elements) {
                if (processed.count(element->coordinates)) {
                    continue;
                }

                double weight_a = current_element->weight_a + this->data_matrix[element->coordinates.first][element->coordinates.second];
                double weight_b = this->swap_elements(element);
                
                std::shared_ptr<DataPoint> existing_element = this->calculate_sum(element);
                if (existing_element) {
                    if (weight_a < existing_element->weight_a) {
                        this->insert_element(existing_element, weight_a, weight_b, current_element);
                    }
                } else {
                    this->insert_element(element, weight_a, weight_b, current_element);
                    this->pending_queue.push(element);
                }
            }
        }

        return std::nullopt;
    }

    std::shared_ptr<DataPoint> calculate_sum(std::shared_ptr<DataPoint> element) {
        for (const auto& e : this->pending_queue.get_container()) {
            if (e->coordinates == element->coordinates) {
                return e;
            }
        }
        return nullptr;
    }

    std::vector<std::shared_ptr<DataPoint>> reverse_string(std::shared_ptr<DataPoint> element) {
        std::vector<std::vector<int>> directions = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}};
        std::vector<std::shared_ptr<DataPoint>> adjacent;

        for (const auto& direction : directions) {
            std::pair<int, int> adjacent_coords = {
                element->coordinates.first + direction[0],
                element->coordinates.second + direction[1]
            };

            if (adjacent_coords.first >= 0 && adjacent_coords.first < this->data_matrix.size() &&
                adjacent_coords.second >= 0 && adjacent_coords.second < this->data_matrix[0].size()) {

                if (this->data_matrix[adjacent_coords.first][adjacent_coords.second] != -1) {
                    adjacent.push_back(std::make_shared<DataPoint>(adjacent_coords, 0, 0));
                }
            }
        }
        return adjacent;
    }

    double swap_elements(std::shared_ptr<DataPoint> element) {
        double distance = std::abs(element->coordinates.first - this->target_point->coordinates.first) + std::abs(element->coordinates.second - this->target_point->coordinates.second);
        return distance;
    }
    
    std::vector<std::pair<int, int>> find_list(std::shared_ptr<DataPoint> final_element) {
        std::vector<std::pair<int, int>> sequence;
        sequence.push_back(final_element->coordinates);
        auto current = final_element;
        
        while (current->predecessor->coordinates != this->initial_point->coordinates) {
            std::cout << "Tracing back from: (" << current->coordinates.first << ", " << current->coordinates.second << ") to predecessor: (" << current->predecessor->coordinates.first << ", " << current->predecessor->coordinates.second << ") with weight: " << current->total_weight << std::endl;
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
            std::cout << std::setw(3) << val;
        }
        std::cout << std::endl;
    }
    
    auto start_node = std::make_shared<DataPoint>(std::make_pair(0, 0), 0.0, 0.0);
    auto goal_node = std::make_shared<DataPoint>(std::make_pair(9, 9), 0.0, 0.0);

    BFS bfs(map_grid, start_node, goal_node);
    auto path = bfs.execute();
    if (path) {
        std::cout << "Path found:" << std::endl;
        
        std::cout << "[";
        for (size_t i = 0; i < path->first.size(); ++i) {
            std::cout << "(" << path->first[i].first << ", " << path->first[i].second << ")";
            if (i < path->first.size() - 1) {
                std::cout << ", ";
            }
        }
        std::cout << "]" << std::endl;

        std::cout << path->second << std::endl;
    } else {
        std::cout << "No path found." << std::endl;
    }

    return 0;
}
// Model: gemini/gemini-2.5-pro
// Temperature: 0.7
// Response Time: 76955 ms
// Timestamp: 9/12/2025, 1:01:31 PM
// Prompt Tokens: 1727
// Completion Tokens: 8852
// Total Tokens: 10579
// Cost: $0.0907