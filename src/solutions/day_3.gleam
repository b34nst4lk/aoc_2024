import gleam/int
import gleam/io
import gleam/list
import gleam/regexp
import gleam/string
import utils

pub fn day_3() {
  let input = utils.open("data/3.txt")
  let inputs =
    input
    |> string.trim()
    |> string.split("\n")

  io.debug(#("3a", solve_3a(inputs)))
  io.debug(#("3b", solve_3b(inputs)))
}

fn solve_3a(inputs) {
  let assert Ok(pattern) = regexp.from_string("mul\\(\\d+,\\d+\\)")

  inputs
  |> list.map(fn(i) {
    pattern
    |> regexp.scan(i)
    |> list.map(fn(match) { parse_mul(match.content) })
    |> int.sum()
  })
  |> int.sum()
}

fn solve_3b(inputs) {
  let assert Ok(pattern) =
    regexp.from_string("mul\\(\\d+,\\d+\\)|do\\(\\)|don't\\(\\)")
  inputs
  |> list.map(fn(i) {
    regexp.scan(pattern,i)
  })
  |> list.flatten()
  |> solve_3b_iter(0, True)
}

fn solve_3b_iter(inputs: List(regexp.Match), acc, to_do) {
  case inputs {
    [] -> acc
    [first, ..rest] -> {
      io.debug(#(first.content, acc))
      case to_do {
        True -> {
          case first.content {
            "do()" -> solve_3b_iter(rest, acc, True)
            "don't()" -> solve_3b_iter(rest, acc, False)
            "mul" <> _ -> solve_3b_iter(rest, acc + parse_mul(first.content), True)
            _ -> panic
          }
        }
        False -> {
          case first.content {
            "do()" -> solve_3b_iter(rest, acc, True)
            "don't()" | _ -> solve_3b_iter(rest, acc, False)
          }
        }
      }
    }
  }
}

fn parse_mul(s) {
  let ints =
    s
    |> string.replace("mul(", "")
    |> string.replace(")", "")
    |> string.split(",")
    |> list.map(fn(i) {
      let assert Ok(parsed) = int.parse(i)
      parsed
    })
  let assert [first, second] = ints
  first * second
}
