import aoc_2025/utils/int_extra
import gleam/int
import gleam/list
import gleam/option
import gleam/regexp
import gleam/string

type Problem {
  Problem(op: fn(Int, Int) -> Int, nrs: List(Int))
}

fn parse(input: String) {
  let assert Ok(re) = regexp.from_string("([\\d\\+\\*]*)")

  string.split(input, on: "\n")
  |> list.map(fn(line) {
    regexp.scan(with: re, content: line)
    |> list.flat_map(fn(match) { match.submatches })
    |> option.values()
  })
  |> list.transpose()
  |> list.map(fn(column) {
    case list.reverse(column) {
      [op, ..nrs] -> {
        let op = case op {
          "*" -> int.multiply
          "+" -> int.add
          _ -> panic as "Uhoh"
        }
        Problem(op:, nrs: list.map(nrs, int_extra.parse))
      }
      _ -> panic as "Uhoh"
    }
  })
}

pub fn pt_1(input: String) {
  parse(input)
  |> list.fold(0, fn(acc, problem) {
    acc
    + list.fold(problem.nrs, 0, fn(acc, nr) {
      case acc {
        0 -> nr
        _ -> problem.op(acc, nr)
      }
    })
  })
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
