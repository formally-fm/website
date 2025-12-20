---
title: First version released... formally!
date: 2025-12-20
author: Nicola Gigante
authorweb: https://www.inf.unibz.it/~gigante/
---

It is with extreme pleasure that I write this first post to announce the **first
preview release** of `::formally`, a project I devoted a lot of effort to in the
last **six months**.

Last May, at the [SPIN] symposium, I presented the project's ideas and promised
a first preview release in **autumn**. Well, here we are, with the first
early-stage public release of the project, and **technically** still in autumn!

But what is this project about, what is included in today's release, and where
is the project going in the future? I will try to answer here, in order to final
write down my plans but also to start a discussion about the needs this project
is supposed to satisfy.

Discussions are supposed to happen on the [GitHub Discussions] page, so after
reading (or even before), if you feel like, drop a message!

The post is a bit long so feel free to jump to your favourite topic:
{{< toc >}}

# What is ::formally?

`::formally` is a project that aims to build a comprehensive open-source
framework and toolchain to help the development of formal methods applications.

I decided to start developing this project out of the experience I gained
developing [BLACK], a **satisfiability checker** for linear temporal logic and
similar formalisms. BLACK is cross-platform, easy to install thanks to packages
for the major operating systems, and extensively tested.

During the almost seven years of development of the tool, I
realised the majority of the time spent was devoted to things completely
unrelated to the tool's main mission: 
1. parsing and handling of I/O
2. interfacing with the (often not smooth) API of SAT and SMT solvers
3. dependency management
4. cross-platform packaging
5. testing and benchmarking
6. many other little things...

As a metric, consider that the main satisfiability algorithm implemented in
BLACK for **all the supported logics** accounts only for **~1500** lines out of
a total of **~22000** lines of C++ code, while packaging and dependency
management requires **~1200** lines of CMake code and benchmarking is handled by
a thousand lines of shell scripts.

While writing and maintaining in-house such a large amount of infrastructure
makes sense for large projects, little ones with only a few developers (in this
case just me and [Luca Geatti]) suffer. A large amount of effort is spent
which, in the **academic world**, pays no rent. Good engineering and proper
maintenance of the projects are completely unpublishable tasks, and small teams
do not have the possibility to fund development without visible returns.

As a result, uncountable promising little projects and tools developed by the
community either become unmaintained after the corresponding paper is published,
or are poorly tested, poorly packaged, and difficult to use.

The goal of `::formally` is to greatly lower the bar for developing formal
methods tools, by providing a comprehensive framework and toolchain that lets
researchers **focus on implementing their new idea** without wasting time on
everything else, while at the same time getting a high quality result.

This goal will be achieved by the development of a number of independent but
interacting components offering to the researcher many useful services:
1. **parsing** and **translation** between common text file formats:  
   SMT-LIBv2, MoXI, SMV, DIMACS, AIGER, BTOR2, ...
2. **high-level** interfaces for interacting with existing industry-standard 
   tools:  
   SAT/QBF/SMT solvers, model checkers, synthesis tools, ...
3. common **data structures**:  
   explicit and symbolic automata, decision diagrams, logical formulas and circuits, ...
3. unified and **reproducible** testing and benchmarking infrastructure
4. unified **packaging** and distribution infrastructure

Of all this utopy, today I've released just a small initial chunk.

## Ok, but what *actually* is ::formally?

`::formally` is currently a [Rust library] providing the following components (*crates* in Rust's gergo):
1. `formally::support` provides common facilities useful for the rest of the
   project. Crucially, it provides a mechanism of error reporting based on the
   concept of **diagnostic**, similar to what seen in many modern compilers, that helps producing precise and informative error messages throughout the
   project.
2. `formally::io` provides utilities to parse input and produce output. The main
   part of the module is a **parser combinators** library that allows easy and
   quick writing of parsers that automatically produce precise and high-quality
   error messages, integrated with the project's error reporting infrastructure.
3. `formally::smt` provides an abstraction over Satisfiability Modulo Theories
   solvers and (what will hopefully become) a fully conformant implementation of
   the SMT-LIBv2 language.
4. A simple toy command-line frontend to test the `formally::smt` module.

The `formally::smt` module is still under quite heavy development but can
already handle simple SMT-LIBv2 scripts, solving them with a [Z3] backend.

You can try it yourself. Follow the instructions on the [README] to install the
command-line interface, pick up an SMT-LIBv2 file, and just run:

```
$ formally solve file.smtlib
```

The command above also explains why I chose an adverb as the name of the
project.

## Wait, why yet another parsing library?

An excellent error reporting infrastructure paired with good support for parsing
was a goal from day one. One of the most time consuming parts of small projects
is parsing common file formats and, most of all, parsing them **correctly** and
with **good error messages**. 

How many times did we start a research tool just to get the the classic
`expected L_PAREN` message (usually generated by common tools such as `bison`)
in a file full of parenthesis? Instead, tools built on top of `::formally` will
feature compiler-grade precise and informative error messages with minimal
effort from the researcher.

The `smt` module itself has been a great stress test for the parsing
infrastructure of the `io` module. The SMT-LIBv2 language looks simple from a
user's point of view, but its grammar is quite extensive and a good test case
for any parsing tool. The **parser combinators** approach, in constrast to
parser generators tools such as `bison`, allows one to write parsers with
succinct, high-level code directly in the host language (Rust in this case),
with a number of advantages including fast development, informative error
messages, and the possibility of reusing pieces of parsers between different
languages (e.g., the syntax for terms in SMT-LIBv2 and MoXI is the same).

Parsing is not the only annoying task required to support common languages.
Languages such as SMT-LIBv2, MoXI and SMV already require non-trivial type
checking, for example.

Building new tools on top of `::formally` will allow researchers to focus on
what is important in their research: new algorithms, new encodings, new ideas.

## So is it a clone of [PySMT] for Rust?

Not exactly. The `formally::smt` module can surely be used for the same
purpose, *i.e.*, accessing SMT solvers with a high-level and solver-agnostic
interface, and from Rust instead of Python. 

However, on the one hand, `formally::smt` implements not only the interface to
the solvers but the **SMT-LIBv2 language itself**. It provides a solid parser
for the full grammar and a (not yet) complete implementation of the full type
system of the language, as well as a complete abstract syntax tree that can be
used to **produce** well-formatted SMT-LIBv2 code easily. This means it will be
useful for more than just accessing a solver. Translation between languages,
desugaring, pre-processing, encodings, are on top of my mind, but an ambitious
use case may be even using `formally::smt` as a frontend for one's own SMT
solver, allowing one to focus on the reasoning algorithms leaving all the rest
to the framework.

On the other hand, `::formally` itself is planned to grow way beyond the `smt`
module. The latter will be integrated into a larger set of components supporting
many other languages and tasks: model checking is the next big step on my road
map, with the support at least of MoXI (which itself is a variation of
SMT-LIBv2) and SMV.

## So will it be a clone of [PyVMT] then?

In the same way, the use cases for the future model checking module will overlap
with PyVMT. But in the same way, the interaction of the module with others will
allow different use cases than the classic one of solving a model checking
problem through a backend.

## Why bother with testing and benchmarking?

Proper benchmarking of new solvers and techniques is a pain point for the
community. Each researcher has to setup their own infrastructure to compare
their single new idea or heuristic or algorithm with all the other
state-of-the-art tools. This is extremely time consuming and sometimes leads to
poor experimental designs leaking into published papers.

Reproducibility of experimental results is a cornerstone of science and we as a
community need better infrastructure to help researchers get it right with as
low friction as possible. 

A framework supporting multiple languages and use cases, multiple backend
solvers and the interoperability between them, is in the unique position of
providing an excellent benchmarking infrastructure for new research prototypes.

Testing, of course, goes with benchmarking, on the one hand because part of the
infrastructure can be shared, but on the other hand because most often
benchmarks need to account for the correctness of answers as well. Moreover, on
top of the infrastructure itself, the project may collect as well the benchmark
and test instances themselves as a centralised resource for the many different
supported use cases (from SAT solving to model checking), lowering the barrier
of entry for any new competitor.

# Why Rust?

Rust is on the rage nowadays so probably most people would find this question
surprising, but I think it deserves some answer. Usually, one means *"Why Rust
instead of X?"*, and depending on who asks the question, *X* may be some classic
systems language such as C++, or some high-level language such as Python.

Let me start from the former. C++ has been my first language of choice for a
long time. I have been writing C++ for literally twenty years now: I shipped my
first real-world C++ application in 2006 (used in production for 15 years at a
company I was working for at the time). [BLACK] itself is written in C++20, with
a strong focus on code quality and modern features, and it worked out well. So,
believe me when I say that **I like** C++.

However, for a **community** effort such as what `::formally` is supposed to
become (more on that later), C++ is clearly too hard to learn, and, especially,
to learn **well**. Despite what detractors say, I believe high-quality modern
C++ code can minimize the risk of serious bugs. However, such high-quality
standards need experience and the investment of an amount of effort that is
simply not sustainable for a little project in the academic world. 

Rust, on the other hand, if famous for ensuring its memory-safety guarantees,
which directly avoid a whole class of bugs that usually C++ developers have to
fight with. However, what I found really life-changing has suprisingly little to
do with the language's type system. What really made a difference is the
extremely high-quality **tooling infrastructure** that comes with the language:
IDE support, packaging, distribution, dependency management, testing,
documentation, and debugging are top-notch. All these features lower the barrier
for entry in the project for new contributors and will ease the development of
the project on the long run.

If community engagement is the key, then why not using a universally known
high-level language such as Python? Indeed, the idea of this project was
partially inspired also by the [unified planning framework] (UP), a project with
somewhat similar purposes focused on the **automated planning** community. The
UP is written in Python and the project is working out extraordinarily well.
Indeed, Python is surely a good **glue language** for providing high-level
interfaces to backend code of any kind, as its success in machine learning
proves.

However, as already remarked above, `::formally` is not only about accessing
backend solvers with some high-level interfaces, and when doing genuine work in
Python itself, the language is simply **too slow**. There is no better proof of
this than the projects by [Astral], a company developing open-source Python
tools written in Rust. Their [type checker], for example, is **two orders of
magnitude** faster than equivalent tools written in Python, just by virtue of
being written in a fast, optimized compiled language. What Rust enables here is
the development of **concurrent code** that is **fast**, **correct**, and
**high-level** at the same time, something that was difficult with C++ before.

## So what about my favourite language?

Still, people have their favourite languages and will write their tools in any
language they want. So if `::formally` was limited to being a Rust library, the
community adoption would be limited. Instead, a major goal of the project is to
be a **cross-language** framework, with other languages treated as first-class
citizens. 

This means the project will be soon equipped with high-quality **bindings** for
a selection of other languages. The first language on the list is surely Python,
indeed, but C++ is on the list as well, together with a plain C API for
universal interoperability and more languages to come in the future. How to
concretely develop these bindings is still an open question. Python bindings for
Rust code are luckily [easy to do], but the same is not true for C++,
unfortunately. Also, separately addressing each language in its own way would
probably be unoptimal. I'm working on a custom-made solution but it is still too
early to say whether it is going in the right direction.

# I think you mentioned this is a community effort?

Yes, it is!

While I have mostly worked alone on the project in the last six months, today's
release marks the start of what I would like to become a **community effort**.
The number of languages, backends, and tasks to support is so large that I will
not be able to meet the project's goals alone, not without loosing my mind in
the meanwhile. 

Instead, the optimal way going forward is to involve the community as much as
possible in the development of the project. The major goal will be to provide a
platform where everybody will be able to easily join and contribute their little
piece such as the parser for a new language, the backend code for their solver,
a new preprocessing step for some class of inputs, and so on.

The key to this goal in technical terms is twofold: **extensibility** and
**discoverability**. 

The framework has to be **extensible** from the outside. I'm designing a
**plugin system** that will allow new components (such as backends for new
solvers) to be written and loaded by `::formally` without touching the
framework's code itself. More importantly, writing plugins will need to be
possible with **any of the supported programming languages**.

Plugins written by different people around the world will need to be
**discovered** by who needs them. For this, the plan is to setup a lightweight
but secure infrastructure for the **distribution** of such plugins. Do you need
to parse a DIMACS file? Just go to `::formally`'s components repository, find if
somebody developed it already, and download it directly with the framework's
command-line tool.

On the **social side** of community involvement, I started the [GitHub
Discussions] page, and I will soon announce this very same blog post around,
start talking with possibly interested people, etc. I'm not a marketing guy, so
this will probably need some time.

But, for today, I'm still the only one in the room. So if you like this idea,
spread the word, send me an email, or post on the [GitHub Discussions] page, and
let's see if we can start collaborating... **formally!**

[BLACK]: https://www.black-sat.org
[Luca Geatti]: https://users.dimi.uniud.it/~luca.geatti/
[SPIN]: https://spin-web.github.io/SPIN2025/
[Rust library]: https://crates.io/crates/formally
[Z3]: https://github.com/Z3Prover/z3
[README]: https://crates.io/crates/formally
[PySMT]: https://github.com/pysmt/pysmt
[PyVMT]: https://github.com/pyvmt/pyvmt
[unified planning framework]: https://github.com/aiplan4eu/unified-planning
[Astral]: https://astral.sh
[type checker]: https://docs.astral.sh/ty/
[easy to do]: https://pyo3.rs/v0.27.2/
[GitHub Discussions]: https://github.com/formally-fm/formally/discussions