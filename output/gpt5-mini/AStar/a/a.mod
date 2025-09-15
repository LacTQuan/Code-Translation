class DataPoint {
    int[] coordinates;
    double weight_a;
    double weight_b;
    double total_weight;

    DataPoint predecessor;

    DataPoint(int x, int y, double weight_a, double weight_b) {
        this.coordinates = new int[2];
        this.coordinates[0] = x;
        this.coordinates[1] = y;
        this.weight_a = weight_a;
        this.weight_b = weight_b;
        this.total_weight = this.weight_a + this.weight_b;
        this.predecessor = null;
    }

    boolean __lt__(DataPoint other) {
        return this.total_weight < other.total_weight;
    }
}

class PendingQueue {
    java.util.ArrayList<DataPoint> queue;

    PendingQueue() {
        this.queue = new java.util.ArrayList<DataPoint>();
    }

    void put(DataPoint dp) {
        this.queue.add(dp);
        // maintain priority by total_weight (ascending)
        java.util.Collections.sort(this.queue, new java.util.Comparator<DataPoint>() {
            public int compare(DataPoint a, DataPoint b) {
                if (a.total_weight < b.total_weight) return -1;
                if (a.total_weight > b.total_weight) return 1;
                return 0;
            }
        });
    }

    DataPoint get() {
        if (this.queue.size() == 0) return null;
        return this.queue.remove(0);
    }

    boolean empty() {
        return this.queue.size() == 0;
    }

    java.util.List<DataPoint> asList() {
        return new java.util.ArrayList<DataPoint>(this.queue);
    }
}

class BFS {
    PendingQueue pending_queue;
    java.util.ArrayList<int[]> processed;
    int[][] data_matrix;
    DataPoint initial_point;
    DataPoint target_point;

    BFS(int[][] data_matrix, DataPoint initial_point, DataPoint target_point) {
        this.pending_queue = new PendingQueue();
        this.processed = new java.util.ArrayList<int[]>();
        this.data_matrix = data_matrix;
        this.initial_point = initial_point;
        this.target_point = target_point;
    }

    Object execute() {
        this.pending_queue.put(this.initial_point);

        while (!this.pending_queue.empty()) {
            DataPoint current_element = this.pending_queue.get();
            boolean alreadyProcessed = false;
            for (int[] p : this.processed) {
                if (p[0] == current_element.coordinates[0] && p[1] == current_element.coordinates[1]) {
                    alreadyProcessed = true;
                    break;
                }
            }
            if (alreadyProcessed) {
                continue;
            }

            this.processed.add(new int[]{current_element.coordinates[0], current_element.coordinates[1]});

            if (current_element.coordinates[0] == this.target_point.coordinates[0] &&
                current_element.coordinates[1] == this.target_point.coordinates[1]) {
                java.util.List<int[]> seq = this.find_list(current_element);
                return new Object[]{seq, current_element.total_weight};
            }

            java.util.List<DataPoint> adjacent_elements = this.reverse_string(current_element);

            for (DataPoint element : adjacent_elements) {
                boolean wasProcessed = false;
                for (int[] p : this.processed) {
                    if (p[0] == element.coordinates[0] && p[1] == element.coordinates[1]) {
                        wasProcessed = true;
                        break;
                    }
                }
                if (wasProcessed) {
                    continue;
                }

                double weight_a = current_element.weight_a + this.data_matrix[element.coordinates[0]][element.coordinates[1]];
                double weight_b = this.swap_elements(element);

                DataPoint existing_element = this.calculate_sum(element);
                if (existing_element != null) {
                    if (weight_a < existing_element.weight_a) {
                        this.insert_element(existing_element, weight_a, weight_b, current_element);
                    }
                } else {
                    this.insert_element(element, weight_a, weight_b, current_element);
                    this.pending_queue.put(element);
                }
            }
        }

        return null;
    }

    DataPoint calculate_sum(DataPoint element) {
        for (DataPoint e : this.pending_queue.asList()) {
            if (e.coordinates[0] == element.coordinates[0] && e.coordinates[1] == element.coordinates[1]) {
                return e;
            }
        }
        return null;
    }

    java.util.List<DataPoint> reverse_string(DataPoint element) {
        int[][] directions = new int[][] { {1,0}, {0,1}, {-1,0}, {0,-1} };
        java.util.ArrayList<DataPoint> adjacent = new java.util.ArrayList<DataPoint>();

        for (int i = 0; i < directions.length; i++) {
            int[] direction = directions[i];
            int adj_x = element.coordinates[0] + direction[0];
            int adj_y = element.coordinates[1] + direction[1];

            if (0 <= adj_x && adj_x < this.data_matrix.length &&
                0 <= adj_y && adj_y < this.data_matrix[0].length) {

                if (this.data_matrix[adj_x][adj_y] != -1) {
                    adjacent.add(new DataPoint(adj_x, adj_y, 0.0, 0.0));
                }
            }
        }

        return adjacent;
    }

    double swap_elements(DataPoint element) {
        int distance = Math.abs(element.coordinates[0] - this.target_point.coordinates[0]) +
                       Math.abs(element.coordinates[1] - this.target_point.coordinates[1]);
        return distance;
    }

    java.util.List<int[]> find_list(DataPoint final_element) {
        java.util.ArrayList<int[]> sequence = new java.util.ArrayList<int[]>();
        sequence.add(new int[]{final_element.coordinates[0], final_element.coordinates[1]});
        DataPoint current = final_element;

        while (current.predecessor.coordinates[0] != this.initial_point.coordinates[0] ||
               current.predecessor.coordinates[1] != this.initial_point.coordinates[1]) {
            System.out.println("Tracing back from: " + "[" + current.coordinates[0] + "," + current.coordinates[1] + "] to predecessor: " +
                "[" + current.predecessor.coordinates[0] + "," + current.predecessor.coordinates[1] + "] with weight: " + current.total_weight);
            sequence.add(new int[]{current.predecessor.coordinates[0], current.predecessor.coordinates[1]});
            current = current.predecessor;
        }

        sequence.add(new int[]{this.initial_point.coordinates[0], this.initial_point.coordinates[1]});

        java.util.Collections.reverse(sequence);
        return sequence;
    }

    void insert_element(DataPoint element, double weight_a, double weight_b, DataPoint current_element) {
        element.weight_a = weight_a;
        element.weight_b = weight_b;
        element.total_weight = weight_a + weight_b;
        element.predecessor = current_element;
    }
}

class Main {
    public static void main(String[] args) {
        int[][] map_grid = new int[][] {
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

        System.out.println("Map Grid:");
        for (int i = 0; i < map_grid.length; i++) {
            StringBuilder sb = new StringBuilder();
            sb.append("[");
            for (int j = 0; j < map_grid[i].length; j++) {
                sb.append(map_grid[i][j]);
                if (j < map_grid[i].length - 1) sb.append(", ");
            }
            sb.append("]");
            System.out.println(sb.toString());
        }

        DataPoint start_node = new DataPoint(0, 0, 0.0, 0.0);
        DataPoint goal_node = new DataPoint(9, 9, 0.0, 0.0);

        BFS bfs = new BFS(map_grid, start_node, goal_node);
        Object result = bfs.execute();
        if (result != null) {
            Object[] resArr = (Object[]) result;
            java.util.List<int[]> path = (java.util.List<int[]>) resArr[0];
            System.out.println("Path found:");
            for (int[] p : path) {
                System.out.println("[" + p[0] + ", " + p[1] + "]");
            }
        } else {
            System.out.println("No path found.");
        }
    }
}
-- Model: gpt-5-mini
-- Temperature: 1
-- Response Time: 55176 ms
-- Timestamp: 9/12/2025, 10:24:35 PM
-- Prompt Tokens: 1514
-- Completion Tokens: 3317
-- Total Tokens: 4831
-- Cost: $0.0070