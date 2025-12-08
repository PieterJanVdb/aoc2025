import aoc_2025/utils/grid.{type Coord, type Grid}
import cell.{type Cell}
import gleam/dict.{type Dict}
import gleam/list
import gleam/pair
import gleam/result

type Tile {
  Start
  Empty
  Splitter
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

fn get_start(grid: Grid(Tile)) {
  result.map(
    dict.to_list(grid) |> list.find(fn(entry) { entry.1 == Start }),
    with: pair.first,
  )
}

fn trace_loop(grid: Grid(Tile), pos: Coord, cell: Cell(Dict(Coord, Int))) {
  let assert Ok(timelines_map) = cell.read(cell)
  case dict.get(timelines_map, pos) {
    Ok(timelines) -> Ok(timelines)
    Error(Nil) -> {
      case dict.get(grid, pos) {
        Error(_) -> Ok(0)
        Ok(Empty) | Ok(Start) -> trace_loop(grid, #(pos.0 + 2, pos.1), cell)
        Ok(Splitter) -> {
          use left <- result.try(trace_loop(grid, #(pos.0, pos.1 - 1), cell))
          use right <- result.try(trace_loop(grid, #(pos.0, pos.1 + 1), cell))
          let timelines = left + right + 1

          use timelines_map <- result.try(cell.read(cell))
          let _ = cell.write(cell, dict.insert(timelines_map, pos, timelines))

          Ok(timelines)
        }
      }
    }
  }
}

fn trace(grid: Grid(Tile)) {
  let cell = cell.new_table() |> cell.new()
  let _ = cell.write(cell, dict.new())
  use start <- result.try(get_start(grid))
  use timelines <- result.try(trace_loop(grid, start, cell))
  use seen <- result.try(cell.read(cell))
  Ok(#(dict.size(seen), timelines + 1))
}

pub fn pt_1(input: String) {
  parse(input) |> trace() |> result.map(pair.first)
}

pub fn pt_2(input: String) {
  parse(input) |> trace() |> result.map(pair.second)
}
