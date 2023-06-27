package erldin_tests

import "core:testing"
import "core:fmt"
import "core:os"
import "core:mem"
import "core:log"
import "core:runtime"

import "../erldin"

TEST_count := 0
TEST_fail := 0

when ODIN_TEST {
  expect :: testing.expect
  log :: testing.log
} else {
  expect :: proc(t: ^testing.T, condition: bool, message: string, loc := #caller_location) {
    TEST_count += 1
    if !condition {
      TEST_fail += 1
      fmt.printf("[%v] %v\n", loc, message)
      return
    }
  }
}

expect_no_leaks :: proc(t: ^testing.T, allocator: mem.Tracking_Allocator) {
  expect(
    t,
    len(allocator.allocation_map) == 0,
    fmt.tprintf("len(allocator.allocation_map) != 0: %v\n", len(allocator.allocation_map)),
  )
  if len(allocator.allocation_map) != 0 {
    i := 0
    for _, allocation in allocator.allocation_map {
      fmt.printf("[%d] %v\n", i, allocation)
      i += 1
    }
  }
}

main :: proc() {
  context.logger = log.create_console_logger()

  t := testing.T{}

  test_find_paths(&t)

  fmt.printf("%v\n\t%v/%v tests successful.\n", #location(), TEST_count - TEST_fail, TEST_count)
  if TEST_fail > 0 {
    os.exit(1)
  }
}

test_find_paths :: proc(t: ^testing.T) {
  tracking_allocator := mem.Tracking_Allocator{}
  mem.tracking_allocator_init(&tracking_allocator, runtime.default_allocator())
  context.allocator = mem.tracking_allocator(&tracking_allocator)
  defer expect_no_leaks(t, tracking_allocator)

  os.set_env("ERLANG_USR", "")

  paths, err := erldin.find_paths()
  expect(
    t,
    err == erldin.NoEnvironmentVariableSet{key = "ERLANG_USR"},
    "err != NoEnvironmentVariableSet",
  )
  expect(t, paths.include == "", "paths.include != \"\"")
  expect(t, paths.lib == "", "paths.lib != \"\"")
}
