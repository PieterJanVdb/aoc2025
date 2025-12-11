import cell
import gleam/dict.{type Dict}
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

fn parse(input: String) {
  string.split(input, "\n")
  |> list.map(fn(line) {
    let assert Ok(#(device, outputs)) = string.split_once(line, ":")
    let outputs = string.trim(outputs) |> string.split(" ")
    #(device, outputs)
  })
  |> dict.from_list()
}

fn paths_loop(
  graph: Dict(String, List(String)),
  cache_cell: cell.Cell(Dict(#(String, Set(String)), Int)),
  node: String,
  required: Set(String),
  visited_required: Set(String),
) -> Int {
  let assert Ok(cache) = cell.read(cache_cell)
  case dict.get(cache, #(node, visited_required)) {
    Ok(n) -> n
    Error(Nil) -> {
      case node {
        "out" -> {
          case required == visited_required {
            True -> 1
            False -> 0
          }
        }

        _ -> {
          dict.get(graph, node)
          |> result.unwrap([])
          |> list.fold(0, fn(acc, neighbour) {
            let visited_required = case set.contains(required, node) {
              True -> set.insert(visited_required, node)
              False -> visited_required
            }

            let n =
              paths_loop(
                graph,
                cache_cell,
                neighbour,
                required,
                visited_required,
              )

            let assert Ok(cache) = cell.read(cache_cell)
            let _ =
              cell.write(
                cache_cell,
                dict.insert(cache, #(neighbour, visited_required), n),
              )
            acc + n
          })
        }
      }
    }
  }
}

fn paths(
  graph: Dict(String, List(String)),
  start: String,
  required: Set(String),
) {
  let cell = cell.new_table() |> cell.new()
  let _ = cell.write(cell, dict.new())
  paths_loop(graph, cell, start, required, set.new())
}

pub fn pt_1(input: String) {
  parse(input) |> paths("you", set.new())
}

pub fn pt_2(input: String) {
  let required = set.new() |> set.insert("dac") |> set.insert("fft")
  parse(input) |> paths("svr", required)
}
