package erldin

import "core:os"
import "core:mem"
import "core:strings"

Paths :: struct {
  include: string,
  lib:     string,
}

FindPathsError :: union {
  mem.Allocator_Error,
  NoEnvironmentVariableSet,
}

NoEnvironmentVariableSet :: struct {
  key: string,
}

find_paths :: proc(allocator := context.allocator) -> (paths: Paths, error: FindPathsError) {
  env_directory := os.get_env("ERLANG_USR", allocator)
  if env_directory == "" {
    return Paths{}, NoEnvironmentVariableSet{key = "ERLANG_USR"}
  }

  include_directory := strings.concatenate({env_directory, "/include"}, allocator) or_return
  lib_directory := strings.concatenate({env_directory, "/lib"}, allocator) or_return

  return Paths{include = include_directory, lib = lib_directory}, nil
}
