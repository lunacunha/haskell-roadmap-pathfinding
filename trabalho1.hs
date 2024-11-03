import qualified Data.List 
import qualified Data.Array
import qualified Data.Bits

-- PFL 2024/2025 Practical assignment 1

-- Uncomment the some/all of the first three lines to import the modules, do not change the code of these lines.

type City = String
type Path = [City]
type Distance = Int

type RoadMap = [(City,City,Distance)]

-- Function 1
-- This function takes a RoadMap and returns a list of unique cities involved in the road map
cities :: RoadMap -> [City]
cities road_map = Data.List.nub [city | (c1,c2,_) <- road_map , city <- [c1,c2]] 


-- Function 2 
-- This function checks if two cities are adjacent in the given RoadMap.
-- It returns True if there is a direct road between city1 and city2; otherwise, it returns False.
areAdjacent :: RoadMap -> City -> City -> Bool
areAdjacent road_map city1 city2 = any is_adjacent road_map
  where
    is_adjacent (c1, c2, _) = (c1 == city1 && c2 == city2) || (c1 == city2 && c2 == city1)


-- Function 3
-- This function calculates the distance between two cities in the RoadMap.
-- If a direct road exists between them, it returns Just the distance; otherwise, it returns Nothing.
distance :: RoadMap -> City -> City -> Maybe Distance
distance [] _ _ = Nothing
distance ((c1,c2,d):xs) city1 city2
    | (c1 == city1 && c2 == city2) || (c1 == city2 && c2 == city1) = Just (d)
    | otherwise = distance xs city1 city2


-- Function 4
-- This function returns a list of cities that are directly adjacent to a given city, along with the distances to those cities from the provided city.
adjacent :: RoadMap -> City -> [(City,Distance)]
adjacent [] _ = []
adjacent ((c1, c2, d):xs) city 
    | (c1 == city) = [(c2, d)] ++ adjacent xs city
    | (c2 == city) = [(c1, d)] ++ adjacent xs city
    | otherwise = adjacent xs city 


-- Function 5
-- This function computes the total distance of a given path in the RoadMap.
-- If the path is valid, it returns Just the total distance; otherwise, it returns Nothing.
pathDistance :: RoadMap -> Path -> Maybe Distance
pathDistance _ [] = Just 0
pathDistance _ [_] = Just 0
pathDistance road_map (c1:c2:xs) = do
    dist <- distance road_map c1 c2
    rest <- pathDistance road_map (c2:xs) -- rest of the distances in the path
    return (dist + rest)

   
-- Function 6
-- This function returns a list of cities with the highest degree (most connections) in the provided RoadMap.
rome :: RoadMap -> [City]
rome road_map = [city | city <- cities road_map, length (adjacent road_map city) == highest_degree]
  where
    highest_degree = maximum [length (adjacent road_map city) | city <- cities road_map] -- maximum em vez de max porque maximum retorna o valor máx de uma lista


-- Function 7
-- This function checks if the RoadMap is strongly connected, meaning every city can be reached from any other city.
isStronglyConnected :: RoadMap -> Bool
isStronglyConnected road_map =
    let all_cities = cities road_map
    in not (null all_cities) && allReachable all_cities road_map

-- This helper function checks if all cities can be reached from each city in the list.
allReachable :: [City] -> RoadMap -> Bool
allReachable cities road_map =
    all (\city -> length (reachable road_map city) == length cities) cities -- if you can reach every city from a city

-- This function returns a list of cities that can be reached from a given city using Depth-First Search (DFS).
reachable :: RoadMap -> City -> [City]
reachable road_map city = dfs road_map city []

-- This is a helper function for performing Depth-First Search on the RoadMap.
dfs :: RoadMap -> City -> [City] -> [City]
dfs road_map city visited_cities
 | city `elem` visited_cities = visited_cities -- no need to visit city again
 | otherwise = foldl (\acc (adj_city, _) -> dfs road_map adj_city acc) (city : visited_cities) (adjacent road_map city)


-- Function 8
-- This function finds all shortest paths between two cities in the RoadMap.
-- It returns a list of paths that have the minimum distance.
shortestPath :: RoadMap -> City -> City -> [Path]
shortestPath road_map start_city end_city =
    let all_paths = shortestPathHelper road_map start_city end_city
        valid_paths = filter (\p -> pathDistance road_map p /= Nothing) all_paths  -- only valid paths
        min_dist = minimum [d | Just d <- map (pathDistance road_map) valid_paths]  -- min distance
    in filter (\p -> pathDistance road_map p == Just min_dist) valid_paths  -- only paths with min distance

-- This helper function performs a breadth-first search (BFS) to find all paths from the start city to the end city in the RoadMap.
shortestPathHelper :: RoadMap -> City -> City -> [Path]
shortestPathHelper road_map start end = bfs [([start], 0)]
  where
    bfs [] = []
    bfs ((current_path, current_dist) : remaining_paths)
      | last current_path == end = current_path : bfs remaining_paths
      | otherwise = bfs (remaining_paths ++ next_paths)
      where
        next_cities = [(city, d) | (city, d) <- adjacent road_map (last current_path), city `notElem` current_path]
        next_paths = [(current_path ++ [next_city], current_dist + d) | (next_city, d) <- next_cities]


-- Function 9
-- This function finds the closest unvisited city from the current city.
-- It returns Just the closest city and its distance or Nothing if there are no unvisited neighbors.
closestUnvisitedCity :: RoadMap -> City -> [City] -> Maybe (City, Distance)
closestUnvisitedCity road_map current_city visited_cities =
    let unvisited_neighbors = [(city, dist) | (city, dist) <- adjacent road_map current_city, city `notElem` visited_cities]
    in if null unvisited_neighbors 
       then Nothing 
       else Just (Data.List.minimumBy (\(_, d1) (_, d2) -> compare d1 d2) unvisited_neighbors)

-- This helper function assists in the traveling salesman problem by recursively finding a path that visits all unvisited cities starting from a current city.
travelSalesHelper :: RoadMap -> City -> [City] -> Path -> Distance -> Maybe (Path, Distance)
travelSalesHelper _ _ [] path total_distance = Just (reverse path, total_distance)  
travelSalesHelper road_map current_city unvisitedCities path total_distance =
    case closestUnvisitedCity road_map current_city path of  
        Nothing -> Just (reverse path, total_distance) 
        Just (next_city, dist) -> travelSalesHelper road_map next_city (filter (/= next_city) unvisitedCities) (next_city : path) (total_distance + dist)

-- This function finds a path for the traveling salesman problem starting from a given city.
-- It returns a path that visits all cities and returns to the starting city.
travelSalesFromStartCity :: RoadMap -> City -> Path
travelSalesFromStartCity road_map start_city =
    let unvisitedCities = filter (/= start_city) (cities road_map)  
        all_paths = travelSalesHelper road_map start_city unvisitedCities [start_city] 0
    in case all_paths of
        Nothing -> []  -- no valid paths
        Just (path, total_distance) -> path ++ [start_city]  -- return to start city

-- This function finds a path for the traveling salesman problem from any city in the RoadMap.
-- If the RoadMap is not strongly connected, it returns an empty path.
travelSales :: RoadMap -> Path
travelSales road_map
    | not (isStronglyConnected road_map) = []  
    | otherwise =
        let valid_paths = filter (not . null) (map (travelSalesFromStartCity road_map) (cities road_map))
        in case valid_paths of
            (first_path:_) -> first_path  -- first valid path
            [] -> []  -- no valid paths


-- function 10
tspBruteForce :: RoadMap -> Path
tspBruteForce = undefined -- only for groups of 3 people; groups of 2 people: do not edit this function

-- Some graphs to test your work
gTest1 :: RoadMap
gTest1 = [("7","6",1),("8","2",2),("6","5",2),("0","1",4),("2","5",4),("8","6",6),("2","3",7),("7","8",7),("0","7",8),("1","2",8),("3","4",9),("5","4",10),("1","7",11),("3","5",14)]

gTest2 :: RoadMap
gTest2 = [("0","1",10),("0","2",15),("0","3",20),("1","2",35),("1","3",25),("2","3",30)]

gTest3 :: RoadMap -- unconnected graph
gTest3 = [("0","1",4),("2","3",2)] 


