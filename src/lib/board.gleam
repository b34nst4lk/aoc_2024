import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string

import lib/coords.{type Coords, Coords}

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

pub fn parse_input(input: String) -> #(Dict(String, Set(Coords)), Coords) {
  let inputs =
    input
    |> string.split("\n")
    |> list.reverse()
    |> list.index_fold(dict.new(), fn(d, line, y) {
      line
      |> string.split("")
      |> list.index_fold(d, fn(d, tile, x) {
        let result = dict.get(d, tile)
        let updated_set = case result {
          Ok(coords) -> set.insert(coords, Coords(x, y))
          Error(_) -> set.new() |> set.insert(Coords(x, y))
        }
        dict.insert(d, tile, updated_set)
      })
    })

  let assert Ok(first_line) = input |> string.split("\n") |> list.first
  let width = string.length(first_line)
  let height = input |> string.split("\n") |> list.length
  #(inputs, Coords(width, height))
}
