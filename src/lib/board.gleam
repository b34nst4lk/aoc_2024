import gleam/set.{type Set}

pub type Coords {
  Coords(x: Int, y: Int)
}

pub fn move(player: Coords, direction: Coords) {
  Coords(player.x + direction.x, player.y + direction.y)
}

pub type Board {
  Board(
    obstacles: Set(Coords),
    player: Coords,
    direction: Coords,
    width: Int,
    height: Int,
  )
}

pub fn new() {
  Board(set.new(), Coords(0, 0), Coords(0, 1), 0, 0)
}

pub fn add_obstacle(board: Board, obstacle: Coords) {
  Board(..board, obstacles: set.insert(board.obstacles, obstacle))
}

pub fn update_dimensions(board: Board, width: Int, height: Int) {
  Board(..board, width: width, height: height)
}

pub fn update_player(board: Board, player: Coords) {
  Board(..board, player: player)
}

pub fn update_direction(board: Board, direction: Coords) {
  Board(board.obstacles, board.player, direction, board.width, board.height)
}

pub fn out_of_bounds(board: Board, moved_player: Coords) {
  moved_player.x < 0
  || moved_player.y < 0
  || moved_player.x >= board.width
  || moved_player.y >= board.height
}
