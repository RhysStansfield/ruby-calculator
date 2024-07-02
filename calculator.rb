# frozen_string_literal: true

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
  IGNORES = %w[_ ,].freeze

  def value
    val = Float(super.chomp('.'))
    (val % 1.0).zero? ? val.to_i : val
  end

  def <<(char)
    chars << char unless IGNORES.any? { |ignored| ignored == char }
  end

  def accepts?(char)
    char =~ /\d|\.|_|,/
  end
end

# Operator abstract class for defining operation tokens
class Operator < Token
  attr_accessor :left, :right

  def precedence
    case operation
    when '+', '-' then 0
    when '*', '/' then 1
    when '**' then 2
    end
  end

  def value
    @value ||= left.value.public_send(operation, right.value)
  end

  def operation
    @operation ||= chars.join
  end
end

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
    reduce(tokenize(input.split(''))).value
  end

  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Style/MethodLength
  def self.reduce(element)
    return element unless element.is_a?(Array)

    values = element.map { |el| reduce(el) }
    operators = element.select { |el| el.is_a?(Operator) }
                       .group_by(&:precedence)
                       .to_a
                       .sort_by(&:first)
                       .reverse
                       .flat_map(&:last)

    while (operator = operators.shift)
      next_operator = values[values.index(operator) + 1..-1].find do |el|
        el.is_a?(Operator)
      end

      left_index = values.index(operator) - 1
      if left_index < 0 && operator.is_a?(Minus)
         # handle case of opening '-' operator, e.g. -2*2
        operator.left = NumericToken.new("0")
      else
        operator.left = values.delete_at(left_index)
      end

      if next_operator.nil? || (operator.precedence >= next_operator.precedence)
        operator.right = values.delete_at(values.index(operator) + 1)
      else
        operator.right = next_operator
        if next_operator.left && next_operator.right
          values.delete(next_operator)
        end
      end
    end

    values.shift
  end

  def self.tokenize(input, level = 0)
    tree = []

    while (char = input.shift)
      element = \
        case char
        when /\d/ then NumericToken.new(char)
        when '+', '-', '*', '/' then create_operator_token(input, char, tree)
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

  def self.create_operator_token(input, char, tree)
    validate_permitted_operator!(char, tree)

    case char
    when '+' then Plus.new(char)
    when '-'
      if tree.last.is_a?(Operator)
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
    end
  end

  def self.validate_permitted_operator!(char, tree)
    if tree.empty? && char != '-'
      raise ParseError, "Unpermitted opening operator: #{char}"
    end
  end
end
