import gleam/int

pub fn parse(input: String) {
  let assert Ok(nr) = int.parse(input)
  nr
}
