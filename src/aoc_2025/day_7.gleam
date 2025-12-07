import aoc_2025/utils/grid.{type Coord, type Grid}
import cell.{type Cell}
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/set.{type Set}

pub type Tile {
  Start
  Empty
  Splitter
}

pub type Visited {
  VisitedGeneric
  VisitedSplitter(Bool)
}

fn parse(input: String) -> Grid(Tile) {
  grid.new_mapped(input, fn(char) {
    case char {
      "S" -> Start
      "^" -> Splitter
      _ -> Empty
    }
  })
}

fn get_start(grid: Grid(Tile)) -> Coord {
  let assert Ok(entry) =
    dict.to_list(grid) |> list.find(fn(entry) { entry.1 == Start })
  entry.0
}

// fn get_splitters_count(grid: Grid(Tile), seen: Set(Coord)) {
//   set.filter(seen, fn(coord) {
//     case dict.get(grid, coord) {
//       Ok(Splitter) -> True
//       _ -> False
//     }
//   })
//   |> set.size()
// }

fn travel_loop(grid: Grid(Tile), pos: Coord, cell: Cell(Set(Coord))) {
  let assert Ok(hit) = cell.read(cell)
  case set.contains(hit, pos) {
    True -> 0
    False -> {
      let hit = set.insert(hit, pos)
      let _ = cell.write(cell, hit)
      case dict.get(grid, pos) {
        Error(_) -> 0
        Ok(Empty) | Ok(Start) -> travel_loop(grid, #(pos.0 + 1, pos.1), cell)
        Ok(Splitter) -> {
          1
          + travel_loop(grid, #(pos.0, pos.1 - 1), cell)
          + travel_loop(grid, #(pos.0, pos.1 + 1), cell)
        }
      }
    }
  }
}

pub fn travel_loop_2(
  grid: Grid(Tile),
  pos: Coord,
  cell: Cell(Dict(Coord, Visited)),
) {
  let assert Ok(visited) = cell.read(cell)
  case dict.get(visited, pos) {
    Ok(VisitedGeneric) | Ok(VisitedSplitter(True)) -> 0
    visited_state -> {
      case dict.get(grid, pos) {
        Error(_) -> {
          echo "sup"
          1
        }
        Ok(Start) | Ok(Empty) -> {
          let hit = dict.insert(visited, pos, VisitedGeneric)
          let _ = cell.write(cell, hit)
          0 + travel_loop_2(grid, #(pos.0 + 1, pos.1), cell)
        }
        Ok(Splitter) -> {
          case visited_state {
            Error(_) -> {
              let hit = dict.insert(visited, pos, VisitedSplitter(False))
              let _ = cell.write(cell, hit)
              0 + travel_loop_2(grid, #(pos.0, pos.1 - 1), cell)
            }
            Ok(VisitedSplitter(False)) -> {
              let hit = dict.insert(visited, pos, VisitedSplitter(True))
              let _ = cell.write(cell, hit)
              0 + travel_loop_2(grid, #(pos.0, pos.1 + 1), cell)
            }
            _ -> 0
          }
        }
      }
    }
  }
}

fn travel_1(grid: Grid(Tile)) {
  let cell = cell.new_table() |> cell.new()
  let _ = cell.write(cell, set.new())
  travel_loop(grid, get_start(grid), cell)
}

fn travel_2(grid: Grid(Tile)) {
  let cell = cell.new_table() |> cell.new()
  let _ = cell.write(cell, set.new())
  travel_loop(grid, get_start(grid), cell)
}

pub fn pt_1(input: String) {
  parse(input) |> travel_1()
}

pub fn pt_2(input: String) {
  let splitters = parse(input) |> travel_2()
  splitters * 2 - 2
}
