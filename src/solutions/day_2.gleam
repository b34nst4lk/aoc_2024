import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string
import utils

pub fn day_2() {
  let input = utils.open("src/data/2.txt")
  let splitted_strings =
    input
    |> string.trim()
    |> string.split("\n")
  let lists = cleanup_input(splitted_strings)

  // 2a
  io.debug(#("day2a", check_safe(lists, safe_condition_2a)))
  io.debug(#("day2b", check_safe(lists, safe_condition_2b)))
}

fn cleanup_input(splitted_strings) {
  list.map(splitted_strings, fn(l) {
    let splitted_l = string.split(l, " ")
    let result =
      splitted_l
      |> list.map(fn(i) {
        let assert Ok(res) = int.parse(i)
        res
      })
    result
  })
}

fn check_safe(lists, cond) {
  let acc = 0
  check_safe_iter(lists, acc, cond)
}

fn check_safe_iter(lists, acc, cond) {
  case lists {
    [] -> acc
    [first, ..rest] -> {
      let acc = cond(first, acc)
      check_safe_iter(rest, acc, cond)
    }
  }
}

// 2a
fn safe_condition_2a(l, acc) {
  let is_ascending = list.sort(l, by: int.compare) == l
  let is_descending = list.sort(l, by: order.reverse(int.compare)) == l
  let is_safe = is_ascending || is_descending
  case is_safe {
    True -> {
      case any_diff_not_between_1_and_3(l) {
        True -> acc + 1
        False -> acc
      }
    }
    False -> acc
  }
}

fn any_diff_not_between_1_and_3(l) {
  let assert [first, ..rest] = l
  any_diff_not_between_1_and_3_iter(first, rest)
}

fn any_diff_not_between_1_and_3_iter(first, l) {
  case l {
    [] -> True
    [second, ..rest] -> {
      case int.absolute_value(first - second) {
        1 | 2 | 3 -> any_diff_not_between_1_and_3_iter(second, rest)
        _ -> False
      }
    }
  }
}

// 2b
fn safe_condition_2b(l, acc) {
  case is_safe(l) {
    True -> acc + 1
    False -> {
      case dampened(l) {
        True -> acc + 1
        False -> acc
      }
    }
  }
}

fn get_diffs(l) {
  let diffs = []
  let assert [first, ..rest] = l
  get_diffs_iter(first, rest, diffs)
}

fn get_diffs_iter(first, rest, diffs) {
  case rest {
    [] -> diffs
    [second, ..rest] -> {
      let diffs = list.append(diffs, [second - first])
      get_diffs_iter(second, rest, diffs)
    }
  }
}

fn dampened(l) {
  let dampened_lists =
    list.index_map(l, fn(_l, i) {
      let before = list.take(l, i)
      let after = list.drop(l, i + 1)
      list.append(before, after)
    })
  list.any(dampened_lists, fn(ll) { is_safe(ll) })
}

fn is_safe(l) {
  let diffs = get_diffs(l)
  let safe_increasing = diffs == list.filter(diffs, fn(i) { 1 <= i && i <= 3 })
  let safe_decreasing =
    diffs == list.filter(diffs, fn(i) { -3 <= i && i <= -1 })
  safe_increasing || safe_decreasing
}
