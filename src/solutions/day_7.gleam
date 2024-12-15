import gleam/int
import gleam/io
import gleam/list
import gleam/string
import utils

pub type Op {
  Mul
  Sum
  Con
}

pub fn day_7() {
  let inputs =
    utils.open("src/data/7.txt")
    |> string.trim
    |> string.split("\n")
    |> list.fold(list.new(), fn(l, s) {
      let split_string = string.split(s, ":")
      let assert [expected, value] = split_string
      let assert Ok(expected) = expected |> string.trim |> int.parse
      let values =
        value
        |> string.trim
        |> string.split(" ")
        |> list.map(fn(val) {
          let assert Ok(val) = int.parse(val)
          val
        })
      list.append(l, [#(expected, values)])
    })

  io.debug(#("7a", sum_backwards_eval(inputs, [Mul, Sum])))
  io.debug(#("7b", sum_backwards_eval(inputs, [Mul, Sum, Con])))
}

fn magnitude(val: Int) {
  magnitude_iter(val, 1)
}

fn magnitude_iter(val: Int, acc: Int) {
  let assert Ok(new_val) = int.divide(val, 10)
  case new_val < 1 {
    True -> acc
    False -> magnitude_iter(new_val, acc * 10)
  }
}

fn sum_backwards_eval(inputs: List(#(Int, List(Int))), ops) {
  inputs
  |> list.filter(fn(input) { backwards_eval(input.0, input.1, ops) })
  |> list.map(fn(result) { result.0 })
  |> int.sum
}

fn backwards_eval(expected: Int, inputs: List(Int), ops) {
  let inputs = list.reverse(inputs)
  backwards_eval_iter(inputs, [expected], ops)
}

fn backwards_eval_iter(inputs, acc, ops) {
  case inputs {
    [] -> {
      list.contains(acc, 0)
    }

    [first, ..rest] -> {
      let new_acc =
        acc
        |> list.fold(list.new(), fn(l, expected) {
          let l = case list.contains(ops, Con) {
            True -> {
              case unconcat(expected, first) {
                Ok(val) -> list.append(l, [val])
                Error(_) -> l
              }
            }
            False -> l
          }
          let l = case unmultiply(expected, first) {
            Ok(val) -> list.append(l, [val])
            Error(_) -> l
          }
          list.append(l, [expected - first])
        })
      backwards_eval_iter(rest, new_acc, ops)
    }
  }
}

pub fn unconcat(expected, val) {
  let m = magnitude(val)
  let dividor = m * 10

  // remove least significant digits from number
  let result = expected / dividor * dividor
  case result == expected - val {
    True -> Ok(expected / dividor)
    False -> Error("cannot concat")
  }
}

pub fn unmultiply(expected, val) {
  case expected >= val {
    True ->
      case expected % val == 0 {
        True -> Ok(expected / val)
        False -> Error("cannot multiply")
      }
    False -> Error("cannot multiply")
  }
}

pub fn unadd(expected, val) {
  case expected - val >= 0 {
    True -> Ok(expected - val)
    False -> Error("cannot add")
  }
}
