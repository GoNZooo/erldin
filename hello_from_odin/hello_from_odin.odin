package hello_from_odin

import "core:c"

import "../erldin"

entry := erldin.ErlNifEntry{}

hello :: proc "c" (env: ^erldin.ErlNifEnv, argc: c.int, argv: [^]cstring) -> erldin.ERL_NIF_TERM {
  return erldin.enif_make_string(
    env,
    "Hello World from Odin!",
    u32(erldin.encoding.ERL_NIF_LATIN1),
  )
}

nif_functions := [?]erldin.ErlNifFunc{
  {name = "hello", arity = 0, fptr = erldin.Nif(hello), flags = 0},
}

@(export)
nif_init :: proc "c" () -> ^erldin.ErlNifEntry {
  entry.major = 2
  entry.minor = 16
  entry.name = "Elixir.HelloWorldInOdin"
  entry.funcs = raw_data(nif_functions[:])
  entry.num_of_funcs = len(nif_functions)
  entry.vm_variant = "beam.vanilla"
  entry.options = 1
  entry.sizeof_ErlNifResourceTypeInit = size_of(erldin.ErlNifResourceTypeInit)
  entry.min_erts = "erts-12.0"

  return &entry
}
