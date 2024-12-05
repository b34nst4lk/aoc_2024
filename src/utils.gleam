import gleam/io
import simplifile

pub fn open(filename: String) -> String {
  io.debug(filename)
  let assert Ok(result) = simplifile.read(from: filename)
  result
}
