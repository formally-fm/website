---
title: A Midsummer Night's Development
date: 2026-08-28
author: Nicola Gigante
authorweb: https://www.inf.unibz.it/~gigante/
---

A new summer release is available with important developments for the SMT module.

<!--more-->

# The new release

After a couple of months spent on the Rust/C++ translation layer I talked about
in the [previous post](/blog/first-three-months) I had to remember I still have
a day job, which requires some times to do other things.

Then, approximately a month ago I resumed work on `::formally`, but this time to
strenghten the SMT module.

The new release comes with great changes, including:
1. a completely new and much easier interface to write new SMT backends
2. a completely rewritten `Z3` backend based on the new interface
3. a new `cvc5` backend based on the new interface
4. a complete refactoring of how terms are constructed, including hash-consing
   and the special `term!()` macro used to build them conveniently.
5. support for quantified terms and `let` expressions
6. fixes and improvements to the (still incomplete) implementation of the 
   SMT-LIBv2 language
7. many many little improvements and fixes...

Testing and improving the quality of the implementation of the SMT-LIBv2
language are the next steps.
