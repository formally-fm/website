---
title: First version released... formally!
date: 2025-12-19
author: Nicola Gigante
authorweb: https://www.inf.unibz.it/~gigante/
---

It is with extreme pleasure that I write this first post to announce the **first
preview release** of `::formally`, a project I devoted a lot of effort to in the
last **six months**.

# What is ::formally?

`::formally` is a project that aims to build a comprehensive open-source
framework and toolchain to help the development of formal methods applications.

I decided to start developing this project out of the experience I gained
developing [BLACK], a **satisfiability checker** for linear temporal logic and
similar formalisms. BLACK is written in C++23, is cross-platform, easy to
install thanks to packages for the major operating systems, and extensively
tested.

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

The goal of `::formally` is to greatly lower the effort for developing formal
methods tools, by providing a comprehensive framework and toolchain that let
researchers **focus on implementing their new idea** without wasting time on
everything else, while at the same time getting a high quality result.

This goal will be achieved by the development of libraries and tools providing
many independent but interacting components that offer to the researcher many
useful services:
1. parsing and production of common text file formats.
2. high-level interfaces for interacting with existing industry-standard tools

[BLACK]: https://www.black-sat.org
[Luca Geatti]: https://users.dimi.uniud.it/~luca.geatti/