import aoc_2025/utils/int_extra
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/set.{type Set}
import gleam/string
import shellout
import simplifile
import temporary

pub type Machine {
  Machine(
    diagram: Int,
    diagram_len: Int,
    state: Int,
    buttons: List(Set(Int)),
    pressed: Set(Int),
    requirements: Dict(Int, Int),
  )
}

fn parse_light_diagram(input: String) {
  let bin_str = string.replace(input, "#", "1") |> string.replace(".", "0")
  let assert Ok(diagram) = int.base_parse(bin_str, 2)
  #(diagram, string.length(bin_str))
}

fn parse_buttons(input: String) -> List(Set(Int)) {
  let assert Ok(buttons_re) = regexp.from_string("\\(([^)]+)\\)")

  regexp.scan(buttons_re, input)
  |> list.flat_map(fn(m) {
    option.values(m.submatches)
    |> list.map(fn(button) {
      string.split(button, ",")
      |> list.map(int_extra.parse)
      |> set.from_list()
    })
  })
}

fn parse_requirements(input: String) {
  string.split(input, ",")
  |> list.map(int_extra.parse)
  |> list.index_map(fn(x, i) { #(i, x) })
  |> dict.from_list
}

fn parse(input: String) {
  let assert Ok(parts_re) =
    regexp.from_string("\\[([^\\]]+)\\](.*?)\\{([^}]+)\\}")
  let matches = regexp.scan(parts_re, input)

  list.map(matches, fn(match) {
    let assert [diagram, buttons, requirements] =
      option.values(match.submatches)
    let #(diagram, diagram_len) = parse_light_diagram(diagram)
    Machine(
      diagram:,
      diagram_len:,
      state: 0,
      buttons: parse_buttons(buttons),
      pressed: set.new(),
      requirements: parse_requirements(requirements),
    )
  })
}

fn indexes_to_bitwise_int(s: Set(Int), diagram_len: Int) -> Int {
  set.fold(s, 0, fn(acc, i) {
    let right_index = diagram_len - 1 - i
    int.bitwise_or(acc, int.bitwise_shift_left(1, right_index))
  })
}

fn press(machine: Machine, button: Set(Int)) {
  let bitwise_button = indexes_to_bitwise_int(button, machine.diagram_len)
  Machine(
    ..machine,
    pressed: set.insert(machine.pressed, bitwise_button),
    state: int.bitwise_exclusive_or(machine.state, bitwise_button),
  )
}

fn shortest_loop(
  queue: List(#(Set(Int), Machine)),
  visited: Set(Set(Int)),
) -> Result(Int, Nil) {
  case queue {
    [] -> Error(Nil)
    [#(button, machine), ..rest] -> {
      let machine = press(machine, button)

      use <- bool.lazy_guard(set.contains(visited, machine.pressed), fn() {
        shortest_loop(rest, visited)
      })

      use <- bool.guard(
        machine.state == machine.diagram,
        Ok(set.size(machine.pressed) - 1),
      )

      let next_visited = set.insert(visited, machine.pressed)

      let next_queue =
        list.filter(machine.buttons, fn(b) { b != button })
        |> list.map(fn(button) { #(button, machine) })
        |> list.append(rest, _)

      shortest_loop(next_queue, next_visited)
    }
  }
}

fn shortest(machine: Machine) {
  shortest_loop([#(set.new(), machine)], set.new())
}

pub fn pt_1(input: String) {
  parse(input) |> list.map(shortest) |> result.values() |> int.sum()
}

fn var(i: Int) -> String {
  " x" <> int.to_string(i)
}

// Thanks to https://whitespace.moe/lily/gleam_aoc/src/branch/main/src/aoc_2025/day_10.gleam
pub fn pt_2(input: String) {
  parse(input)
  |> list.map(fn(m) {
    let formula =
      "(set-logic LIA) (set-option :produce-models true)"
      <> list.index_fold(m.buttons, "", fn(acc, _, i) {
        let v = var(i)
        acc <> " (declare-const" <> v <> " Int) (assert (>=" <> v <> " 0))"
      })
      <> list.fold(dict.to_list(m.requirements), "", fn(acc, p) {
        let vs =
          list.index_fold(m.buttons, "", fn(acc, b, i) {
            case set.contains(b, p.0) {
              True -> acc <> var(i)
              False -> acc
            }
          })
        acc <> " (assert (= (+" <> vs <> ") " <> int.to_string(p.1) <> "))"
      })
      <> " (minimize (+"
      <> list.index_fold(m.buttons, "", fn(acc, _, i) { acc <> var(i) })
      <> ")) (check-sat) (get-objectives) (exit)"
    let assert Ok(res) =
      temporary.create(temporary.file(), fn(file_path) {
        let assert Ok(_) = simplifile.write(formula, to: file_path)
        shellout.command("z3", with: [file_path], in: ".", opt: [])
      })
      as "Failed to create temporary file"
    let output = case res {
      Ok(output) -> output
      Error(#(i, output)) ->
        panic as {
          "Z3 command failed with exit status "
          <> int.to_string(i)
          <> " and output: "
          <> output
        }
    }
    let assert [_, " " <> n, ..] = string.split(output, ")")
      as { "Unexpected Z3 output: " <> output }
    int_extra.parse(n)
  })
  |> int.sum
}
