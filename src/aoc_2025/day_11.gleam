import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
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

fn sort_loop(
  node: String,
  graph: Dict(String, List(String)),
  stack: List(String),
  visited: Set(String),
) {
  use <- bool.guard(set.contains(visited, node), #(stack, visited))

  let next_visited = set.insert(visited, node)
  let neighbours = dict.get(graph, node) |> result.unwrap([])

  list.fold(neighbours, #(stack, next_visited), fn(acc, neighbour) {
    let #(stack, visited) = acc
    case set.contains(visited, neighbour) {
      False -> sort_loop(neighbour, graph, stack, visited)
      True -> acc
    }
  })
  |> pair.map_first(list.prepend(_, node))
}

fn sort(graph: Dict(String, List(String))) {
  let visited = set.new()
  let stack = []

  dict.fold(graph, #(stack, visited), fn(acc, node, _) {
    sort_loop(node, graph, acc.0, acc.1)
  })
  |> pair.first()
  |> list.reverse()
}

fn paths_loop(
  graph: Dict(String, List(String)),
  nodes: List(String),
  counts: Dict(String, Int),
) -> Dict(String, Int) {
  case nodes {
    [] -> counts
    [node, ..rest] -> {
      case node {
        "out" -> dict.insert(counts, "out", 1)
        _ ->
          dict.get(graph, node)
          |> result.unwrap([])
          |> list.map(fn(neighbour) {
            dict.get(counts, neighbour) |> result.unwrap(0)
          })
          |> int.sum()
          |> dict.insert(counts, node, _)
      }
      |> paths_loop(graph, rest, _)
    }
  }
}

fn paths(graph: Dict(String, List(String)), sorted_nodes: List(String)) {
  let assert Ok(paths) =
    paths_loop(graph, sorted_nodes, dict.new()) |> dict.get("you")
  paths
}

pub fn pt_1(input: String) {
  let graph = parse(input)
  sort(graph) |> paths(graph, _)
}

pub fn pt_2(input: String) {
  todo as "part 2 not implemented"
}
