require 'minitest/autorun'

require_relative 'calculator.rb'

# Calculator tests
class CalculatorTest < Minitest::Test
  def test_single_operator_calculatioms
    assert_equal 4, Calculator.calculate('2 ** 2')
    assert_equal 4, Calculator.calculate('1 * 4')
    assert_equal 4, Calculator.calculate('8 / 2')
    assert_equal 4, Calculator.calculate('2 + 2')
    assert_equal 4, Calculator.calculate('6 - 2')
  end

  def test_multiple_operator_calculations
    assert_equal 16, Calculator.calculate('2 ** 2 ** 2')
    assert_equal 6, Calculator.calculate('2 + 2 + 2')
    assert_equal 6, Calculator.calculate('10 - 2 - 2')
    assert_equal 6, Calculator.calculate('1 * 3 * 2')
    assert_equal 6, Calculator.calculate('24 / 2 / 2')
  end

  def test_variable_precedence_operator_calculations
    assert_equal 8, Calculator.calculate('4 + 2 ** 2')
    assert_equal 8, Calculator.calculate('4 * 3 - 4')
    assert_equal 8, Calculator.calculate('18 - 2 - 2 ** 3')
    assert_equal 8, Calculator.calculate('2 ** 4 - 8')
    assert_equal 8, Calculator.calculate('24 / 2 - 4')
  end

  def test_bracket_calculations
    assert_equal 36, Calculator.calculate('(4 + 2) ** 2')
    assert_equal 4, Calculator.calculate('4 * (4 - 3)')
    assert_equal 24, Calculator.calculate('18 - (2 - 2 ** 3)')
    assert_equal 4, Calculator.calculate('2 ** (4 - 2)')
    assert_equal 12, Calculator.calculate('24 / (4 - 2)')
  end

  def test_negative_number_calculations
    assert_equal 0, Calculator.calculate('-2 - -2')
    assert_equal 2, Calculator.calculate('4 + -2')
    assert_equal(-4, Calculator.calculate('2 * -2'))
    assert_equal 6, Calculator.calculate('0 + (4 - -2)')
    assert_equal(-12, Calculator.calculate('-24 / (4 - 2)'))

    # note this next test seems to be a bug in Ruby related to .send
    #
    # irb(main):003:0> -2.send(:**, 2)
    # => 4
    # irb(main):004:0> -2 ** 2
    # => -4
    assert_equal 4, Calculator.calculate('-2 ** 2')
  end

  def test_float_calculations
    assert_equal 9.0, Calculator.calculate('4.5 * 2')
    # floats suck
    assert_equal 6.840000000000001, Calculator.calculate('2.2 * 2.2 + 2')
    assert_equal 33.0, Calculator.calculate('10 * 3.3')
    assert_equal 35.0, Calculator.calculate('5 * 3.5 * 2')
    assert_equal 1294.134198, Calculator.calculate('24.01 * 53.8998')
  end

  # (((BrACKeTs)))
  def test_unnecessary_brackets
    assert_equal 4, Calculator.calculate('((((((2)))))) * (((2)))')
  end

  def test_raises_not_closed_error
    Calculator.calculate('2 + (2 * 2')
    assert false
  rescue Calculator::ParenNotClosedError
    assert true
  end

  def test_raises_not_opened_error
    Calculator.calculate('2 + 2) * 2')
    assert false
  rescue Calculator::ParenNotOpenedError
    assert true
  end

  def test_raises_parse_error
    Calculator.calculate('take one cup of flour')
    assert false
  rescue Calculator::ParseError
    assert true
  end

  def test_getting_silly
    assert_equal(
      40.120666666666665,
      Calculator.calculate('43 - (1.234 * (4 + 3) / 3)')
    )
  end

  def test_no_spaces
    assert_equal(
      Calculator.calculate('43 - (1.234 * (4 + 3) / 3)'),
      Calculator.calculate('43-(1.234*(4+3)/3)')
    )
  end

  def test_extra_spaces
    assert_equal(
      Calculator.calculate('43 - (1.234 * (4 + 3) / 3)'),
      Calculator.calculate('43-    ( 1.234   *  (4    +3) /     3     )  ')
    )
  end
end
