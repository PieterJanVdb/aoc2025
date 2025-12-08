import aoc_2025/utils/int_extra
import cell.{type Cell}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/set.{type Set}
import gleam/string

pub opaque type Box {
  Box(x: Int, y: Int, z: Int)
}

type CircuitDistMap =
  Dict(Set(Set(Box)), Int)

type BoxDistMap =
  Dict(Set(Box), Int)

type Cache =
  Cell(#(CircuitDistMap, BoxDistMap))

fn parse(input: String) -> List(Set(Box)) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    let assert [x, y, z] =
      string.split(line, ",")
      |> list.map(int_extra.parse)
    set.new() |> set.insert(Box(x:, y:, z:))
  })
}

fn cached_distance(a: Box, b: Box, cache: Cache) -> Int {
  let assert Ok(#(_, box_dists)) = cell.read(cache)
  let line = set.from_list([a, b])
  case dict.get(box_dists, line) {
    Ok(dist) -> {
      // echo "hit box cache!"
      dist
    }
    Error(Nil) -> {
      let dx = a.x - b.x
      let dy = a.y - b.y
      let dz = a.z - b.z
      let dist = dx * dx + dy * dy + dz * dz
      let assert Ok(#(circuit_dists, box_dists)) = cell.read(cache)
      let _ =
        cell.write(cache, #(circuit_dists, dict.insert(box_dists, line, dist)))
      dist
    }
  }
}

fn cached_circuit_distance(a: Set(Box), b: Set(Box), cache: Cache) -> Int {
  let assert Ok(#(circuit_dists, _)) = cell.read(cache)

  let circuit_line = set.from_list([a, b])
  case dict.get(circuit_dists, circuit_line) {
    Ok(dist) -> {
      echo "hit circuit cache!"
      dist
    }
    Error(Nil) -> {
      let a_list = set.to_list(a)
      let b_list = set.to_list(b)

      let assert Some(dist) =
        list.fold(a_list, None, fn(min, a) {
          let next_min =
            list.fold(b_list, None, fn(min, b) {
              let next_min = cached_distance(a, b, cache)
              case min, next_min {
                None, _ -> Some(next_min)
                Some(min), _ -> Some(int.min(min, next_min))
              }
            })

          case min, next_min {
            None, None -> None
            Some(min), None -> Some(min)
            None, Some(next_min) -> Some(next_min)
            Some(min), Some(next_min) -> Some(int.min(min, next_min))
          }
        })

      let assert Ok(#(circuit_dists, box_dists)) = cell.read(cache)
      let _ =
        cell.write(cache, #(
          dict.insert(circuit_dists, circuit_line, dist),
          box_dists,
        ))

      dist
    }
  }
}

fn closest_circuits(
  circuits: List(Set(Box)),
  cache: Cache,
) -> #(Set(Box), Set(Box)) {
  let pairs = list.combination_pairs(circuits)

  echo list.length(pairs)

  let assert Some(best) =
    list.fold(pairs, None, fn(acc, p) {
      let dist = cached_circuit_distance(p.0, p.1, cache)
      let candidate = Some(#(p.0, p.1, dist))

      case acc {
        None -> candidate
        Some(#(_, _, best_d)) ->
          case dist < best_d {
            True -> candidate
            False -> acc
          }
      }
    })

  #(best.0, best.1)
}

fn join(circuits: List(Set(Box)), a: Set(Box), b: Set(Box)) {
  let #(circuits, conn) = {
    use #(next, conn), circuit <- list.fold(circuits, #([], set.new()))

    case circuit == a, circuit == b {
      True, _ | _, True -> #(next, set.union(conn, circuit))
      _, _ -> #([circuit, ..next], conn)
    }
  }

  [conn, ..circuits]
}

fn step(circuits: List(Set(Box)), cache: Cache) {
  let #(a, b) = closest_circuits(circuits, cache)
  echo "found closest circuits!"
  let next_circuits = join(circuits, a, b)
  echo "joined circuits!"
  next_circuits
}

fn step_n_loop(
  circuits: List(Set(Box)),
  curr: Int,
  max: Int,
  cache: Cache,
) -> List(Set(Box)) {
  case curr >= max {
    True -> circuits
    False -> step_n_loop(step(circuits, cache), curr + 1, max, cache)
  }
}

fn step_n(circuits: List(Set(Box)), n: Int) -> List(Set(Box)) {
  let cell = cell.new_table() |> cell.new()
  let _ = cell.write(cell, #(dict.new(), dict.new()))
  step_n_loop(circuits, 1, n, cell)
}

pub fn pt_1(input: String) {
  step_n(parse(input), 1000)
  |> list.map(set.size)
  |> list.sort(order.reverse(int.compare))
  |> list.take(3)
  |> list.fold(1, int.multiply)
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
