---
title: "The first three months: progress and news"
date: 2026-03-23
author: Nicola Gigante
authorweb: https://www.inf.unibz.it/~gigante/
---

No new releases have been published since the first announcement post of the
project three months ago, but there are nevertheless interesting things going
on.

<!--more-->

# A cross-language problem

Before announcing the project, I focused on publishing three foundational
modules: [`formally::support`], [`formally::io`], and [`formally::smt`]. These
are just the first components of what is planned to be an ecosystem of reusable
pieces that can be used to compose a formal methods research tool.

However, as the [announcement post] explains briefly, `formally` is not meant to
be **just** a collection of Rust libraries, because restricting the audience to
users of a single programming language, albeit one with growing popularity like
Rust, goes against the stated goal of opening the project to the community as
much as possible.

For this reason, it is **crucial** for my vision of the project for `formally`
to be usable and extensible from other programming languages.

1. first and more urgently, `formally` has to be usable and extensible from
   **C++**, which is the language used to implement the majority of the SAT,
   SMT, CSP solvers out there and many other kinds of tools the project may want
   to interface with. 

   For example, the [`formally::smt`] module currently includes a backend for
   `Z3` written using a thin wrapper over its C API, but the approach is not
   scalable to other solvers, many of which only have a C++ API which is quite
   more difficult to wrap around. I would like to include a backend for `cvc5`,
   for the example, but the latter is only accessible via C++.

2. then, for fast prototyping and lower entry barrier, being able to use and
   extend `formally` from Python is the next important goal. I'm not really a
   fan of Python myself, but I cannot deny the fact that this is one of the most
   popular languages out there, and it can be especially useful to bring up
   quick experiments and simple tools.

Rust can interface quite well with Python using the popular [pyO3] library, but
the same cannot be said with C++. The [cxx] library is usually cited as a
solution for the interoperation between the two languages. However, it has
some drawbacks for my use case:

1. it requires one to declare up front all the types, functions, etc. used at
   the boundary between the two languages. One needs to design a minimal
   interface layer between the Rust and the C++ components of the project,
   declare them using the `#[cxx::bridge]` attribute, and use the package's
   tooling to generate approriate C++ headers from that.

   This approach is useful in many cases but not adequate to the needs of
   `formally`, which I want to be usable and extensible **entirely** from C++.
   It is not possible to design a minimal interface layer, if all the API of the
   library has to be accessible.

2. it does not support generic types, except for specially blessed types such as
   `Vec<T>`. This limits the kind of Rust APIs one can export to the other side,
   and again goes against the goal of exposing the entire API surface of
   `formally` to C++.

Moreover, as Python and C++ are just two of the many languages out there,
working with ad-hoc solutions for each language is not scalable. What about
bindings to JavaScript or Swift the next time?

For this reason, in the last three months I have been looking at a centralized
solution that would allow me to use and extend `formally` in C++, Python and, in
the future, other languages.

# Bridging Rust to the world

This problem seems quite similar to what happens in the design of multi-platform
compilers. You have one front-end language, but many architectures you want to
compile to, and you want to repeat as little work as possible. So compilers
usually employ an **intermediate representation** (IR): the front-end language
is translated to the IR once, and then many backends can be written to support
the different architectures.

The solution I'm working on works exactly in this way. 

1. given a Rust library to be exported to other languages, the library's source
   code is parsed and analysed once, producing another little interface library,
   called a **bridge**, which exposes a well-defined low-level C API that maps
   to the original Rust API;
2. on top of the C API calling the actual Rust functions and methods, the 
   bridge also contains the **metadata** extracted from the analysis phase;
3. the metadata can be used to generate precise and expressive bindings for any
   language that can link to a C API.

For C++, the bridge's metadata are used to generate C++ headers that, linking to
the bridge itself, expose a high-level C++ interface for the Rust code. For
Python, a Rust-made Python module can dynamically load the bridge and use the
metadata to expose the API to the interpreter.

The end result will be able to expose expressive Rust APIs to idiomatic C++,
incurring only a negligible overhead, avoiding expensive data marshalling. 

In particular, it will be possible to:

1. export almost any Rust type, including generic types and those not marked
   with `#[repr(C)]`;
2. pass objects of Rust types by value in C++, with copies handled by `Clone` 
   implementations and `std::move()` doing almost what a Rust move does;
3. use Rust generic types with C++ type parameters (e.g. `Vec<std::string>`);
4. use Rust traits as C++20 concepts;
5. use `dyn`-compatible Rust traits as pure virtual base classes, with derived 
   classes passed as `dyn Trait` or `impl Trait` parameters to Rust functions;
6. match on Rust enums in C++ using an `std::visit()`-like interface;
7. pass C++ lambdas to Rust code expecting `impl Fn()` and similar types;
8. integrate language features such as Rust iterators and C++ range-for loops 
   and traits for operator overloading.

An example pseudo-code of what should be possible to do when exporting, e.g.,
the Rust standard library to C++:
```
#include <iostream>

// the header generated from the standard library bridge
#include <rust> 

using namespace rust;

int main() {
   Vec<std::string> messages; // Rust Vec, C++ elements

   messages.push("hello world!"); // Rust method, C++ argument
   messages.push("bye bye!");

   // `IntoIterator` type turned into a C++ range
   for(auto msg: messages) {
      std::cout << msg << "\n";
   }

   return 0;
}
```

# Show me the code

Not yet, I'm sorry. Currently I'm about half-way to proving that all this is
possible. I have a prototype (still too young to be published) of the code
extracting the bridge and its metadata from the desired Rust crates, and a
concrete path torwards the generation of the C++ headers to make the above code
work.

To parse Rust code, I use the APIs of [`rust-analyzer`], the component usually
employed as the backend the Language Server Protocol for IDEs and editors.
`rust-analyzer` implements an extremely precise Rust front-end and exposes the
AST and all the semantic information I need.

The missing part is then the generation of the corresponding C++ headers,
improving the generated bridge along the way. As this is not my full-time
occupation, work is slow and unpredictable so I won't set a release date.

# Conclusions

How much work can be done without cutting a single new release? Apparently a
lot. I've been designing this cross-language binding system for months now and
it's starting to get in shape. It seems a strange side-quest, given the original
scope of `formally`, but the cross-language nature of the vision I have for the
project is crucial. 

The next step will be to use it to implement solid SMT backends for the
[`formally::smt`] module, and then expand the framework into new directions
unrelated to SMT and SAT solving (first of all, model checking).

Stay tuned!


[announcement post]: /blog/first-version-released-formally/
[`formally::support`]: https://docs.rs/formally/latest/formally/support/
[`formally::io`]: https://docs.rs/formally/latest/formally/io/
[`formally::smt`]: https://docs.rs/formally/latest/formally/smt/
[pyO3]: https://pyo3.rs
[cxx]: https://cxx.rs
[`rust-analyzer`]: https://rust-analyzer.github.io