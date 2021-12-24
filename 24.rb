require_relative './solve'

class Expr

  attr_reader :coeffs

  def initialize(coeffs)
    @coeffs = Array(coeffs)
    @coeffs << 0 until @coeffs.size == 15
  end

  def +(other)
    if other.zero?
      self
    elsif zero?
      other
    else
      Expr.new(coeffs.zip(other.coeffs).map { |a, b| a + b })
    end
  end

  def *(other)
    if zero? || other.zero?
      Expr.new(0)
    elsif other.one?
      self
    elsif one?
      other
    elsif numeric?
      Expr.new(other.coeffs.map { |a| a * coeffs[0] })
    elsif other.numeric?
      Expr.new(coeffs.map { |a| a * other.coeffs[0] })
    else
      raise "Non-polynomial multiply: #{self} * #{other}"
    end
  end

  def /(other)
    if other.one? || zero?
      self
    elsif numeric?
      Expr.new(other.coeffs.map { |a| a / coeffs[0] })
    elsif other.numeric?
      Expr.new(coeffs.map { |a| a / other.coeffs[0] })
    else
      raise "Non-polynomial divide: #{self} / #{other}"
    end
  end

  def %(other)
    if zero? || one?
      self
    elsif numeric?
      Expr.new(other.coeffs.map { |a| a % coeffs[0] })
    elsif other.numeric?
      Expr.new(coeffs.map { |a| a % other.coeffs[0] })
    else
      raise "Non-polynomial mod: #{self} % #{other}"
    end
  end

  def ==(other)
    if numeric? && other.numeric?
      coeffs[0] == other.coeffs[0]
    elsif monomial? && other.monomial?
      c1 = coeffs[1..].reject(&:zero?).first || 0
      c2 = other.coeffs[1..].reject(&:zero?).first || 0
      possibilities = Set.new
      1.upto(9).each do |d1|
        1.upto(9).map do |d2|
          possibilities << (c1 * d1 + coeffs[0] == c2 * d2 + other.coeffs[0])
          raise RelatedDigitError if possibilities.size > 1
        end
      end
      possibilities.first
    else
      raise "Unknown == case for #{coeffs.inspect} | #{other.coeffs.inspect}"
    end
  end

  def zero?
    numeric? && coeffs[0] == 0
  end

  def one?
    numeric? && coeffs[0] == 1
  end

  def numeric?
    coeffs[1..].all?(&:zero?)
  end

  def monomial?
    coeffs[1..].reject(&:zero?).size <= 1
  end

  def base
    raise "Not a monomial" unless monomial?
    coeffs[1..].index { |c| c == 1 }
  end

  def to_s
    return '0' if zero?
    coeffs.each_with_index.map do |c, i|
      c = c % 26
      next if c.zero?
      i == 0 ? c : "#{c unless c == 1}d#{i}"
    end.compact.reverse.join(' + ')
  end

end

class RelatedDigitError < StandardError; end

class MonadValidator

  OPS = {
    'add' => '+',
    'mul' => '*',
    'div' => '/',
    'mod' => '%',
    'eql' => '==',
  }

  attr_reader :w, :x, :y, :z
  attr_accessor :related_digits

  def initialize(lines)
    @w, @x, @y, @z = Array.new(4) { Expr.new(0) }
    @lines = lines
    @related_digits = {}
    find_related_digits
  end

  def find_related_digits(inputs = monomials)
    @related_digits = {}
    @lines.each do |line|
      case line
      when /^inp ([wxyz])$/
        a = inputs.shift or raise "Not enough inputs!"
        set($1, a)
      when /^(add|mul|div|mod|eql) ([wxyz]) ([wxyz]|-?\d+)$/
        a, b = get($2), get($3)
        c = begin
              a.send(OPS.fetch($1), b)
            rescue RelatedDigitError
              @related_digits[b.base] = [a.base, a.coeffs[0]]
              true
            end
        set($2, $1 == 'eql' ? Expr.new(c ? 1 : 0) : c)
      else
        raise "Unknown: #{line}"
      end
    end
    @z
  end

  def monomials
    1.upto(14).map do |i|
      a = Array.new(15) { 0 }
      a[i] = 1
      Expr.new(a)
    end
  end

  def get(field)
    case field
    when 'w', 'x', 'y', 'z'
      instance_variable_get("@#{field}")
    else
      Expr.new(field.to_i)
    end
  end

  def set(field, v)
    instance_variable_set("@#{field}", v)
  end

  def related_digits_inverted
    @related_digits_inverted = related_digits.map do |b1, (b2, c2)|
      [b2, [b1, -c2]]
    end.to_h
  end

  def valid_monads
    Enumerator.new { |e| _valid_monads(e) }
  end

  def _valid_monads(e, *path)
    if path.size == 14
      e << path.join.to_i
      return
    end

    base = path.size
    b2, c2 = related_digits_inverted[base]
    if b2 && c2
      (c2 < 0 ? 1 .. 9 + c2 : 1 + c2 .. 9).each do |d|
        _valid_monads(e, *path, d)
      end
    else
      b2, c2 = related_digits[base]
      raise "Can't find related digits for #{base}" unless b2 && c2
      _valid_monads(e, *path, path[b2] + c2)
    end
  end

end

solve_with(MonadValidator) do |validator|
  validator.valid_monads.max
end

solve_with(MonadValidator) do |validator|
  validator.valid_monads.min
end
