pub type Coords {
  Coords(x: Int, y: Int)
}

pub fn add(node1: Coords, node2: Coords) {
  Coords(node1.x + node2.x, node1.y + node2.y)
}

pub fn minus(node1: Coords, node2: Coords) {
  Coords(node1.x - node2.x, node1.y - node2.y)
}
