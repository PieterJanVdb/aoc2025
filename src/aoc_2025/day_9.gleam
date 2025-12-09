import aoc_2025/utils/int_extra
import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/order
import gleam/string

fn parse(input: String) -> List(#(Int, Int)) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    let assert Ok(#(x, y)) = string.split_once(line, ",")
    #(int_extra.parse(x), int_extra.parse(y))
  })
}

fn size(pair: #(#(Int, Int), #(Int, Int))) {
  let #(left, right) = pair
  { int.absolute_value(left.0 - right.0) + 1 }
  * { int.absolute_value(left.1 - right.1) + 1 }
}

fn find_biggest(points: List(#(Int, Int))) {
  list.combination_pairs(points)
  |> list.fold(0, fn(acc, pair) { int.max(acc, size(pair)) })
}

fn intersects(
  sides: List(#(#(Int, Int), #(Int, Int))),
  pair: #(#(Int, Int), #(Int, Int)),
) {
  let #(#(ax, ay), #(bx, by)) = pair

  list.any(sides, fn(side) {
    let #(#(px, py), #(qx, qy)) = side
    {
      int.max(ax, bx) <= int.min(px, qx)
      || int.max(ay, by) <= int.min(py, qy)
      || int.min(ax, bx) >= int.max(px, qx)
      || int.min(ay, by) >= int.max(py, qy)
    }
    |> bool.negate()
  })
}

fn sort_by_size(pairs: List(#(#(Int, Int), #(Int, Int)))) {
  list.sort(pairs, fn(a, b) { order.reverse(int.compare)(size(a), size(b)) })
}

pub fn pt_1(input: String) {
  parse(input) |> find_biggest()
}

pub fn pt_2(input: String) {
  let points = parse(input)
  let assert Ok(first) = list.first(points)
  let sides = list.append(points, [first]) |> list.window_by_2()
  let assert Some(dist) =
    list.combination_pairs(points)
    |> sort_by_size()
    |> list.fold_until(None, fn(_, pair) {
      case intersects(sides, pair) {
        False -> list.Stop(Some(size(pair)))
        True -> list.Continue(None)
      }
    })
  dist
}
