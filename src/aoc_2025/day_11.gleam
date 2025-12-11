import gleam/dict.{type Dict}
import gleam/list
import gleam/pair
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
  cache: Dict(#(String, Set(String)), Int),
  node: String,
  required: Set(String),
  visited_required: Set(String),
) -> #(Int, Dict(#(String, Set(String)), Int)) {
  case dict.get(cache, #(node, visited_required)) {
    Ok(n) -> #(n, cache)
    Error(Nil) -> {
      case node {
        "out" -> {
          case required == visited_required {
            True -> #(1, cache)
            False -> #(0, cache)
          }
        }
        _ -> {
          dict.get(graph, node)
          |> result.unwrap([])
          |> list.fold(#(0, cache), fn(acc, neighbour) {
            let #(n_acc, cache) = acc

            let visited_required = case set.contains(required, node) {
              True -> set.insert(visited_required, node)
              False -> visited_required
            }

            let #(n, cache) =
              paths_loop(graph, cache, neighbour, required, visited_required)

            #(n_acc + n, dict.insert(cache, #(neighbour, visited_required), n))
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
  paths_loop(graph, dict.new(), start, required, set.new())
  |> pair.first()
}

pub fn pt_1(input: String) {
  parse(input) |> paths("you", set.new())
}

pub fn pt_2(input: String) {
  let required = set.new() |> set.insert("dac") |> set.insert("fft")
  parse(input) |> paths("svr", required)
}
