# String8 Library

## Introduction

This is a custom string library implemented in C that provides
a length-prefixed, non-null-terminated string type (`str8`)
along with a comprehensive set of operations for inspection,
transformation, and manipulation. Unlike standard C strings,
`str8` carries its length explicitly, which avoids repeated
`strlen` calls and makes the type safe to use with binary data
or substrings that contain embedded null bytes.

The library ships every mutating/allocating operation in
**three flavors**, so you can pick the memory strategy that
fits your program:

- **Malloc**: standard heap allocation via `malloc`/`free`.
- **Arena**: bump-allocated from an `Arena` (see
  [Memory-Allocators][memalloc]) for fast, bulk-freed
  allocations.
- **Pool**: allocated from a `Pool` (see
  [Memory-Allocators][memalloc]) when individual frees
  are needed.

## Features

The library provides the `str8` type as defined in
`string8.h`:

```c
typedef struct string8 str8;

struct string8 {
  u64 s_str; // length of the string in bytes
  u8* str;   // pointer to the (not necessarily null-terminated) byte buffer
};
```

- **Convenience Macros:**

  * `STR8_LIT(s)`: build a `str8` from a C string literal
  * `STR8_FMT(s)`: expand a `str8` into `(int, char*)` for
    use with `printf("%.*s", ...)`
  * `STR8_NULL`: an empty/null `str8` constant

- **Inspection:**

  * `string8_compare`: lexicographically compare two
    strings
  * `string8_starts_with` / `string8_ends_with` /
    `string8_contains`: substring checks
  * `string8_is_alpha` / `string8_is_num` /
    `string8_is_alpha_num`: character-class checks
  * `string8_indexes_of`: find every occurrence of a
    substring, returned as a `vector(u64)`
  * `string8_count_occur`: count occurrences of a
    substring
  * `string8_count_words`: count whitespace-separated
    words

- **In-place Transformation** (writes into a
  caller-provided `target`):

  * `string8_to_lower` / `string8_to_upper` /
    `string8_to_title`
  * `string8_reverse`

- **Allocating Operations** (available in `_malloc`
  (default), `_arena`, and `_pool` variants):

  * `string8_copy`: duplicate a string
  * `string8_trim`: strip leading/trailing whitespace
  * `string8_strip`: strip all whitespace
  * `string8_remove`: remove every occurrence of a
    substring
  * `string8_split`: split into a `vector(str8)` on a
    delimiter
  * `string8_join`: join a `vector(str8)` into a single
    string
  * `string8_replace`: replace every occurrence of a
    substring with another
  * `string8_repeat`: repeat a string `n` times
  * `string8_truncate`: cut a string at a given position
  * `string8_pad_start` / `string8_pad_end`: pad a string
    with another
  * `string8_substring`: extract a substring by range
  * `string8_format`: `printf`-style formatted string
    construction
  * `string8_read_file`: read a whole file into a `str8`

  Arena and Pool variants take an extra trailing `Arena*`
  / `Pool*` argument, e.g. `string8_copy_arena(source,
  arena)` and `string8_copy_pool(source, pool)`.

## Dependencies

- [Memory-Allocators][memalloc] — provides `Arena` and
  `Pool` used by the arena/pool variants
- [CVector][cvector] — provides the `vector(T)` generic
  vector type used for `vector(str8)` and `vector(u64)`
  return types

Both must be available on your include path (e.g.
installed to `/usr/local/include`) before building.

## Building

To build the static library, use the provided `makefile`.
The `make all` command will compile the source code and
create `libstring8.a` in the `build/` directory.

```
make all
```

## Installation

To install the library and its headers to standard system
directories (`/usr/local/lib` and `/usr/local/include`),
use the `make install` command.

```
make install
```

To remove the installed library and headers:

```
make uninstall
```

## Example Usage

```c
#include <string8/string8.h>
#include <stdio.h>
#include <assert.h>

int main() {
  str8 source = STR8_LIT("  Hello, String8 World!  ");

  // Trim whitespace (heap-allocated)
  str8 trimmed = string8_trim(source);
  printf("Trimmed: '%.*s'\n", STR8_FMT(trimmed));

  // Transform to upper case in place
  str8 upper = string8_copy(trimmed);
  string8_to_upper(upper, trimmed);
  printf("Upper: '%.*s'\n", STR8_FMT(upper));

  // Split into words
  vector(str8) words = string8_split(trimmed, STR8_LIT(" "));
  for (u64 i = 0; i < vector_size(words); i++)
    printf(
      "Word %llu: '%.*s'\n",
      i, STR8_FMT(vector_get(words, i))
    );

  // Replace a substring
  str8 replaced = string8_replace(
    trimmed, STR8_LIT("World"), STR8_LIT("C")
  );
  printf("Replaced: '%.*s'\n", STR8_FMT(replaced));

  // Check contents
  assert(string8_starts_with(trimmed, STR8_LIT("Hello")));
  assert(string8_contains(trimmed, STR8_LIT("String8")));

  return 0;
}
```

### Arena Variant Example

```c
#include <string8/string8.h>
#include <alloc/alloc.h>

int main() {
  Arena* arena = arena_create(KB(4), 100);
  assert(arena != NULL);

  str8 source = STR8_LIT("allocate me in the arena");
  str8 copy   = string8_copy_arena(source, arena);
  str8 upper  = string8_copy_arena(source, arena);
  string8_to_upper(upper, copy);

  printf("Arena copy: '%.*s'\n", STR8_FMT(upper));

  arena_destroy(arena);
  return 0;
}
```

## License

This project is licensed under the MIT License. See the
LICENSE file for details.

## Author

**Henrique Teixeira**

[memalloc]: https://github.com/UShouldRun/Memory-Allocators
[cvector]: https://github.com/UShouldRun/CVector
