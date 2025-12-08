import aoc_2025/utils/int_extra
import gleam/int
import gleam/list
import gleam/order
import gleam/set.{type Set}
import gleam/string

type Box {
  Box(x: Int, y: Int, z: Int)
}

fn parse(input: String) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    let assert [x, y, z] =
      string.split(line, ",")
      |> list.map(int_extra.parse)
    set.new() |> set.insert(Box(x:, y:, z:))
  })
}

fn distance(a: Box, b: Box) {
  let dx = a.x - b.x
  let dy = a.y - b.y
  let dz = a.z - b.z
  dx * dx + dy * dy + dz * dz
}

fn get_sorted_pairs(circuits: List(Set(Box))) {
  list.flat_map(circuits, set.to_list)
  |> list.combination_pairs()
  |> list.sort(fn(a, b) { int.compare(distance(a.0, a.1), distance(b.0, b.1)) })
}

fn join(circuits: List(Set(Box)), a: Box, b: Box) {
  let #(circuits, conn) = {
    use #(next, conn), circuit <- list.fold(circuits, #([], set.new()))

    case set.contains(circuit, a), set.contains(circuit, b) {
      True, _ | _, True -> #(next, set.union(conn, circuit))
      _, _ -> #([circuit, ..next], conn)
    }
  }

  [conn, ..circuits]
}

fn connect(circuits: List(Set(Box)), pairs: List(#(Box, Box))) {
  case pairs {
    [] -> circuits
    [pair, ..rest] -> join(circuits, pair.0, pair.1) |> connect(rest)
  }
}

fn connect_all(circuits: List(Set(Box)), pairs: List(#(Box, Box))) {
  case pairs {
    [] -> 0
    [pair, ..rest] -> {
      case join(circuits, pair.0, pair.1) {
        [_] -> { pair.0 }.x * { pair.1 }.x
        next -> connect_all(next, rest)
      }
    }
  }
}

pub fn pt_1(input: String) {
  let circuits = parse(input)

  get_sorted_pairs(circuits)
  |> list.take(1000)
  |> connect(circuits, _)
  |> list.map(set.size)
  |> list.sort(order.reverse(int.compare))
  |> list.take(3)
  |> list.fold(1, int.multiply)
}

pub fn pt_2(input: String) {
  let circuits = parse(input)

  get_sorted_pairs(circuits)
  |> connect_all(circuits, _)
}
