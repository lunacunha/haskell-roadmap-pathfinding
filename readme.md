# RoadMap Path Finding - Haskell Assignment

### Overview
This Haskell program implements various graph algorithms for analyzing road maps and finding optimal paths between cities. The RoadMap is represented as an undirected weighted graph where cities are nodes and roads are edges with associated distances.

### Data Types
```haskell
type City = String
type Path = [City]
type Distance = Int
type RoadMap = [(City, City, Distance)]
```

A RoadMap is a list of tuples where each tuple represents a bidirectional road between two cities with a given distance.

### Functions

#### 1. `cities :: RoadMap -> [City]`
Returns a list of all unique cities present in the road map.

**Example:**
```haskell
cities gTest1 
-- Returns: ["7","6","8","2","5","0","1","3","4"]
```

#### 2. `areAdjacent :: RoadMap -> City -> City -> Bool`
Checks if two cities are directly connected by a road.

**Example:**
```haskell
areAdjacent gTest1 "0" "1"  -- Returns: True
areAdjacent gTest1 "0" "4"  -- Returns: False
```

#### 3. `distance :: RoadMap -> City -> City -> Maybe Distance`
Returns the distance between two adjacent cities. Returns `Nothing` if no direct road exists.

**Example:**
```haskell
distance gTest1 "0" "1"  -- Returns: Just 4
distance gTest1 "0" "4"  -- Returns: Nothing
```

#### 4. `adjacent :: RoadMap -> City -> [(City, Distance)]`
Returns all cities directly connected to a given city along with their distances.

**Example:**
```haskell
adjacent gTest1 "0"  
-- Returns: [("1",4),("7",8)]
```

#### 5. `pathDistance :: RoadMap -> Path -> Maybe Distance`
Calculates the total distance of a given path. Returns `Nothing` if the path is invalid (contains non-adjacent cities).

**Example:**
```haskell
pathDistance gTest1 ["0","1","2"]  -- Returns: Just 12
pathDistance gTest1 ["0","4"]      -- Returns: Nothing
```

#### 6. `rome :: RoadMap -> [City]`
Returns all cities with the maximum number of connections (highest degree). Named after the saying "all roads lead to Rome."

**Example:**
```haskell
rome gTest1  
-- Returns cities with the most connections
```

#### 7. `isStronglyConnected :: RoadMap -> Bool`
Checks if the road map is strongly connected, meaning every city can be reached from every other city.

**Implementation:** Uses Depth-First Search (DFS) to verify that all cities are reachable from each city.

**Example:**
```haskell
isStronglyConnected gTest1  -- Returns: True
isStronglyConnected gTest3  -- Returns: False (disconnected graph)
```

#### 8. `shortestPath :: RoadMap -> City -> City -> [Path]`
Finds all shortest paths between two cities using Breadth-First Search (BFS). Returns all paths with the minimum distance.

**Example:**
```haskell
shortestPath gTest1 "0" "4"
-- Returns all paths from "0" to "4" with minimum distance
```

#### 9. `travelSales :: RoadMap -> Path`
Solves the Traveling Salesman Problem using a greedy nearest-neighbor approach. Returns a path that visits all cities and returns to the starting city.

**Algorithm:** 
- Starts from an arbitrary city
- Repeatedly visits the closest unvisited neighbor
- Returns to the starting city

**Note:** This is a heuristic solution and may not always find the optimal path.

**Example:**
```haskell
travelSales gTest1
-- Returns a path visiting all cities (may not be optimal)
```

**Returns empty path if graph is not strongly connected:**
```haskell
travelSales gTest3  -- Returns: []
```

#### 10. `tspBruteForce :: RoadMap -> Path`
**(For groups of 3 students only)**
This function should implement a brute-force solution to find the optimal TSP path by checking all possible permutations.

### Test Graphs

#### gTest1
A connected graph with 9 cities and 14 roads:
```haskell
gTest1 = [("7","6",1),("8","2",2),("6","5",2),("0","1",4),("2","5",4),
          ("8","6",6),("2","3",7),("7","8",7),("0","7",8),("1","2",8),
          ("3","4",9),("5","4",10),("1","7",11),("3","5",14)]
```

#### gTest2
A fully connected graph with 4 cities:
```haskell
gTest2 = [("0","1",10),("0","2",15),("0","3",20),
          ("1","2",35),("1","3",25),("2","3",30)]
```

#### gTest3
A disconnected graph for testing:
```haskell
gTest3 = [("0","1",4),("2","3",2)]
```

### Dependencies
```haskell
import qualified Data.List
import qualified Data.Array
import qualified Data.Bits
```

### Usage

Load the file in GHCi:
```bash
ghci YourFileName.hs
```

Run functions with test graphs:
```haskell
cities gTest1
shortestPath gTest1 "0" "4"
travelSales gTest2
```

### Implementation Notes

- All roads are **bidirectional** (undirected graph)
- The `travelSales` function uses a **greedy approach** (nearest neighbor heuristic)
- Empty paths `[]` are returned for invalid scenarios (e.g., disconnected graphs in TSP)
- Helper functions use DFS and BFS for graph traversal
- The implementation prioritizes clarity and correctness over performance optimization

### Algorithms Used

- **DFS (Depth-First Search):** For connectivity checking
- **BFS (Breadth-First Search):** For finding shortest paths
- **Greedy Nearest Neighbor:** For TSP approximation

--

#### Practical Assignment 1 - PFL 2024/2025
