require_relative './solve'

EXAMPLE = <<-END
  199
  200
  208
  210
  200
  207
  240
  269
  260
  263
END

solve_with_numbers(EXAMPLE => 7) do |numbers|
  numbers.each_cons(2).count { |a, b| b > a }
end

solve_with_numbers(EXAMPLE => 5) do |numbers|
  numbers.each_cons(4).count { |a, _, _, b| b > a }
end
