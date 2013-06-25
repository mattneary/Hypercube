Hypercube
=========

Introduction
------------
Hypercube is a Rubik's cube simulator for Ruby. Face-turns are lambdas that modify a given `Cube` object via `Cube#faceTurn`. These lambdas can then be composed via the infix operator `*`.

A usual Hypercube program would instantiate a cube, manipulate it with face-turns, and output the cube. However, more complex workflows are easily implemented; you can output facelet permutations or a side-by-side grid of cube states.

Faceturns
---------
You will most likely begin with something like the following.

```ruby
cube = Cube.new()

U = lambda { |cube| cube.faceTurn :U }
D = lambda { |cube| cube.faceTurn :D }
L = lambda { |cube| cube.faceTurn :L }
R = lambda { |cube| cube.faceTurn :R }
F = lambda { |cube| cube.faceTurn :F }
B = lambda { |cube| cube.faceTurn :B }
```

After having defined these shorthands and instantiated a cube you can compose face-turns with the `*` operator and access their inverses via `Proc#inv`. The following performs a corner orientation algorithm and outputs the result.

```ruby
(R * U * R.inv * U * R * U * U * R.inv * U * U)[cube]
print cube.to_s
```

Cube Structure
--------------
A cube is represented as an array of faces, which in turn are arrays of up- and down-layer, which are in turn pairs of left- and right-facelet. These arrays are addressed with symbols `:U, :D, ... :B` as well as `:_L` and `:_R`. The latter are used exclusively for the third layer down, access of a specific facelet.

The default cube holds at each of the above articulated locations an array that serves as an address. For example:

```ruby
rubik = Cube.new
rubik[:U][:U][:_L] == [rubik.U, rubik.U, rubik._L]
```

Of course the reason for this equivalence is that we are dealing with a default cube. Upon manipulation the value at a facelet location will point to its origin and allow the facelet to be uniquely identitifed.

Analysis
--------
Hypercube aims to make analysis of Rubik's cube moves as straight-forward as possible. 

1. `Cube#delta(other)` - outputs the permutations separating one cube state from another.
2. `Cube#join_to_s(other, simple)` - forms a table of the cube with another beside it, output can be simplified to merely color rather than specific facelets.

Once the permutations of a move sequence have been identitifed, many conclusions may be reached; for example:

- The region of manipulation, i.e., the *support*.
- The period of the move sequence, i.e., the *order*.
- Intermediary states of an algorithm to give insight into the inner-workings of an algorithm.

Conclusion
----------
Hypercube is a work in progress. I hope to soon expand to a full 3x3x3 cube after I've made good progress in my research on group theory of the Rubik's cube. Its inspiration was to aid in derivation of algorithms.
