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

## How does it work?

First the input is parsed character by character and a list of tokens is built.

E.g. given

```
2 * 3 ** 4 + ((4 + 6 / (1 + 1)) ** 3) - ((((2 + 2) * 3) - 4) ** 2)
```

We will end up with a parsed token list that will look something like:
```java
[#<NumericToken:0x007fa1688e3b48 @chars=["2"]>,
 #<Times:0x007fa1688e37d8 @chars=["*"]>,
 #<NumericToken:0x007fa1688e35f8 @chars=["3"]>,
 #<Order:0x007fa1688e33c8 @chars=["*", "*"]>,
 #<NumericToken:0x007fa1688e3238 @chars=["4"]>,
 #<Plus:0x007fa1688e3058 @chars=["+"]>,
 [[#<NumericToken:0x007fa1688e2d38 @chars=["4"]>,
   #<Plus:0x007fa1688e2ba8 @chars=["+"]>,
   #<NumericToken:0x007fa1688e2a18 @chars=["6"]>,
   #<Divide:0x007fa1688e2888 @chars=["/"]>,
   [#<NumericToken:0x007fa1688e25b8 @chars=["1"]>, #<Plus:0x007fa1688e2428 @chars=["+"]>, #<NumericToken:0x007fa1688e2298 @chars=["1"]>]],
  #<Order:0x007fa1688e2108 @chars=["*", "*"]>,
  #<NumericToken:0x007fa1688e1f78 @chars=["3"]>],
 #<Minus:0x007fa1688e1d48 @chars=["-"]>,
 [[[[#<NumericToken:0x007fa1688e16b8 @chars=["2"]>, #<Plus:0x007fa1688e13c0 @chars=["+"]>, #<NumericToken:0x007fa1688e10a0 @chars=["2"]>],
    #<Times:0x007fa1688e0dd0 @chars=["*"]>,
    #<NumericToken:0x007fa1688e0b00 @chars=["3"]>],
   #<Minus:0x007fa1688e0830 @chars=["-"]>,
   #<NumericToken:0x007fa1688e05d8 @chars=["4"]>],
  #<Order:0x007fa1688e02e0 @chars=["*", "*"]>,
  #<NumericToken:0x007fa1688e2798 @chars=["2"]>]]
```

Next we run an algorithm that scans and reduces the list of tokens into a single expression tree based on precedence, assigning values to `left` and `right` on each side of every operator.

Our final expression to be evaluated will look something like this:

```java
#<Minus:0x007f9bc90e2380
 @chars=["-"],
 @left=
  #<Plus:0x007f9bc90e3730
   @chars=["+"],
   @left=
    #<Times:0x007f9bc90e3e60
     @chars=["*"],
     @left=#<NumericToken:0x007f9bca014038 @chars=["2"]>,
     @operation="*",
     @right=
      #<Order:0x007f9bc90e3b40
       @chars=["*", "*"],
       @left=#<NumericToken:0x007f9bc90e3cd0 @chars=["3"]>,
       @operation="**",
       @right=#<NumericToken:0x007f9bc90e3960 @chars=["4"]>>>,
   @operation="+",
   @right=
    #<Order:0x007f9bc90e26a0
     @chars=["*", "*"],
     @left=
      #<Plus:0x007f9bc90e3190
       @chars=["+"],
       @left=#<NumericToken:0x007f9bc90e3320 @chars=["4"]>,
       @operation="+",
       @right=
        #<Divide:0x007f9bc90e2e20
         @chars=["/"],
         @left=#<NumericToken:0x007f9bc90e2fb0 @chars=["6"]>,
         @operation="/",
         @right=
          #<Plus:0x007f9bc90e29c0
           @chars=["+"],
           @left=#<NumericToken:0x007f9bc90e2b50 @chars=["1"]>,
           @operation="+",
           @right=#<NumericToken:0x007f9bc90e2830 @chars=["1"]>>>>,
     @operation="**",
     @right=#<NumericToken:0x007f9bc90e2510 @chars=["3"]>>>,
 @operation="-",
 @right=
  #<Order:0x007f9bc90e0cd8
   @chars=["*", "*"],
   @left=
    #<Minus:0x007f9bc90e1200
     @chars=["-"],
     @left=
      #<Times:0x007f9bc90e1908
       @chars=["*"],
       @left=
        #<Plus:0x007f9bc90e1cf0
         @chars=["+"],
         @left=#<NumericToken:0x007f9bc90e1f20 @chars=["2"]>,
         @operation="+",
         @right=#<NumericToken:0x007f9bc90e1b60 @chars=["2"]>>,
       @operation="*",
       @right=#<NumericToken:0x007f9bc90e1598 @chars=["3"]>>,
     @operation="-",
     @right=#<NumericToken:0x007f9bc90e0f30 @chars=["4"]>>,
   @operation="**",
   @right=#<NumericToken:0x007f9bc90e0a08 @chars=["2"]>>>
```

We then simply ask the top operation to determine it's value and it will descend the trees to the bottom, bubble their values up to the top transforming them with each new operation as it goes and perform the final top level calculation on the result of each side.

## TODO

* Add support for exponential and other notations
* Other common calculator functions (sine/cosine/etc)
* Refactoring
