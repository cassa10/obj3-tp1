require 'trait'

def trait(traitName, &definitions)
  Object.const_set(traitName, Trait.new(definitions))
end

class Class
  def uses(trait)
    trait.methods.each { |method| self.define_method(method) }
  end
end