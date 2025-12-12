import aoc_2025/utils/grid.{type Grid}
import aoc_2025/utils/int_extra
import gleam/dict.{type Dict}
import gleam/list
import gleam/string

type Shape {
  Shape(grid: Grid(Int), size: Int)
}

type Region {
  Region(dimensions: #(Int, Int), quantities: Dict(Int, Int))
}

fn parse(input: String) {
  let blocks = string.split(input, "\n\n") |> list.reverse()

  let shapes =
    list.drop(blocks, 1)
    |> list.reverse()
    |> list.index_map(fn(shape, idx) {
      let grid =
        string.split(shape, "\n")
        |> list.drop(1)
        |> string.join("\n")
        |> grid.new_mapped(fn(char) {
          case char {
            "#" -> 1
            _ -> 0
          }
        })
      let size =
        dict.values(grid) |> list.filter(fn(e) { e == 1 }) |> list.length()

      #(idx, Shape(grid:, size:))
    })
    |> dict.from_list()

  let assert Ok(regions) = list.first(blocks)

  let regions =
    string.split(regions, "\n")
    |> list.map(fn(line) {
      let assert Ok(#(size, quantities)) = string.split_once(line, ":")
      let assert Ok(#(width, height)) = string.split_once(size, "x")
      let dimensions = #(int_extra.parse(width), int_extra.parse(height))
      let quantities =
        string.trim(quantities)
        |> string.split(" ")
        |> list.index_map(fn(quantity, idx) {
          #(idx, int_extra.parse(quantity))
        })
        |> dict.from_list()

      Region(dimensions:, quantities:)
    })

  #(shapes, regions)
}

fn filter_tiny(regions: List(Region), shapes: Dict(Int, Shape)) {
  list.filter(regions, fn(region) {
    let size = region.dimensions.0 * region.dimensions.1

    let shapes_size =
      dict.to_list(region.quantities)
      |> list.fold(0, fn(acc, entry) {
        let #(idx, quantity) = entry
        let assert Ok(shape) = dict.get(shapes, idx)
        acc + quantity * shape.size
      })

    shapes_size <= size
  })
}

pub fn pt_1(input: String) {
  let #(shapes, regions) = parse(input)
  filter_tiny(regions, shapes) |> list.length()
}

pub fn pt_2(_input: String) {
  "no part 2"
}
