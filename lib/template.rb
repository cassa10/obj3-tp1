class Trait
  attr_reader :cosas

  def initialize(cosas)
    super()
    @cosas = cosas
  end
end

class Class
  def uses(trait)
    class_eval(&trait.cosas)
  end
end

def trait(constante, &cosas)
  Object.const_set(constante, Trait.new(cosas))
end


