import gleam/int
import gleam/list
import gleam/string

pub fn parse(input: String) -> List(List(Int)) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    let assert Ok(line_nrs) =
      string.to_graphemes(line)
      |> list.try_map(int.parse)
    line_nrs
  })
}

fn turn_on(batteries: List(Int), remaining: Int, collected: List(Int)) -> Int {
  case remaining {
    1 -> {
      let assert Ok(left) = list.max(batteries, int.compare)
      let assert Ok(joltage) =
        list.reverse([left, ..collected])
        |> list.map(int.to_string)
        |> string.join(with: "")
        |> int.parse
      joltage
    }
    _ -> {
      let assert Ok(left) =
        list.reverse(batteries)
        |> list.drop(remaining - 1)
        |> list.max(int.compare)
      let rest =
        list.drop_while(batteries, fn(battery) { battery != left })
        |> list.drop(1)
      turn_on(rest, remaining - 1, [left, ..collected])
    }
  }
}

pub fn pt_1(input: List(List(Int))) -> Int {
  list.map(input, fn(batteries) { turn_on(batteries, 2, []) }) |> int.sum
}

pub fn pt_2(input: List(List(Int))) {
  list.map(input, fn(batteries) { turn_on(batteries, 12, []) }) |> int.sum
}
