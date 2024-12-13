import gleam/string
import simplifile

pub fn open(filename: String) -> String {
  let assert Ok(result) = simplifile.read(from: filename)
  string.trim(result)
}
