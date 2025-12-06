import aoc_2025/utils/int_extra
import gleam/int
import gleam/list
import gleam/string

pub type Op =
  fn(Int, Int) -> Int

fn parse(input: String, parse_column: fn(List(List(String))) -> List(Int)) {
  let assert [ops, ..nrs] =
    string.split(input, on: "\n")
    |> list.reverse()

  let #(ops, dists) = parse_ops(ops)
  let cells = list.map(nrs, parse_cells(_, dists))

  list.transpose(cells)
  |> list.map(fn(column) { list.reverse(column) |> parse_column })
  |> list.zip(ops, _)
}

fn parse_ops(input: String) -> #(List(Op), List(Int)) {
  let #(ops, dists, final_dist) =
    string.split(input, on: "")
    |> list.fold(#([], [], 0), fn(acc, char) {
      let #(ops, dists, dist) = acc

      case parse_op(char) {
        Ok(op) -> {
          case ops {
            [] -> #([op, ..ops], dists, 0)
            _ -> #([op, ..ops], [dist - 1, ..dists], 0)
          }
        }
        Error(Nil) -> #(ops, dists, dist + 1)
      }
    })
  #(list.reverse(ops), list.reverse([final_dist, ..dists]))
}

fn parse_cells(input: String, dists: List(Int)) -> List(List(String)) {
  let #(_, cells) =
    list.fold(dists, #(string.split(input, on: ""), []), fn(acc, dist) {
      let #(chars, cells) = acc
      let #(cell, next_chars) = list.split(chars, dist + 1)
      #(list.drop(next_chars, 1), [cell, ..cells])
    })

  list.reverse(cells)
}

fn parse_op(op_str: String) -> Result(Op, Nil) {
  case op_str {
    "*" -> Ok(int.multiply)
    "+" -> Ok(int.add)
    _ -> Error(Nil)
  }
}

fn cell_to_int(cell: List(String)) -> Int {
  string.join(cell, with: "") |> string.trim |> int_extra.parse
}

fn solve(problems: List(#(Op, List(Int)))) {
  list.fold(problems, 0, fn(acc, problem) {
    acc
    + list.fold(problem.1, 0, fn(acc, nr) {
      case acc {
        0 -> nr
        _ -> problem.0(acc, nr)
      }
    })
  })
}

pub fn pt_1(input: String) {
  parse(input, list.map(_, cell_to_int)) |> solve
}

pub fn pt_2(input: String) {
  parse(input, fn(column) { list.transpose(column) |> list.map(cell_to_int) })
  |> solve
}
