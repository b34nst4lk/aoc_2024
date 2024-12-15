import gleeunit
import gleeunit/should
import solutions/day_7.{unadd, unconcat, unmultiply}

pub fn main() {
  gleeunit.main()
}

// gleeunit test functions end in `_test`
pub fn hello_world_test() {
  1
  |> should.equal(1)
}

// test unconcat
pub fn unconcat_test() {
  let assert Ok(res) = unconcat(1234, 34)
  res |> should.equal(12)
  unconcat(1234, 33) |> should.be_error
}

// test unmultiply
pub fn unmultiply_test() {
  let assert Ok(res) = unmultiply(1234, 2)
  res |> should.equal(617)
  unconcat(1234, 33) |> should.be_error
}

// test unadd
pub fn unadd_test() {
  let assert Ok(res) = unadd(1234, 2)
  res |> should.equal(1232)
  unconcat(1234, 1235) |> should.be_error
}
