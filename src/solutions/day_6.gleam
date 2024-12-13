import gleam/io
import gleam/list
import gleam/otp/task
import gleam/set.{type Set}
import gleam/string
import utils

import lib/board.{type Board, type Coords, Coords}

pub fn day_6() {
  let input = utils.open("src/data/6.txt")
  let lines = string.split(input, "\n")

  let b = init_board(lines)

  let assert Ok(path) = run_simulation(b, set.new())
  let visited =
    path
    |> set.fold(set.new(), fn(s, tile) { set.insert(s, tile.0) })

  io.debug(#("6a", set.size(visited)))
  io.debug(#("6b", count_possible_obstacle_placements(path, b)))
}

fn init_board(lines) {
  let height = list.length(lines)
  let width = {
    let assert Ok(first) = list.first(lines)
    string.length(first)
  }
  let b =
    board.new()
    |> board.update_dimensions(width, height)
    |> board.update_direction(Coords(0, 1))

  lines
  |> list.reverse()
  |> list.index_fold(b, fn(b, line, y) {
    line
    |> string.split("")
    |> list.index_fold(b, fn(b, tile, x) {
      case tile {
        "#" -> board.add_obstacle(b, Coords(x, y))
        "^" -> board.update_player(b, Coords(x, y))
        _ -> b
      }
    })
  })
}

fn run_simulation(b: Board, visited: Set(#(Coords, Coords))) {
  let _ = case set.contains(visited, #(b.player, b.direction)) {
    True -> Error("loop found")
    False -> {
      let visited = set.insert(visited, #(b.player, b.direction))
      let moved_player = board.move(b.player, b.direction)
      case board.out_of_bounds(b, moved_player) {
        True -> Ok(visited)
        False -> {
          let b = case set.contains(b.obstacles, moved_player) {
            True -> {
              let assert Ok(direction) = rotate(b.direction)
              board.update_direction(b, direction)
            }
            False -> board.update_player(b, moved_player)
          }
          run_simulation(b, visited)
        }
      }
    }
  }
}

fn rotate(direction: Coords) {
  case direction {
    Coords(0, 1) -> Ok(Coords(1, 0))
    Coords(1, 0) -> Ok(Coords(0, -1))
    Coords(0, -1) -> Ok(Coords(-1, 0))
    Coords(-1, 0) -> Ok(Coords(0, 1))
    _ -> Error("Invalid direction found")
  }
}

fn count_possible_obstacle_placements(
  path: Set(#(Coords, Coords)),
  original_board: Board,
) {
  path
  |> set.fold(set.new(), fn(s, p) {
    case p.0 != original_board.player {
      True -> set.insert(s, p.0)
      False -> s
    }
  })
  |> set.fold([], fn(task_list, o) {
    let new_board = board.add_obstacle(original_board, o)
    list.append(task_list, [
      task.async(fn() { run_simulation(new_board, set.new()) }),
    ])
  })
  |> task.try_await_all(10_000)
  |> list.map(fn(r) {
    let assert Ok(r) = r
    r
  })
  |> list.fold(0, fn(c, r) {
    case r {
      Ok(_) -> c
      Error(_) -> c + 1
    }
  })
}
