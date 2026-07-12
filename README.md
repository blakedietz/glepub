# glepub

An EPUB toolkit for the Erlang and JavaScript targets — the format layer of
an EPUB reader, built on [glexml](https://github.com/blakedietz/glexml) and modelled on
[foliate-js](https://github.com/johnfactotum/foliate-js)'s architecture.

Like glexml underneath it, glepub performs no I/O. Opening a book takes a
`Loader` — `fn(String) -> Result(BitArray, Nil)` — mapping container paths
to bytes. Back it with a zip library on the server, a JSZip-style reader in
the browser, a directory on disk, or a dictionary in tests: the same format
code runs everywhere.

```gleam
import glepub

let assert Ok(book) = glepub.open(loader)

book.metadata.title       // "Moby-Dick"
book.metadata.creators    // [Contributor("Herman Melville", Some("aut"), ..)]
book.spine                // reading order, linear flags, resolved hrefs
book.toc                  // nested TocEntry tree (EPUB 3 nav or EPUB 2 NCX)
book.landmarks            // EPUB 3 landmarks, or the EPUB 2 guide
book.cover                // Option(ManifestItem), via property/meta/convention
book.rendition.layout     // Reflowable or PrePaginated

let assert Ok(chapter) = glepub.document(book, item)   // a glexml Document
```

Handles both EPUB 3 and EPUB 2: nav documents and NCX become the same
`TocEntry` tree, `meta refines` and `opf:` attributes both populate
contributor roles, and hrefs are percent-decoded and resolved relative to
the document that declared them.

## Development

```sh
gleam test                      # Erlang
gleam test --target javascript  # Node.js
```
