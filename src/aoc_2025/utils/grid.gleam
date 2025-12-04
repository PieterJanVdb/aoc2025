import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/list
import gleam/order
import gleam/pair
import gleam/string

pub type Direction {
  N
  E
  S
  W
  NE
  SE
  SW
  NW
}

pub fn new_mapped(
  input: String,
  mapper: fn(String) -> a,
) -> Dict(#(Int, Int), a) {
  string.split(input, "\n")
  |> list.index_fold(dict.new(), fn(grid, line, r_idx) {
    string.split(line, "")
    |> list.index_fold(grid, fn(grid, val, c_idx) {
      dict.insert(grid, #(r_idx, c_idx), mapper(val))
    })
  })
}

pub fn new(input: String) {
  new_mapped(input, function.identity)
}

pub fn neighbour(grid: Dict(#(Int, Int), a), coord: #(Int, Int), dir: Direction) {
  case dir {
    E -> dict.get(grid, #(coord.0, coord.1 + 1))
    N -> dict.get(grid, #(coord.0 - 1, coord.1))
    NE -> dict.get(grid, #(coord.0 - 1, coord.1 + 1))
    NW -> dict.get(grid, #(coord.0 - 1, coord.1 - 1))
    S -> dict.get(grid, #(coord.0 + 1, coord.1))
    SE -> dict.get(grid, #(coord.0 + 1, coord.1 + 1))
    SW -> dict.get(grid, #(coord.0 + 1, coord.1 - 1))
    W -> dict.get(grid, #(coord.0, coord.1 - 1))
  }
}

pub fn compass_neighbours(
  grid: Dict(#(Int, Int), a),
  coord: #(Int, Int),
) -> List(a) {
  list.filter_map([E, N, NE, NW, S, SE, SW, W], neighbour(grid, coord, _))
}

pub fn cardinal_neighbours(
  grid: Dict(#(Int, Int), a),
  coord: #(Int, Int),
) -> List(a) {
  list.filter_map([E, N, S, W], neighbour(grid, coord, _))
}

pub fn print(grid: Dict(#(Int, Int), a), mapper: fn(a) -> String) -> String {
  dict.to_list(grid)
  |> list.sort(fn(a, b) {
    int.compare(a.0.0, b.0.0)
    |> order.break_tie(int.compare(a.0.1, b.0.1))
  })
  |> list.fold(#("", 0), fn(acc, entry) {
    let next_grid_str = case entry.0.0 > acc.1 {
      True -> acc.0 <> " |\n"
      False -> acc.0
    }
    #(next_grid_str <> " | " <> mapper(entry.1), entry.0.0)
  })
  |> pair.first()
}
