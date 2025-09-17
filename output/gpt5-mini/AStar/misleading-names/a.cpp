#include <iostream>
#include <vector>
#include <algorithm>
#include <utility>
#include <cmath>

class DataPoint {
public:
    std::pair<int,int> coordinates;
    double weight_a;
    double weight_b;
    double total_weight;
    DataPoint* predecessor;

    DataPoint(std::pair<int,int> coordinates_, double weight_a_, double weight_b_) {
        coordinates = coordinates_;
        weight_a = weight_a_;
        weight_b = weight_b_;
        total_weight = weight_a + weight_b;
        predecessor = nullptr;
    }

    bool operator<(const DataPoint& other) const {
        return total_weight < other.total_weight;
    }
};

class PendingQueue {
public:
    struct Cmp {
        bool operator()(DataPoint* a, DataPoint* b) const {
            return a->total_weight > b->total_weight;
        }
    };

    std::vector<DataPoint*> q;
    Cmp cmp;

    void put(DataPoint* p) {
        q.push_back(p);
        std::push_heap(q.begin(), q.end(), cmp);
    }

    DataPoint* get() {
        std::pop_heap(q.begin(), q.end(), cmp);
        DataPoint* res = q.back();
        q.pop_back();
        return res;
    }

    bool empty() const {
        return q.empty();
    }

    std::vector<DataPoint*> get_all() const {
        return q;
    }
};

class BFS {
public:
    PendingQueue pending_queue;
    std::vector<std::pair<int,int>> processed;
    std::vector<std::vector<int>> data_matrix;
    DataPoint* initial_point;
    DataPoint* target_point;

    BFS(const std::vector<std::vector<int>>& data_matrix_, DataPoint* initial_point_, DataPoint* target_point_) {
        data_matrix = data_matrix_;
        initial_point = initial_point_;
        target_point = target_point_;
    }

    std::pair<std::vector<std::pair<int,int>>, double>* execute() {
        pending_queue.put(initial_point);

        while (!pending_queue.empty()) {
            DataPoint* current_element = pending_queue.get();
            if (contains_processed(current_element->coordinates)) {
                continue;
            }

            processed.push_back(current_element->coordinates);

            if (current_element->coordinates == target_point->coordinates) {
                std::vector<std::pair<int,int>> seq = find_list(current_element);
                std::pair<std::vector<std::pair<int,int>>, double>* res = new std::pair<std::vector<std::pair<int,int>>, double>(seq, current_element->total_weight);
                return res;
            }

            std::vector<DataPoint*> adjacent_elements = reverse_string(current_element);

            for (DataPoint* element : adjacent_elements) {
                if (contains_processed(element->coordinates)) {
                    continue;
                }

                double weight_a = current_element->weight_a + data_matrix[element->coordinates.first][element->coordinates.second];
                double weight_b = swap_elements(element);
                
                DataPoint* existing_element = calculate_sum(element);
                if (existing_element) {
                    if (weight_a < existing_element->weight_a) {
                        insert_element(existing_element, weight_a, weight_b, current_element);
                    }
                } else {
                    insert_element(element, weight_a, weight_b, current_element);
                    pending_queue.put(element);
                }
            }
        }

        return nullptr;
    }

    DataPoint* calculate_sum(DataPoint* element) {
        std::vector<DataPoint*> snapshot = pending_queue.get_all();
        for (DataPoint* e : snapshot) {
            if (e->coordinates == element->coordinates) {
                return e;
            }
        }
        return nullptr;
    }

    std::vector<DataPoint*> reverse_string(DataPoint* element) {
        std::vector<std::pair<int,int>> directions = { {1,0}, {0,1}, {-1,0}, {0,-1} };
        std::vector<DataPoint*> adjacent;

        for (auto direction : directions) {
            std::pair<int,int> adjacent_coords = { element->coordinates.first + direction.first, element->coordinates.second + direction.second };

            if (0 <= adjacent_coords.first && adjacent_coords.first < (int)data_matrix.size() &&
                0 <= adjacent_coords.second && adjacent_coords.second < (int)data_matrix[0].size()) {

                if (data_matrix[adjacent_coords.first][adjacent_coords.second] != -1) {
                    adjacent.push_back(new DataPoint(adjacent_coords, 0, 0));
                }
            }
        }

        return adjacent;
    }

    double swap_elements(DataPoint* element) {
        int distance = std::abs(element->coordinates.first - target_point->coordinates.first) + std::abs(element->coordinates.second - target_point->coordinates.second);
        return distance;
    }
    
    std::vector<std::pair<int,int>> find_list(DataPoint* final_element) {
        std::vector<std::pair<int,int>> sequence;
        sequence.push_back(final_element->coordinates);
        DataPoint* current = final_element;
        
        while (current->predecessor->coordinates != initial_point->coordinates) {
            std::cout << "Tracing back from: (" << current->coordinates.first << ", " << current->coordinates.second << ") to predecessor: ("
                      << current->predecessor->coordinates.first << ", " << current->predecessor->coordinates.second << ") with weight: " << current->total_weight << std::endl;
            sequence.push_back(current->predecessor->coordinates);
            current = current->predecessor;
        }

        sequence.push_back(initial_point->coordinates);

        std::reverse(sequence.begin(), sequence.end());
        return sequence;
    }

    void insert_element(DataPoint* element, double weight_a, double weight_b, DataPoint* current_element) {
        element->weight_a = weight_a;
        element->weight_b = weight_b;
        element->total_weight = weight_a + weight_b;
        element->predecessor = current_element;
    }

private:
    bool contains_processed(const std::pair<int,int>& coords) {
        for (auto& c : processed) {
            if (c == coords) return true;
        }
        return false;
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
        for (size_t j = 0; j < row.size(); ++j) {
            std::cout << row[j];
            if (j + 1 < row.size()) std::cout << " ";
        }
        std::cout << std::endl;
    }

    DataPoint start_node({0,0}, 0, 0);
    DataPoint goal_node({9,9}, 0, 0);

    BFS bfs(map_grid, &start_node, &goal_node);
    std::pair<std::vector<std::pair<int,int>>, double>* path = bfs.execute();
    if (path) {
        std::cout << "Path found:" << std::endl;
        for (auto p : path->first) {
            std::cout << "(" << p.first << ", " << p.second << ")" << std::endl;
        }
        delete path;
    } else {
        std::cout << "No path found." << std::endl;
    }

    return 0;
}
// Model: gpt-5-mini
// Temperature: 1
// Response Time: 79375 ms
// Timestamp: 9/12/2025, 10:15:41 PM
// Prompt Tokens: 1514
// Completion Tokens: 4647
// Total Tokens: 6161
// Cost: $0.0097