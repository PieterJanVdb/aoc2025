import aoc_2025/utils/int_extra
import gleam/bool
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/result
import gleam/set.{type Set}
import gleam/string

pub type Machine {
  Machine(
    diagram: Int,
    state: Int,
    buttons: List(Int),
    pressed: Set(Int),
    requirements: List(Int),
  )
}

fn parse_light_diagram(input: String) {
  let bin_str = string.replace(input, "#", "1") |> string.replace(".", "0")
  let assert Ok(diagram) = int.base_parse(bin_str, 2)
  #(diagram, string.length(bin_str))
}

fn parse_buttons(input: String, diagram_len: Int) -> List(Int) {
  let assert Ok(buttons_re) = regexp.from_string("\\(([^)]+)\\)")

  regexp.scan(buttons_re, input)
  |> list.flat_map(fn(m) {
    option.values(m.submatches)
    |> list.map(fn(button) {
      string.split(button, ",")
      |> list.map(int_extra.parse)
      |> list.fold(0, fn(mask, button_idx) {
        let right_index = diagram_len - 1 - button_idx
        int.bitwise_or(mask, int.bitwise_shift_left(1, right_index))
      })
    })
  })
}

fn parse_requirements(input: String) {
  string.split(input, ",") |> list.map(int_extra.parse)
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
      state: 0,
      buttons: parse_buttons(buttons, diagram_len),
      pressed: set.new(),
      requirements: parse_requirements(requirements),
    )
  })
}

fn press(machine: Machine, button: Int) {
  Machine(
    ..machine,
    pressed: set.insert(machine.pressed, button),
    state: int.bitwise_exclusive_or(machine.state, button),
  )
}

fn shortest_loop(
  queue: List(#(Int, Machine)),
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
        list.map(machine.buttons, fn(button) { #(button, machine) })
        |> list.append(rest, _)

      shortest_loop(next_queue, next_visited)
    }
  }
}

fn shortest(machine: Machine) {
  shortest_loop([#(0, machine)], set.new())
}

pub fn pt_1(input: String) {
  parse(input) |> list.map(shortest) |> result.values() |> int.sum()
  // let assert [a, b, c] = parse(input)
  // echo shortest(a)
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
