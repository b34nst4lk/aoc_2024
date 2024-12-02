import gleam/int
import gleam/io
import gleam/list
import gleam/string
import simplifile

pub fn main() {
  io.println("Hello from advent_of_code_2024!")
  let contents = open("src/data/1.txt")
  let lines = string.split(contents, "\n")
  let splitted_strings = split_strings(lines)
  let list1 =
    splitted_strings.0
    |> list.sort(by: int.compare)

  let list2 =
    splitted_strings.1
    |> list.sort(by: int.compare)

  io.debug(sum_diff_of_lists(list1, list2))
}

fn open(filename: String) -> String {
  let result = simplifile.read(from: filename)
  case result {
    Ok(value) -> value
    Error(_) -> ""
  }
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
) {
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
