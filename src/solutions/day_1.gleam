import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn day_1() {
  // prep
  let contents = open("src/data/1.txt")
  let lines = string.split(contents, "\n")
  let splitted_strings = split_strings(lines)

  // 1a
  let list1a =
    splitted_strings.0
    |> list.sort(by: int.compare)

  let list2a =
    splitted_strings.1
    |> list.sort(by: int.compare)

  io.print("day 1a: ")
  io.debug(sum_diff_of_lists(list1a, list2a))

  // 1b
  let dict1b = count_items(splitted_strings.0)
  let dict2b = count_items(splitted_strings.1)
  io.print("day 1b: ")
  io.debug(multiply_dicts(dict1b, dict2b))
}

fn open(filename: String) -> String {
  let assert Ok(result) = simplifile.read(from: filename)
  result
}

fn split_strings(list_of_strings: List(String)) {
  let list1 = []
  let list2 = []
  split_strings_iter(list1, list2, list_of_strings)
}

fn split_strings_iter(
  list1: List(Int),
  list2: List(Int),
  original_list: List(String),
) -> #(List(Int), List(Int)) {
  case original_list {
    [] | [""] -> #(list1, list2)
    [first, ..rest] -> {
      let split_line = string.split(first, "   ")
      let assert [i, j] = split_line
      let assert Ok(front) = int.parse(i)
      let assert Ok(back) = int.parse(j)
      split_strings_iter(
        list.append(list1, [front]),
        list.append(list2, [back]),
        rest,
      )
    }
  }
}

fn sum_diff_of_lists(list1, list2) -> Int {
  let acc = 0
  sum_diff_of_lists_iter(list1, list2, acc)
}

fn sum_diff_of_lists_iter(list1, list2, acc) {
  case list1, list2 {
    [], [] | [], _ | _, [] -> acc

    [left, ..rest1], [right, ..rest2] -> {
      sum_diff_of_lists_iter(
        rest1,
        rest2,
        acc + int.absolute_value(left - right),
      )
    }
  }
}

fn count_items(l: List(Int)) -> Dict(Int, Int) {
  let d = dict.new()
  count_items_iter(l, d)
}

fn count_items_iter(l: List(Int), d: Dict(Int, Int)) -> Dict(Int, Int) {
  case l {
    [] -> d
    [first, ..rest] -> {
      let res = dict.get(d, first)
      let val = case res {
        Ok(val) -> val
        Error(_) -> 0
      }
      let new_d = dict.insert(d, first, val + 1)
      count_items_iter(rest, new_d)
    }
  }
}

fn multiply_dicts(d1, d2) -> Int {
  let l1 = dict.to_list(d1)
  let acc = 0
  multiply_dicts_iter(l1, d2, acc)
}

fn multiply_dicts_iter(l1: List(#(Int, Int)), d2, acc) -> Int {
  case l1 {
    [] -> acc
    [first, ..rest] -> {
      let res = dict.get(d2, first.0)
      let val = case res {
        Ok(val) -> val
        Error(_) -> 0
      }
      multiply_dicts_iter(rest, d2, acc + first.0 * val)
    }
  }
}
