import gleam/bool
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
import gleam/set
import gleam/string

pub fn parse(input: String) -> List(#(Int, Int)) {
  let assert Ok(ranges) =
    string.split(input, ",")
    |> list.try_map(fn(range_str) {
      use #(start, end) <- result.try(string.split_once(range_str, "-"))
      use start <- result.try(int.parse(start))
      use end <- result.try(int.parse(end))
      Ok(#(start, end))
    })
  ranges
}

fn get_invalid_ids_loop(
  start: Int,
  end: Int,
  static_chunks: Option(Int),
  invalids: List(Int),
) {
  let invalids = case is_invalid(start, static_chunks) {
    True -> [start, ..invalids]
    False -> invalids
  }

  use <- bool.guard(when: start >= end, return: invalids)
  get_invalid_ids_loop(start + 1, end, static_chunks, invalids)
}

fn get_invalid_ids(start: Int, end: Int, static_chunks: Option(Int)) {
  get_invalid_ids_loop(start, end, static_chunks, [])
}

fn is_invalid(n: Int, static_chunks: Option(Int)) -> Bool {
  let digits =
    int.to_string(n)
    |> string.split("")

  let digits_len = list.length(digits)

  case static_chunks {
    Some(static_chunks) if digits_len % static_chunks == 0 -> {
      let size = digits_len / static_chunks
      check_chunks(digits, digits_len, size, size)
    }
    None -> check_chunks(digits, digits_len, 1, digits_len / 2)
    _ -> False
  }
}

fn check_chunks(
  digits: List(String),
  digits_len: Int,
  size: Int,
  max: Int,
) -> Bool {
  let invalid = case digits_len % size == 0 && digits_len > size {
    False -> False
    True -> {
      list.sized_chunk(digits, into: size)
      |> set.from_list
      |> set.size
      == 1
    }
  }

  use <- bool.guard(when: invalid, return: True)
  use <- bool.guard(when: size >= max, return: False)

  check_chunks(digits, digits_len, size + 1, max)
}

pub fn pt_1(input: List(#(Int, Int))) {
  list.flat_map(input, fn(range) { get_invalid_ids(range.0, range.1, Some(2)) })
  |> int.sum()
}

pub fn pt_2(input: List(#(Int, Int))) {
  list.flat_map(input, fn(range) { get_invalid_ids(range.0, range.1, None) })
  |> int.sum()
}
