# Calculator Hammer

Attempt to recreate Ruby maths parsing equivalent (Integer and Float only, currently no support for exponetials or other notations), written in pure stdlib Ruby.

Correctly handles arbitrary spacing, parenthesis, and precedence.

## Usage

```
$: ./calculator "43-1.234*((4+3))/(((3)))"
43-1.234*((4+3))/(((3))) = 40.120666666666665
```

You can also evaluate multiple expressions in one go:

```
$: ./calculator "2 + 2" "2 * 4" "3 * 5 + 8 ** 9"
2 + 2 = 4
2 * 4 = 8
3 * 5 + 8 ** 9 = 134217743
```

## Test

Tests written in `minitest`

Just run with plain ol' Ruby:

```
$: ruby ./calculator_test.rb
Run options: --seed 21534

# Running:

.............

Finished in 0.003837s, 3388.0636 runs/s, 9903.5705 assertions/s.
13 runs, 38 assertions, 0 failures, 0 errors, 0 skips
```
