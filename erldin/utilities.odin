package erldin

import "core:mem"
import "core:c"

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

foreign import erldin "erldin_nif.h"
foreign erldin {
  enif_make_binary :: proc(env: ^ErlNifEnv, bin: ^ErlNifBinary) -> ERL_NIF_TERM ---
  enif_make_string :: proc(env: ^ErlNifEnv, string: cstring, encoding: c.uint) -> ERL_NIF_TERM ---
}

ErlNifBinary :: struct {
  size:      c.size_t,
  data:      [^]u8,
  ref_bin:   rawptr,
  __spare__: [2]rawptr,
}

ErlNifResourceTypeInit :: struct {
  dtor:    rawptr,
  stop:    rawptr,
  down:    rawptr,
  members: c.int,
  dyncall: rawptr,
}

ErlNifEntry :: struct {
  major:                         c.int,
  minor:                         c.int,
  name:                          cstring,
  num_of_funcs:                  c.int,
  funcs:                         [^]ErlNifFunc,
  load:                          LoadFunction,
  reload:                        ReloadFunction,
  upgrade:                       UpgradeFunction,
  unload:                        UnloadFunction,
  vm_variant:                    cstring,
  options:                       c.uint,
  sizeof_ErlNifResourceTypeInit: c.size_t,
  min_erts:                      cstring,
}

ErlNifEnv :: rawptr

ERL_NIF_TERM :: c.uint

LoadFunction :: proc(env: ^ErlNifEnv, priv_data: [^]rawptr, load_info: ERL_NIF_TERM) -> c.int

ReloadFunction :: proc(env: ^ErlNifEnv, priv_data: [^]rawptr, load_info: ERL_NIF_TERM) -> c.int

UpgradeFunction :: proc(
  env: ^ErlNifEnv,
  priv_data: [^]rawptr,
  old_priv_data: [^]rawptr,
  load_info: ERL_NIF_TERM,
) -> c.int

UnloadFunction :: proc(env: ^ErlNifEnv, priv_data: rawptr)

ErlNifFunc :: struct {
  name:  cstring,
  arity: c.uint,
  fptr:  Nif,
  flags: c.uint,
}

Nif :: proc(env: ^ErlNifEnv, argc: c.int, argv: [^]ERL_NIF_TERM) -> ERL_NIF_TERM

encoding :: enum u32 {
  ERL_NIF_LATIN1 = 1,
}
