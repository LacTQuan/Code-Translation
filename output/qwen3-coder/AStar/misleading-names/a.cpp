#include <queue>
#include <vector>
#include <tuple>
#include <iostream>
#include <algorithm>
#include <cmath>

using namespace std;

class DataPoint {
public:
    tuple<int, int> coordinates;
    float weight_a;
    float weight_b;
    float total_weight;
    DataPoint* predecessor;

    DataPoint(tuple<int, int> coords, float w_a, float w_b) {
        coordinates = coords;
        weight_a = w_a;
        weight_b = w_b;
        total_weight = weight_a + weight_b;
        predecessor = nullptr;
    }

    bool operator<(const DataPoint& other) const {
        return total_weight > other.total_weight;
    }
};

class BFS {
public:
    priority_queue<DataPoint> pending_queue;
    vector<tuple<int, int>> processed;
    vector<vector<int>> data_matrix;
    DataPoint* initial_point;
    DataPoint* target_point;

    BFS(vector<vector<int>> matrix, DataPoint* start, DataPoint* goal) {
        data_matrix = matrix;
        initial_point = start;
        target_point = goal;
    }

    tuple<vector<tuple<int, int>>, float> execute() {
        pending_queue.push(*initial_point);

        while (!pending_queue.empty()) {
            DataPoint current_element = pending_queue.top();
            pending_queue.pop();

            if (find(processed.begin(), processed.end(), current_element.coordinates) != processed.end()) {
                continue;
            }

            processed.push_back(current_element.coordinates);

            if (current_element.coordinates == target_point->coordinates) {
                auto result = find_list(&current_element);
                return make_tuple(result, current_element.total_weight);
            }

            vector<DataPoint> adjacent_elements = reverse_string(&current_element);

            for (auto& element : adjacent_elements) {
                if (find(processed.begin(), processed.end(), element.coordinates) != processed.end()) {
                    continue;
                }

                float weight_a = current_element.weight_a + data_matrix[get<0>(element.coordinates)][get<1>(element.coordinates)];
                float weight_b = swap_elements(&element);

                DataPoint* existing_element = calculate_sum(&element);
                if (existing_element) {
                    if (weight_a < existing_element->weight_a) {
                        insert_element(existing_element, weight_a, weight_b, &current_element);
                    }
                } else {
                    insert_element(&element, weight_a, weight_b, &current_element);
                    pending_queue.push(element);
                }
            }
        }

        return make_tuple(vector<tuple<int, int>>(), -1);
    }

    DataPoint* calculate_sum(DataPoint* element) {
        vector<DataPoint> queue_copy;
        while (!pending_queue.empty()) {
            queue_copy.push_back(pending_queue.top());
            pending_queue.pop();
        }

        for (auto& e : queue_copy) {
            pending_queue.push(e);
            if (e.coordinates == element->coordinates) {
                return &e;
            }
        }

        return nullptr;
    }

    vector<DataPoint> reverse_string(DataPoint* element) {
        vector<vector<int>> directions = {{1, 0}, {0, 1}, {-1, 0}, {0, -1}};
        vector<DataPoint> adjacent;

        for (auto& direction : directions) {
            tuple<int, int> adjacent_coords = make_tuple(
                get<0>(element->coordinates) + direction[0],
                get<1>(element->coordinates) + direction[1]
            );

            if (get<0>(adjacent_coords) >= 0 && get<0>(adjacent_coords) < data_matrix.size() &&
                get<1>(adjacent_coords) >= 0 && get<1>(adjacent_coords) < data_matrix[0].size()) {

                if (data_matrix[get<0>(adjacent_coords)][get<1>(adjacent_coords)] != -1) {
                    adjacent.push_back(DataPoint(adjacent_coords, 0, 0));
                }
            }
        }

        return adjacent;
    }

    float swap_elements(DataPoint* element) {
        float distance = abs(get<0>(element->coordinates) - get<0>(target_point->coordinates)) +
                         abs(get<1>(element->coordinates) - get<1>(target_point->coordinates));
        return distance;
    }

    vector<tuple<int, int>> find_list(DataPoint* final_element) {
        vector<tuple<int, int>> sequence;
        sequence.push_back(final_element->coordinates);
        DataPoint* current = final_element;

        while (current->predecessor->coordinates != initial_point->coordinates) {
            cout << "Tracing back from: (" << get<0>(current->coordinates) << ", " << get<1>(current->coordinates)
                 << ") to predecessor: (" << get<0>(current->predecessor->coordinates) << ", " << get<1>(current->predecessor->coordinates)
                 << ") with weight: " << current->total_weight << endl;
            sequence.push_back(current->predecessor->coordinates);
            current = current->predecessor;
        }

        sequence.push_back(initial_point->coordinates);
        reverse(sequence.begin(), sequence.end());
        return sequence;
    }

    void insert_element(DataPoint* element, float weight_a, float weight_b, DataPoint* current_element) {
        element->weight_a = weight_a;
        element->weight_b = weight_b;
        element->total_weight = weight_a + weight_b;
        element->predecessor = current_element;
    }
};

int main() {
    vector<vector<int>> map_grid = {
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

    cout << "Map Grid:" << endl;
    for (const auto& row : map_grid) {
        for (int val : row) {
            cout << val << " ";
        }
        cout << endl;
    }

    DataPoint start_node(make_tuple(0, 0), 0, 0);
    DataPoint goal_node(make_tuple(9, 9), 0, 0);

    BFS bfs(map_grid, &start_node, &goal_node);
    auto result = bfs.execute();

    if (get<1>(result) != -1) {
        cout << "Path found:" << endl;
        for (const auto& p : get<0>(result)) {
            cout << "(" << get<0>(p) << ", " << get<1>(p) << ")" << endl;
        }
    } else {
        cout << "No path found." << endl;
    }

    return 0;
}
// Model: openrouter/qwen/qwen3-coder
// Temperature: 0.7
// Response Time: 41602 ms
// Timestamp: 9/12/2025, 10:57:01 PM
// Prompt Tokens: 1516
// Completion Tokens: 1767
// Total Tokens: 3283
// Cost: $0.0104