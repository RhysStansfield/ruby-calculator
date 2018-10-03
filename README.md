# Calculator Test

Build a simple command line calculator, it should be able to receive input as a string as input to the script being run and return the calculated value.

To start with we should aim to handle just two operands of positive ints only (don't worry about negative numbers for now) on either side of an operator (+, -, /, \*, \*\*..)

e.g.
```
$ calculator.rb "2 + 5" # => 7
$ calculator.rb "243 - 43" # => 200
$ calculator.rb "3 ** 5" # => 243
$ calculator.rb "243 / 3" # => 81
```

Next lets aim to handle multiple chained operations, with correct precedence handling (BODMAS).

Don't worry about handling brackets for now.

e.g.
```
$ calculator.rb "2 + 2 - 2" # => 2
$ calculator.rb "2 + 2 * 4" # => 10
$ calculator.rb "20 ** 4 / 8" # => 20000
```
