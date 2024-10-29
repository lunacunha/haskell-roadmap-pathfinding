import qualified Data.List
--import qualified Data.Array
import qualified Data.Bits

-- PFL 2024/2025 Practical assignment 1

-- Uncomment the some/all of the first three lines to import the modules, do not change the code of these lines.

type City = String
type Path = [City]
type Distance = Int

type RoadMap = [(City,City,Distance)]


-- função 1 (100% testada)
cities :: RoadMap -> [City]
cities road_map = Data.List.nub [city | (c1,c2,_) <- road_map , city <- [c1,c2]] -- nub porque temos de tirar os duplicados


-- temos de verificar sempre para os dois lados porque é undirected

-- função 2 (SEMI TESTADA)
areAdjacent :: RoadMap -> City -> City -> Bool
areAdjacent [] _ _ = False
areAdjacent ((c1, c2, _):xs) city1 city2 -- temos de pôr (c1,c2,_) porque queremos comparar elementos especificos do tuplo
    | (c1 == city1 && c2 == city2) || (c1 == city2 && c2 == city1) = True
    | otherwise = areAdjacent xs city1 city2


-- função 3 (SEMI TESTADA)
distance :: RoadMap -> City -> City -> Maybe Distance
distance [] _ _ = Nothing
distance ((c1,c2,d):xs) city1 city2
    | (c1 == city1 && c2 == city2) || (c1 == city2 && c2 == city1) = Just (d)
    | otherwise = distance xs city1 city2


-- função 4 (SEMI TESTADA)
adjacent :: RoadMap -> City -> [(City,Distance)]
adjacent [] _ = []
adjacent ((c1, c2, d):xs) city 
    | (c1 == city) = [(c2, d)] ++ adjacent xs city
    | (c2 == city) = [(c1, d)] ++ adjacent xs city
    | otherwise = adjacent xs city 


-- função 5 (SEMI TESTADA)
pathDistance :: RoadMap -> Path -> Maybe Distance
pathDistance _ [] = Just 0
pathDistance _ [_] = Just 0
pathDistance [] _ = Nothing
pathDistance road_map (c1:c2:xs) =  -- temos de pôr duas cidades pq temos de ver a distancia
    if distance road_map c1 c2 == Nothing || pathDistance road_map (c2:xs) == Nothing 
    then Nothing 
    else Just (dist + rest)
    where
        Just dist = distance road_map c1 c2  -- distância entre c1 e c2
        Just rest = pathDistance road_map (c2:xs)  -- distância restante do caminho (recursão)

   
-- função 6 (SEMI TESTADA)
rome :: RoadMap -> [City]
rome road_map = [city | city <- cities road_map, length (adjacent road_map city) == highest_degree]
  where
    highest_degree = maximum [length (adjacent road_map city) | city <- cities road_map] -- maximum em vez de max porque maximum retorna o valor máx de uma lista


-- função 7 (testada)
isStronglyConnected :: RoadMap -> Bool
isStronglyConnected road_map = 
    case cities road_map of
        [] -> True  -- um grafo vazio é conectado
        (first_city:_) ->
            let reachable_from_first = reachable road_map first_city
                total_cities = length (cities road_map)
            in length reachable_from_first == total_cities  


dfs :: RoadMap -> City -> [City] -> [City]
dfs road_map city visited_cities
 | city `elem` visited_cities = visited_cities
 | otherwise = foldl (\acc (adj_city, _) -> dfs road_map adj_city acc) (city : visited_cities) (adjacent road_map city)

-- função para chegar a todas as reachable cities a partir de uma determinada city
reachable :: RoadMap -> City -> [City]
reachable road_map city = dfs road_map city []


-- função 8 (semi testada)
shortestPath :: RoadMap -> City -> City -> [Path]
shortestPath road_map start_city end_city =
    let all_paths = bfsDijkstra road_map start_city end_city
        valid_paths = filter (\p -> pathDistance road_map p /= Nothing) all_paths  -- só paths válidos
        min_dist = minimum [d | Just d <- map (pathDistance road_map) valid_paths]  -- distância + pequena
    in filter (\p -> pathDistance road_map p == Just min_dist) valid_paths  -- só paths com a distância min

-- bfs + dijkstra (porque as edges têm pesos diferentes)
bfsDijkstra :: RoadMap -> City -> City -> [Path]
bfsDijkstra road_map start end = bfs [[start]]
  where
    bfs [] = []  -- não há mais paths
    bfs (current_path:remaining_paths)
      | last current_path == end = current_path : bfs remaining_paths
      | otherwise = bfs (remaining_paths ++ next_paths)
      where
        next_cities = [city | (city, _) <- adjacent road_map (last current_path), city `notElem` current_path]
        next_paths = [current_path ++ [next_city] | next_city <- next_cities]


-- função 9
travelSales :: RoadMap -> Path
travelSales road_map = 
    let all_cities = cities road_map
        all_routes = Data.List.permutations all_cities
        valid_routes = filter (isValidRoute road_map) all_routes
    in if null valid_routes 
       then []  -- no valid routes
       else let distances = map (pathDistance road_map) valid_routes
                min_route = Data.List.minimumBy compareDistance (zip valid_routes distances)
            in fst min_route


-- checks if route is valid
isValidRoute :: RoadMap -> Path -> Bool
isValidRoute road_map route = 
    all (\(c1, c2) -> areAdjacent road_map c1 c2) (zip route (drop 1 route))


-- compare routes (distances)
compareDistance :: (Path, Maybe Distance) -> (Path, Maybe Distance) -> Ordering
compareDistance (_, Nothing) (_, Nothing) = EQ
compareDistance (_, Just _) (_, Nothing) = LT
compareDistance (_, Nothing) (_, Just _) = GT
compareDistance (_, Just d1) (_, Just d2) = compare d1 d2


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