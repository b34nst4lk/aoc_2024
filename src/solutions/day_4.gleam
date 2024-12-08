import gleam/dict.{type Dict}
import gleam/io
import gleam/set.{type Set}
import gleam/string
import utils

pub fn day_4() {
  let input = utils.open("src/data/4.txt")
  let inputs =
    input
    |> string.trim()
    |> string.split("")

  let xmas_dict = create_xmas_dict(inputs)

  // 4a
  let assert Ok(x_list) = dict.get(xmas_dict, "X")
  let search_list = create_search_list(x_list)
  io.debug(#("4a", count_matches(search_list, xmas_dict)))
  // 4b
  let assert Ok(m_list) = dict.get(xmas_dict, "M")
  let search_list = create_mas_list(m_list)
  io.debug(#("4b", count_matches(search_list, xmas_dict)))
}

fn create_xmas_dict(chars) {
  let xmas_dict =
    dict.new()
    |> dict.insert("X", set.new())
    |> dict.insert("M", set.new())
    |> dict.insert("A", set.new())
    |> dict.insert("S", set.new())

  create_xmas_dict_iter(xmas_dict, chars, 0, 0)
}

fn create_xmas_dict_iter(
  xmas_dict: Dict(String, Set(#(Int, Int))),
  chars: List(String),
  col: Int,
  row: Int,
) {
  case chars {
    [] -> xmas_dict
    [char, ..rest] -> {
      case char {
        "X" | "M" | "A" | "S" -> {
          let assert Ok(coords) = dict.get(xmas_dict, char)
          let new_list = set.insert(coords, #(col, row))
          let xmas_dict = dict.insert(xmas_dict, char, new_list)
          create_xmas_dict_iter(xmas_dict, rest, col + 1, row)
        }
        "\n" -> create_xmas_dict_iter(xmas_dict, rest, 0, row + 1)
        _ -> create_xmas_dict_iter(xmas_dict, rest, col + 1, row)
      }
    }
  }
}

pub type SearchTarget {
  Xmas(x: #(Int, Int), m: #(Int, Int), a: #(Int, Int), s: #(Int, Int))
  Mas(m: #(Int, Int), a: #(Int, Int), s: Set(#(Int, Int)))
}

fn create_xmas(x, col_dir, row_dir) {
  Xmas(
    x,
    m: #(x.0 + 1 * col_dir, x.1 + 1 * row_dir),
    a: #(x.0 + 2 * col_dir, x.1 + 2 * row_dir),
    s: #(x.0 + 3 * col_dir, x.1 + 3 * row_dir),
  )
}

fn create_mas(m: #(Int, Int)) {
  set.new()
  |> set.insert(Mas(
    //        M . S
    //        . A .
    // ref -> M . S
    m: #(m.0, m.1 - 2),
    a: #(m.0 + 1, m.1 - 1),
    s: set.from_list([#(m.0 + 2, m.1 - 2), #(m.0 + 2, m.1)]),
  ))
  |> set.insert(Mas(
    //        S . S
    //        . A .
    // ref -> M . M
    m: #(m.0 + 2, m.1),
    a: #(m.0 + 1, m.1 - 1),
    s: set.from_list([#(m.0, m.1 - 2), #(m.0 + 2, m.1 - 2)]),
  ))
  |> set.insert(Mas(
    // S . M
    // . A .
    // S . M <- ref
    m: #(m.0, m.1 - 2),
    a: #(m.0 - 1, m.1 - 1),
    s: set.from_list([#(m.0 - 2, m.1), #(m.0 - 2, m.1 - 2)]),
  ))
  |> set.insert(Mas(
    // ref -> M . M
    //        . A .
    //        S . S
    m: #(m.0 + 2, m.1),
    a: #(m.0 + 1, m.1 + 1),
    s: set.from_list([#(m.0, m.1 + 2), #(m.0 + 2, m.1 + 2)]),
  ))
}

fn create_search_list(s) {
  s
  |> set.fold(set.new(), fn(search_list, i) {
    search_list
    // North
    |> set.insert(create_xmas(i, 0, -1))
    // NorthEast
    |> set.insert(create_xmas(i, 1, -1))
    // East
    |> set.insert(create_xmas(i, 1, 0))
    // SouthEast
    |> set.insert(create_xmas(i, 1, 1))
    // South
    |> set.insert(create_xmas(i, 0, 1))
    // SouthWest
    |> set.insert(create_xmas(i, -1, 1))
    // West
    |> set.insert(create_xmas(i, -1, 0))
    // NorthWest
    |> set.insert(create_xmas(i, -1, -1))
  })
}

fn create_mas_list(s) {
  s
  |> set.fold(set.new(), fn(search_list, i) {
    search_list
    |> set.union(create_mas(i))
  })
}

fn count_matches(search_targets: Set(SearchTarget), coords) {
  let assert Ok(m_set) = dict.get(coords, "M")
  let assert Ok(a_set) = dict.get(coords, "A")
  let assert Ok(s_set) = dict.get(coords, "S")

  search_targets
  |> set.fold(0, fn(match_count, search_target) {
    case search_target {
      Xmas(_, m, a, s) -> {
        case
          set.contains(m_set, m)
          && set.contains(a_set, a)
          && set.contains(s_set, s)
        {
          True -> match_count + 1
          False -> match_count
        }
      }
      Mas(m, a, s) -> {
        case
          set.contains(m_set, m)
          && set.contains(a_set, a)
          && set.is_subset(s, s_set)
        {
          True -> match_count + 1
          False -> match_count
        }
      }
    }
  })
}
