# Practical Assignment 1 - PFL 2024/2025

## Group Members and Contributions
- **Luna Cunha (up202205714)**: Contribution 50%
  - Functions Implemented: `cities`, `areAdjacent`, `rome`, `isStronglyConnected`, `shortestPath`.
- **Rodrigo Araújo (up202205515)**: Contribution 50%
  -  Functions Implemented: `distance`, `adjacent`, `pathDistance`, `travelSales`.


## Function Implementations

### Shortest Path (`shortestPath`)
The `shortestPath` function was implemented to find all paths between two cities and select the shortest. To achieve this, we used the following approach:
1. **Algorithm**: The function combines **Breadth-First Search (BFS)** with an adaptation of **Dijkstra’s Algorithm** for weighted paths. It explores all paths from the start city to the end city.
2. **Data Structures**:
   - `Path`: List of `City` strings representing a sequence of cities in a potential route.
   - `RoadMap`: A list of tuples, each containing two cities and the distance between them.
   - **Filtering**: Valid paths are determined by filtering out any paths with invalid distances.
   - **Memoization**: Auxiliary function `shortestPathHelper` uses BFS to store and track viable paths efficiently.
3. **Explanation**: BFS is used to maintain traversal order, while Dijkstra helps in assessing distances for shortest paths. These structures were selected for efficiency and simplicity, supporting optimized path selection and minimal redundant computation.


### Traveling Salesperson Problem (`travelSales`)
The `travelSales` function implements a greedy approximation approach to solve the Traveling Salesperson Problem (TSP) for strongly connected graphs:
1. **Algorithm**: Uses a **Nearest Neighbor** strategy. Starting from a given city, it iteratively selects the closest unvisited city until all cities are visited, then returns to the start city.
2. **Data Structures**:
   - **Recursive Path Storage**: `travelSalesHelper` tracks cities visited and accumulates distances to maintain path and distance information.
   - `RoadMap`, `Path`, and `Distance` are reused to store graph and path details effectively.
   - **Helper Function**: `closestUnvisitedCity` identifies the nearest city not yet visited, ensuring no unnecessary backtracking.
   - **Start Function**: `travelSalesFromStartCity` initializes the TSP solution by selecting a starting city and invoking the nearest neighbor strategy through `travelSalesHelper`.
3. **Explanation**: This structure, combined with memoization of visited paths, helps achieve an approximate solution for TSP with minimal computation. Although this approach doesn't guarantee the optimal TSP solution, it significantly reduces computational complexity while yielding a near-optimal path for strongly connected graphs.



### Testing Graphs

The following test graphs were used to validate function performance and accuracy:
- `gTest1`: a general graph with different weights and connectivity
- `gTest2`: a fully connected graph
- `gTest3`: an unconnected graph