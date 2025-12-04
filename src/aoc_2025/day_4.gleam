import aoc_2025/utils/grid
import gleam/dict.{type Dict}
import gleam/list

fn to_entry(str: String) -> Bool {
  case str {
    "@" -> True
    _ -> False
  }
}

fn is_accessible(grid: Dict(#(Int, Int), Bool), coord: #(Int, Int)) -> Bool {
  grid.compass_neighbours(grid, coord)
  |> list.filter(fn(val) { val == True })
  |> list.length
  < 4
}

fn get_accessible_rolls(grid: Dict(#(Int, Int), Bool)) -> List(#(Int, Int)) {
  dict.filter(grid, fn(_, value) { value == True })
  |> dict.keys
  |> list.filter(is_accessible(grid, _))
}

fn remove_rolls(
  grid: Dict(#(Int, Int), Bool),
  rolls: List(#(Int, Int)),
) -> Dict(#(Int, Int), Bool) {
  list.fold(rolls, grid, fn(grid, roll) { dict.insert(grid, roll, False) })
}

fn count_removeable_rolls(grid: Dict(#(Int, Int), Bool), removed: Int) -> Int {
  let accessible = get_accessible_rolls(grid)

  case list.length(accessible) {
    0 -> removed
    len ->
      remove_rolls(grid, accessible)
      |> count_removeable_rolls(removed + len)
  }
}

pub fn pt_1(input: String) {
  grid.new_mapped(input, to_entry)
  |> get_accessible_rolls
  |> list.length
}

pub fn pt_2(input: String) {
  grid.new_mapped(input, to_entry)
  |> count_removeable_rolls(0)
}
