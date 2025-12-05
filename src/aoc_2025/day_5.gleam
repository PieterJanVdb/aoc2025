import gleam/int
import gleam/list
import gleam/pair
import gleam/string

fn split_input(input: String) {
  let assert Ok(#(ranges_str, ingredients_str)) =
    string.split_once(input, on: "\n\n")

  #(ranges_str, ingredients_str)
}

fn parse_ranges(ranges_str: String) {
  string.split(ranges_str, on: "\n")
  |> list.map(fn(range_str) {
    let assert Ok(#(start_str, end_str)) = string.split_once(range_str, on: "-")
    let assert Ok(start) = int.parse(start_str)
    let assert Ok(end) = int.parse(end_str)
    #(start, end)
  })
}

fn parse_ingredients(ingredients_str: String) {
  string.split(ingredients_str, on: "\n")
  |> list.map(fn(ingredient_str) {
    let assert Ok(ingredient) = int.parse(ingredient_str)
    ingredient
  })
}

fn is_fresh(ranges: List(#(Int, Int)), ingredient: Int) {
  list.any(ranges, fn(range) {
    let #(start, end) = range
    ingredient >= start && ingredient <= end
  })
}

fn overlaps(a: #(Int, Int), b: #(Int, Int)) {
  { a.0 >= b.0 && a.0 <= b.1 } || { b.0 >= a.0 && b.0 <= a.1 }
}

fn consolidate(a: #(Int, Int), b: #(Int, Int)) {
  #(int.min(a.0, b.0), int.max(a.1, b.1))
}

fn consolidate_ranges_loop(
  ranges: List(#(Int, Int)),
  consolidations: List(#(Int, Int)),
  consolidated: Bool,
) {
  case ranges, consolidated {
    [], False -> consolidations
    [], True -> consolidate_ranges_loop(consolidations, [], False)
    [hd, ..tl], _ -> {
      let #(consolidations, next_consolidated) =
        list.fold(consolidations, #([], False), fn(acc, range) {
          let #(consolidations, consolidated) = acc
          case overlaps(hd, range) {
            True -> #([consolidate(hd, range), ..consolidations], True)
            False -> #([range, ..consolidations], False || consolidated)
          }
        })
      let consolidations = case next_consolidated {
        True -> consolidations
        False -> [hd, ..consolidations]
      }
      consolidate_ranges_loop(
        tl,
        consolidations,
        consolidated || next_consolidated,
      )
    }
  }
}

fn consolidate_ranges(ranges: List(#(Int, Int))) {
  consolidate_ranges_loop(ranges, [], False)
}

pub fn pt_1(input: String) {
  let #(ranges, ingredients) =
    split_input(input)
    |> pair.map_first(parse_ranges)
    |> pair.map_second(parse_ingredients)
  list.filter(ingredients, is_fresh(ranges, _))
  |> list.length
}

pub fn pt_2(input: String) {
  let ranges = split_input(input) |> pair.map_first(parse_ranges) |> pair.first
  consolidate_ranges(ranges)
  |> list.fold(0, fn(acc, range) { acc + range.1 - range.0 + 1 })
}
