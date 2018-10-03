# @author Rhys Stansfield <rhys.stansfield@protonmail.com>

# Abstract token class for representing all token varieties
class Token
  def initialize(char)
    self.chars = [].push(char)
  end

  def accepts?(_char)
    false
  end

  def value
    chars.join
  end

  def <<(char)
    chars << char
  end

  private

  attr_accessor :chars
end

# Numeric token class for holding numeric values
class NumericToken < Token
  def value
    val = Float(super.chomp('.'))
    (val % 1.0).zero? ? val.to_i : val
  end

  def accepts?(char)
    char =~ /\d|\./
  end
end

# Operator abstract class for defining operation tokens
class Operator < Token
  InvalidOperandError = Class.new(StandardError)

  attr_accessor :left, :right

  def precedence
    case operation
    when '+', '-' then 0
    when '*', '/' then 1
    when /\*{2}/ then 2
    end
  end

  def value
    @value ||= left.value.public_send(operation, right.value)
  end

  def operation
    @operation ||= chars.join
  end
end

OpenParen = Class.new(Operator)
CloseParen = Class.new(Operator)

Plus = Class.new(Operator)
Minus = Class.new(Operator)
Times = Class.new(Operator)
Divide = Class.new(Operator)
Order = Class.new(Operator) do
  def accepts?(char)
    char == '*'
  end
end

# Calculator that accepts a string, tokenizes it and performs the calculation
# it describes
class Calculator
  ParseError = Class.new(StandardError)
  ParenNotClosedError = Class.new(StandardError)
  ParenNotOpenedError = Class.new(StandardError)

  def self.calculate(input)
    reduce(tokenize(input.gsub(/\s|_|,/, '').split(''))).value
  end

  def self.reduce(element)
    return element unless element.is_a?(Array)

    until element.empty?
      operator = element.find do |el|
        el.is_a?(Operator) && el.right.nil?
      end

      return reduce(element.shift) if operator.nil?

      next_operator = element[element.index(operator) + 1..-1].find do |el|
        el.is_a?(Operator)
      end

      operator.left = reduce(element.delete_at(element.index(operator) - 1))

      if next_operator.nil? || (operator.precedence >= next_operator.precedence)
        operator.right = reduce(element.delete_at(element.index(operator) + 1))
      else
        operator.right = next_operator
      end
    end
  end

  def self.tokenize(input, level = 0)
    tree = []

    while (char = input.shift)
      element = \
        case char
        when /\d/ then NumericToken.new(char)
        when '+' then Plus.new(char)
        when '-'
          if tree.empty? || tree.last.is_a?(Operator)
            NumericToken.new(char) # handle negatives
          else
            Minus.new(char)
          end
        when '*'
          if input.first == '*'
            Order.new(char)
          else
            Times.new(char)
          end
        when '/' then Divide.new(char)
        when '('
          tokenize(input, level + 1)
        when ')' then
          if level.zero?
            raise ParenNotOpenedError, 'Unexpected parenthesis closure'
          end
          return tree
        when /\s/ then next
        else
          raise ParseError, "Invalid input: #{char}"
        end

      if element.is_a?(Token)
        element << input.shift while element.accepts?(input.first)
      end

      tree << element
    end

    if level > 0 && input.empty?
      raise ParenNotClosedError, 'Parenthesis not closed'
    end

    tree
  end
end
