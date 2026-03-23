---
title: Welcome
---

Welcome to the website of `::formally`, an early-stage project providing a set
of composable components useful to develop **formal methods** tools and
applications.

# News from the blog

{{< blogposts >}}

[SMT-LIB]: https://smtlib.cs.uiowa.edu

# What is `::formally`

`::formally` is a set of reusable and composable components that help with the
development of formal methods tools. More concretely, `::formally` is a set of
libraries written in the Rust programming language (**crates** in the Rust
lingo) providing useful building blocks to ease the life of the formal methods
researcher.

*Currently*, the framework provides the following:

1. a flexible **parsing** infrastructure supporting the easy definition of
   high-quality parsers producing detailed syntax trees and precise and
   informative **error messages**.
2. a detailed implementation of the [SMT-LIB] standard language, including a
   precise parser for the language, an extensible implementation of its type
   system and an abstraction layer on top of SMT solvers.

In the near future, the project will provide similar abstractions on top of
**model checkers** and other kinds of backend tools, and will be accessible and
**extensible** using multiple programming languages (currently planned are at
least C++ and Python).

The project is in a **very early** stage of development.

For more information on the project's vision, please read the [announcement blog post](/blog/first-version-released-formally/).