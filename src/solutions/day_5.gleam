import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/set
import gleam/string

import utils

pub fn day_5() {
  let input =
    utils.open("src/data/5.txt")
    |> string.trim()

  let assert [raw_rules, raw_updates] = string.split(input, "\n\n")

  let rules = prepare_rules(raw_rules)
  let updates = prepare_updates(raw_updates)

  let categorized_updates = categorize_updates(rules, updates)

  io.debug(#("5a", sum_mids(categorized_updates.valid)))
  io.debug(#("5b", sum_mids(fix_invalids(rules, categorized_updates.invalid))))
}

fn prepare_rules(raw_rules) {
  raw_rules
  |> string.split("\n")
  |> list.fold(dict.new(), fn(d, item) {
    let assert [key, value] = string.split(item, "|")
    let assert Ok(key) = int.parse(key)
    let assert Ok(value) = int.parse(value)

    let res = dict.get(d, key)
    let values = case res {
      Ok(current_values) -> set.insert(current_values, value)
      Error(_) -> set.from_list([value])
    }
    dict.insert(d, key, values)
  })
}

fn prepare_updates(raw_updates) {
  raw_updates
  |> string.split("\n")
  |> list.map(fn(raw_update) {
    raw_update
    |> string.split(",")
    |> list.map(fn(item) {
      let assert Ok(v) = int.parse(item)
      v
    })
  })
}

pub type CategorizedUpdates {
  CategorizedUpdates(valid: List(List(Int)), invalid: List(List(Int)))
}

fn categorize_updates(rules, updates) {
  let categorized_updates = CategorizedUpdates([], [])
  updates
  |> list.fold(categorized_updates, fn(u, update) {
    let valid_update = checks_iter(rules, update)
    case valid_update {
      True ->
        CategorizedUpdates(
          valid: list.append(u.valid, [update]),
          invalid: u.invalid,
        )
      False ->
        CategorizedUpdates(
          valid: u.valid,
          invalid: list.append(u.invalid, [update]),
        )
    }
  })
}

fn sum_mids(updates) {
  let mids =
    updates
    |> list.fold([], fn(mids, update) {
      let len = list.length(update)
      let assert Ok(mid) = update |> list.take({ len + 1 } / 2) |> list.last()
      list.append(mids, [mid])
    })
  int.sum(mids)
}

fn checks_iter(rules, update) {
  case update {
    [] -> True
    [first, ..rest] -> {
      let accepted = dict.get(rules, first)
      case accepted {
        Ok(values) -> {
          let is_empty =
            rest
            |> set.from_list()
            |> set.difference(values)
            |> set.is_empty
          case is_empty {
            True -> checks_iter(rules, rest)
            False -> False
          }
        }
        Error(_) -> False
      }
    }
  }
}

fn fix_invalids(rules, updates) {
  updates
  |> list.map(fn(update) {
    update
    |> list.fold(dict.new(), fn(d, key) {
      let count =
        update
        |> list.fold(0, fn(c, i) {
          let rule = get_rule(rules, i)
          case set.contains(rule, key) {
            True -> c + 1
            False -> c
          }
        })
      dict.insert(d, key, count)
    })
    |> dict.to_list()
    |> list.sort(fn(a: #(Int, Int), b: #(Int, Int)) { int.compare(b.1, a.1) })
    |> list.map(fn(j) { j.0 })
  })
}

fn get_rule(rules, key) {
  let assert Ok(rule) = dict.get(rules, key)
  rule
}
