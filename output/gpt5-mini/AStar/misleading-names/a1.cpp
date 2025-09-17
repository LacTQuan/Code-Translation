#include <iostream>
#include <vector>
#include <algorithm>
#include <utility>
#include <cmath>

using namespace std;

struct Node {
    pair<int,int> pos;
    double g_cost;
    double h_cost;
    double f_cost;
    Node* parent;

    Node(pair<int,int> pos_, double g_cost_, double h_cost_) {
        pos = pos_;
        g_cost = g_cost_;
        h_cost = h_cost_;
        f_cost = g_cost + h_cost;
        parent = nullptr;
    }

    bool operator<(const Node& other) const {
        return f_cost < other.f_cost;
    }
};

struct Compare {
    bool operator()(Node* a, Node* b) const {
        return a->f_cost > b->f_cost;
    }
};

class AStar {
public:
    vector<Node*> open;
    vector<pair<int,int>> visited;
    vector<vector<int>> map_grid;
    Node* start_node;
    Node* goal_node;

    AStar(const vector<vector<int>>& map_grid_, Node* start_node_, Node* goal_node_) {
        map_grid = map_grid_;
        start_node = start_node_;
        goal_node = goal_node_;
    }

    pair<vector<pair<int,int>>, double>* search() {
        // put start_node
        open.push_back(start_node);
        push_heap(open.begin(), open.end(), Compare());

        while (!open.empty()) {
            // get
            pop_heap(open.begin(), open.end(), Compare());
            Node* current_node = open.back();
            open.pop_back();

            if (pos_in_visited(current_node->pos)) {
                continue;
            }

            visited.push_back(current_node->pos);

            if (current_node->pos == goal_node->pos) {
                if (current_node->parent != nullptr) {
                    cout << "Reached goal node: (" << current_node->parent->pos.first << ", " << current_node->parent->pos.second << ")" << endl;
                } else {
                    cout << "Reached goal node: (None)" << endl;
                }
                auto result = new pair<vector<pair<int,int>>, double>(reconstruct_path(current_node), current_node->f_cost);
                return result;
            }

            vector<Node*> neighbors = get_neighbors(current_node);

            for (Node* neighbor : neighbors) {
                if (pos_in_visited(neighbor->pos)) {
                    continue;
                }

                double g_cost = current_node->g_cost + map_grid[neighbor->pos.first][neighbor->pos.second];
                double h_cost = heuristic(neighbor);

                Node* existing_node = find_node_in_open(neighbor);
                if (existing_node) {
                    if (g_cost < existing_node->g_cost) {
                        update_node(existing_node, g_cost, h_cost, current_node);
                    }
                } else {
                    update_node(neighbor, g_cost, h_cost, current_node);
                    open.push_back(neighbor);
                    push_heap(open.begin(), open.end(), Compare());
                }
            }
        }

        return nullptr;
    }

    Node* find_node_in_open(Node* node) {
        for (Node* n : open) {
            if (n->pos == node->pos) {
                return n;
            }
        }
        return nullptr;
    }

    vector<Node*> get_neighbors(Node* node) {
        vector<vector<int>> dirs = { {1,0}, {0,1}, {-1,0}, {0,-1} };
        vector<Node*> neighbors;

        for (auto dir : dirs) {
            pair<int,int> neighbor_pos = make_pair(node->pos.first + dir[0], node->pos.second + dir[1]);

            if ((0 <= neighbor_pos.first && neighbor_pos.first < (int)map_grid.size()) &&
                (0 <= neighbor_pos.second && neighbor_pos.second < (int)map_grid[0].size())) {

                if (map_grid[neighbor_pos.first][neighbor_pos.second] != -1) {
                    neighbors.push_back(new Node(neighbor_pos, 0, 0));
                }
            }
        }

        return neighbors;
    }

    double heuristic(Node* node) {
        double d = abs(node->pos.first - goal_node->pos.first) + abs(node->pos.second - goal_node->pos.second);
        return d;
    }

    vector<pair<int,int>> reconstruct_path(Node* goal_node_) {
        vector<pair<int,int>> path;
        path.push_back(goal_node_->pos);
        Node* current = goal_node_;

        while (current->parent->pos != start_node->pos) {
            cout << "Backtracking from node: (" << current->pos.first << ", " << current->pos.second << ") to parent: (" 
                 << current->parent->pos.first << ", " << current->parent->pos.second << ") with f_cost: " << current->f_cost << endl;
            path.push_back(current->parent->pos);
            current = current->parent;
        }

        path.push_back(start_node->pos);
        reverse(path.begin(), path.end());
        return path;
    }

    void update_node(Node* node, double g_cost, double h_cost, Node* current_node) {
        node->g_cost = g_cost;
        node->h_cost = h_cost;
        node->f_cost = g_cost + h_cost;
        node->parent = current_node;
    }

private:
    bool pos_in_visited(const pair<int,int>& p) {
        for (auto v : visited) {
            if (v == p) return true;
        }
        return false;
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
        for (const auto& val : row) {
            cout << val << " ";
        }
        cout << endl;
    }

    Node* start_node = new Node(make_pair(0,0), 0, 0);
    Node* goal_node = new Node(make_pair(9,9), 0, 0);

    AStar astar(map_grid, start_node, goal_node);
    auto path = astar.search();
    if (path) {
        cout << "Path found:" << endl;
        for (auto p : path->first) {
            cout << "(" << p.first << ", " << p.second << ")" << endl;
        }
    } else {
        cout << "No path found." << endl;
    }

    return 0;
}
// Model: gpt-5-mini
// Temperature: 1
// Response Time: 58632 ms
// Timestamp: 9/13/2025, 9:29:46 PM
// Prompt Tokens: 1520
// Completion Tokens: 4454
// Total Tokens: 5974
// Cost: $0.0093