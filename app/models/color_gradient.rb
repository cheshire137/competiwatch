class ColorGradient
  def initialize(colors:, steps:)
    @colors = colors
    @steps = steps - 1
    @gradient_count = colors.size - 1
    @substeps = @steps / @gradient_count
    @remainder = @steps % @gradient_count
  end

  # Public: Returns an array of RGB value arrays.
  def rgb
    generate.collect do |color|
      color.collect(&:to_i)
    end
  end

  private

  def generate
    @gradient_count.times.inject([]) do |memo, index|
      steps = @substeps
      if @remainder > 0
        steps += 1
        @remainder -= 1
      end
      memo += gradient_for(@colors[index], @colors[index+1], steps)
      memo
    end.push(@colors.last)
  end

  def gradient_for(color1, color2, steps)
    # Calculate a single color-to-color gradient
    steps.times.inject([]) do |memo, index|
      ratio = index.to_f / steps
      r = color2[0] * ratio + color1[0] * (1 - ratio)
      g = color2[1] * ratio + color1[1] * (1 - ratio)
      b = color2[2] * ratio + color1[2] * (1 - ratio)
      memo.push [ r, g, b ]
      memo
    end
  end
end
