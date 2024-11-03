import qualified Data.List 
--import qualified Data.Array
import qualified Data.Bits

-- PFL 2024/2025 Practical assignment 1

-- Uncomment the some/all of the first three lines to import the modules, do not change the code of these lines.

type City = String
type Path = [City]
type Distance = Int

type RoadMap = [(City,City,Distance)]

type AdjList = [(City, [(City, Distance)])]


-- function 1 (100% tested) - O(m + n^2)
cities :: RoadMap -> [City]
cities road_map = Data.List.nub [city | (c1,c2,_) <- road_map , city <- [c1,c2]] 


-- function 2 (semi tested) - O(m)
areAdjacent :: RoadMap -> City -> City -> Bool
areAdjacent road_map city1 city2 = any is_adjacent road_map
  where
    is_adjacent (c1, c2, _) = (c1 == city1 && c2 == city2) || (c1 == city2 && c2 == city1)


-- function 3 (semi tested) - O(m)
distance :: RoadMap -> City -> City -> Maybe Distance
distance [] _ _ = Nothing
distance ((c1,c2,d):xs) city1 city2
    | (c1 == city1 && c2 == city2) || (c1 == city2 && c2 == city1) = Just (d)
    | otherwise = distance xs city1 city2


-- function 4 (semi tested) - O(m)
adjacent :: RoadMap -> City -> [(City,Distance)]
adjacent [] _ = []
adjacent ((c1, c2, d):xs) city 
    | (c1 == city) = [(c2, d)] ++ adjacent xs city
    | (c2 == city) = [(c1, d)] ++ adjacent xs city
    | otherwise = adjacent xs city 


-- function 5 (semi tested) - O(n * E)
pathDistance :: RoadMap -> Path -> Maybe Distance
pathDistance _ [] = Just 0
pathDistance _ [_] = Just 0
pathDistance road_map (c1:c2:xs) = do
    dist <- distance road_map c1 c2
    rest <- pathDistance road_map (c2:xs) -- rest of the distances in the path
    return (dist + rest)

   
-- function 6 (semi tested) - O(n * m)
rome :: RoadMap -> [City]
rome road_map = [city | city <- cities road_map, length (adjacent road_map city) == highest_degree]
  where
    highest_degree = maximum [length (adjacent road_map city) | city <- cities road_map] -- maximum em vez de max porque maximum retorna o valor máx de uma lista


-- function 7 (tested) - O(n^2 + n * m)
isStronglyConnected :: RoadMap -> Bool
isStronglyConnected road_map =
    let all_cities = cities road_map
    in not (null all_cities) && allReachable all_cities road_map

allReachable :: [City] -> RoadMap -> Bool
allReachable cities road_map =
    all (\city -> length (reachable road_map city) == length cities) cities -- if you can reach every city from a city

reachable :: RoadMap -> City -> [City]
reachable road_map city = dfs road_map city []

dfs :: RoadMap -> City -> [City] -> [City]
dfs road_map city visited_cities
 | city `elem` visited_cities = visited_cities -- no need to visit city again
 | otherwise = foldl (\acc (adj_city, _) -> dfs road_map adj_city acc) (city : visited_cities) (adjacent road_map city)


-- function 8 (semi tested) - O((V + E) * log V + P)
shortestPath :: RoadMap -> City -> City -> [Path]
shortestPath road_map start_city end_city =
    let all_paths = shortestPathHelper road_map start_city end_city
        valid_paths = filter (\p -> pathDistance road_map p /= Nothing) all_paths  -- only valid paths
        min_dist = minimum [d | Just d <- map (pathDistance road_map) valid_paths]  -- min distance
    in filter (\p -> pathDistance road_map p == Just min_dist) valid_paths  -- only paths with min distance

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


-- função 9
-- finds the closest city not visited
closestUnvisitedCity :: RoadMap -> City -> [City] -> Maybe (City, Distance)
closestUnvisitedCity road_map current_city visited_cities =
    let unvisited_neighbors = [(city, dist) | (city, dist) <- adjacent road_map current_city, city `notElem` visited_cities]
    in if null unvisited_neighbors 
       then Nothing 
       else Just (Data.List.minimumBy (\(_, d1) (_, d2) -> compare d1 d2) unvisited_neighbors)

-- greedy approach - auxiliary function
travelSalesHelper :: RoadMap -> City -> [City] -> Path -> Distance -> [(Path, Distance)]
travelSalesHelper _ _ [] path totalDist = [(reverse path, totalDist)]  -- No more cities to go through
travelSalesHelper r currentCity unvisitedCities path totalDist =
    case closestUnvisitedCity r currentCity path of
        Nothing -> [(reverse path, totalDist)]  -- No more unvisited cities, return the current path
        Just (nextCity, dist) -> 
            let newPath = nextCity : path
            in travelSalesHelper r nextCity (filter (/= nextCity) unvisitedCities) newPath (totalDist + dist)

-- TSP from a start city
travelSalesFromStartCity :: RoadMap -> City -> Path
travelSalesFromStartCity road_map start_city =
    let unvisitedCities = filter (/= start_city) (cities road_map)  -- Compute once
        all_paths = travelSalesHelper road_map start_city unvisitedCities [start_city] 0
        valid_paths = filter (\(_, dist) -> dist /= maxBound) all_paths
    in case valid_paths of
        [] -> []
        _  -> let (path, total_distance) = Data.List.minimumBy (\(_, d1) (_, d2) -> compare d1 d2) valid_paths
              in case distance road_map (last path) start_city of
                    Nothing -> []
                    Just dist -> path ++ [start_city]  -- goes back to start city

-- TSP from different start cities
travelSales :: RoadMap -> Path
travelSales road_map
    | not (isStronglyConnected road_map) = []  
    | otherwise =
        let valid_paths = filter (not . null) (map (travelSalesFromStartCity road_map) (cities road_map))
        in case valid_paths of
            (first_path:_) -> first_path -- first valid path
            [] -> []

-- função 10
tspBruteForce :: RoadMap -> Path
tspBruteForce = undefined -- only for groups of 3 people; groups of 2 people: do not edit this function

-- Some graphs to test your work
gTest1 :: RoadMap
gTest1 = [("7","6",1),("8","2",2),("6","5",2),("0","1",4),("2","5",4),("8","6",6),("2","3",7),("7","8",7),("0","7",8),("1","2",8),("3","4",9),("5","4",10),("1","7",11),("3","5",14)]

gTest2 :: RoadMap
gTest2 = [("0","1",10),("0","2",15),("0","3",20),("1","2",35),("1","3",25),("2","3",30)]

gTest3 :: RoadMap -- unconnected graph
gTest3 = [("0","1",4),("2","3",2)] 

gTest4 ::RoadMap
gTest4 = [("0", "1", 1), ("1", "3", 1), ("2", "3", 1),("0","2",1)]

