import gleam/int
import gleam/list
import gleam/string

pub opaque type Direction {
  Left
  Right
}

fn tick_times(from: Int, turn: #(Int, Direction), saw_zero: Int) -> #(Int, Int) {
  let #(times, dir) = turn
  let next = case dir {
    Left ->
      case from - 1 {
        next if next < 0 -> 99
        next -> next
      }
    Right ->
      case from + 1 {
        next if next > 99 -> 0
        next -> next
      }
  }
  let saw_zero = case next == 0 {
    True -> saw_zero + 1
    False -> saw_zero
  }
  case times - 1 {
    0 -> #(next, saw_zero)
    times -> tick_times(next, #(times, dir), saw_zero)
  }
}

fn run(turns: List(#(Int, Direction)), on_turn: fn(Int, #(Int, Int)) -> Int) {
  let #(_, zeroes) =
    list.fold(turns, #(50, 0), fn(acc, turn) {
      let #(next, saw_zeroes) = tick_times(acc.0, turn, 0)
      #(next, on_turn(acc.1, #(next, saw_zeroes)))
    })

  zeroes
}

pub fn parse(input: String) -> List(#(Int, Direction)) {
  string.split(input, on: "\n")
  |> list.map(fn(turn_str) {
    case turn_str {
      "L" <> n_str -> {
        let assert Ok(n) = int.parse(n_str)
        #(n, Left)
      }
      "R" <> n_str -> {
        let assert Ok(n) = int.parse(n_str)
        #(n, Right)
      }
      _ -> panic as "Invalid input"
    }
  })
}

pub fn pt_1(input: List(#(Int, Direction))) {
  run(input, fn(curr_zeroes, res) {
    let #(next, _) = res
    case next == 0 {
      True -> curr_zeroes + 1
      False -> curr_zeroes
    }
  })
}

pub fn pt_2(input: List(#(Int, Direction))) {
  run(input, fn(curr_zeroes, res) {
    let #(_, saw_zeroes) = res
    curr_zeroes + saw_zeroes
  })
}
