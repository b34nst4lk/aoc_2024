import gleam/dict
import gleam/io
import gleam/set.{type Set}
import utils

import lib/board.{parse_input}
import lib/coords.{type Coords, Coords}

pub fn day_8() {
  let #(input, bounds) = {
    let #(input, bounds) =
      utils.open("src/data/8.txt")
      |> parse_input

    let input = input |> dict.filter(fn(k, _) { k != "." })
    #(input, bounds)
  }

  let all_antinodes = find_antinodes(input, bounds, pairwise_antinodes_calc)
  io.debug(#("8a", set.size(all_antinodes)))

  let all_trailing_antinodes = find_antinodes(input, bounds, trailing_antinodes_calc)
  io.debug(#("8b", set.size(all_trailing_antinodes)))
}

fn find_antinodes(input, bounds, calc_func) {
    input
    |> dict.map_values(fn(_, v) {
      let result = calculate_antinodes(v, bounds, calc_func)
      case result {
        Ok(values) -> values
        Error(_) -> set.new()
      }
    })
    |> dict.fold(set.new(), fn(s, _, v) { set.union(s, v) })

}

fn calculate_antinodes(
  nodes: Set(Coords),
  bounds: Coords,
  calc_func: fn(Set(Coords), Coords, Coords, Coords) -> Set(Coords),
) -> Result(Set(Coords), String) {
  case set.size(nodes) {
    0 -> Error("unreachable")
    _ -> {
      let s =
        nodes
        |> set.fold(set.new(), fn(s, node1) {
          set.fold(nodes, s, fn(s, node2) {
            case node1 == node2 {
              True -> s
              False -> {
                calc_func(s, node1, node2, bounds)
              }
            }
          })
        })
      Ok(s)
    }
  }
}

fn pairwise_antinodes_calc(
  s: Set(Coords),
  node1: Coords,
  node2: Coords,
  bounds: Coords,
) -> Set(Coords) {
  let diff = coords.minus(node1, node2)
  s
  |> set.insert(coords.add(node1, diff))
  |> set.insert(coords.minus(node1, diff))
  |> set.insert(coords.add(node2, diff))
  |> set.insert(coords.minus(node2, diff))
  |> set.delete(node1)
  |> set.delete(node2)
  |> set.filter(fn(i) { !out_of_bounds(i, bounds) })
}

fn trailing_antinodes_calc(
  s: Set(Coords),
  node1: Coords,
  node2: Coords,
  bounds: Coords,
) -> Set(Coords) {
  let diff = coords.minus(node1, node2)
  s
  |> trailing_antinodes_calc_iter(node1, coords.minus(node1, node2), bounds)
  |> trailing_antinodes_calc_iter(node2, coords.minus(node2, node1), bounds)
  |> set.insert(node1)
  |> set.insert(node2)
}

fn trailing_antinodes_calc_iter(
  s: Set(Coords),
  node: Coords,
  diff: Coords,
  bounds: Coords,
) {
  let new_node = coords.add(node, diff)
  case out_of_bounds(new_node, bounds) {
    True -> s
    False -> {
      trailing_antinodes_calc_iter(
        set.insert(s, new_node),
        new_node,
        diff,
        bounds,
      )
    }
  }
}

fn out_of_bounds(node: Coords, bounds: Coords) {
  node.x < 0 || node.x >= bounds.x || node.y < 0 || node.y >= bounds.y
}
