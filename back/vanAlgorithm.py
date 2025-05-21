def manhattan_distance(start, goal):
    dx = abs(start[0] - goal[0])
    dy = abs(start[1] - goal[1])
    return dx + dy

def get_neighbors(node, valid_nodes):
    directions = [(-1, 0), (1, 0), (0, -1), (0, 1)]
    neighbors = []
    for dx, dy in directions:
        neighbor = (node[0] + dx, node[1] + dy)
        if neighbor in valid_nodes:
            neighbors.append(neighbor)
    return neighbors

def a_star(start, goal, valid_nodes, traffic_penalties, road_costs):
    open_set = {start: (0, manhattan_distance(start, goal))}
    came_from = {}
    g_score = {start: 0}

    while open_set:
        current = min(open_set, key=lambda x: open_set[x][1])
        if current == goal:
            path = []
            while current in came_from:
                path.append(current)
                current = came_from[current]
            path.append(start)
            return path[::-1]

        del open_set[current]

        for neighbor in get_neighbors(current, valid_nodes):
            road_weight = road_costs.get((current, neighbor), 1)  # si no se sabe el costo, se asume 1
            traffic_penalty = traffic_penalties.get((current, neighbor), 0) # si no hay trafico, se asume 0

            # Se le suma al costo el peso del camino y la penalizacion por trafico
            cost = road_weight + traffic_penalty

            # El costo tentativo es la suma del costo y el g_score del nodo actual

            tentative_g_score = g_score[current] + cost
            if neighbor not in g_score or tentative_g_score < g_score[neighbor]:
                came_from[neighbor] = current
                g_score[neighbor] = tentative_g_score
                f_score = tentative_g_score + manhattan_distance(neighbor, goal)
                open_set[neighbor] = (tentative_g_score, f_score)

    return "No se encontró un camino"

# Buscar nodos intermedios entre el trafico
def get_path_points(orig, dest):
    path = []
    x1, y1 = orig
    x2, y2 = dest
    if x1 == x2:
        step = 1 if y2 > y1 else -1 # 1 si va hacia abajo, -1 si va hacia arriba
        for y in range(y1, y2, step):
            path.append((x1, y))
        path.append(dest)
    elif y1 == y2:
        step = 1 if x2 > x1 else -1 # 1 si va hacia la derecha, -1 si va hacia la izquierda
        for x in range(x1, x2, step):
            path.append((x, y1))
        path.append(dest)
    else:
        # SIN DIAGONALES
        raise ValueError("Solo soporta rutas horizontales o verticales")
    return path

import json

# Cargar JSON
with open("mapa.json") as f:
    data = json.load(f)

map_data = data["map"]
trip = data["trip"]

#print("Datos del mapa:", map_data)
#print("Datos del viaje:", trip)

# Set nodos validos 

valid_nodes = set()

for road_type in ["highways", "avenues", "streets"]:
    for coord in data["map"]["roads"][road_type]:
        valid_nodes.add(tuple(coord))

for place in data["map"]["places"]:
    valid_nodes.add(tuple(place["coords"]))

road_weights = {
    "highways": 1,
    "avenues": 2,
    "streets": 3
}
# Asignar pesos a los nodos

road_costs = {}

for road_type, nodes in map_data["roads"].items():
    for i in range(len(nodes) - 1):
        start = tuple(nodes[i]) # Va conectando los nodos
        end = tuple(nodes[i+1])
        cost = road_weights[road_type]

        road_costs[(start, end)] = cost
        road_costs[(end, start)] = cost

traffic_penalties = {}

for t in map_data.get("traffic", []):
    orig = tuple(t["origin"])
    dest = tuple(t["destination"])

    penalty = t["rate"] # Se extrae del JSON el peso de las zonas de trafico
    path_points = get_path_points(orig, dest) # Consigue los puntos intermedios

    for i in range(len(path_points) - 1):  # Añade el peso a cada punto intermedio
        a = path_points[i]
        b = path_points[i + 1]
        traffic_penalties[(a, b)] = penalty
        traffic_penalties[(b, a)] = penalty  # bidireccional

# Coordenadas de inicio y destino

start = tuple(trip["origin"])
goal = tuple(trip["destination"])

# Usar A star para encontrar el camino
path = a_star(start, goal, valid_nodes, traffic_penalties, road_costs)

#print("Camino encontrado:", path)
