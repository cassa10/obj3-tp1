require 'trait'

def trait(traitName, &definitions)
  Object.const_set(traitName, Trait.new(&definitions))
end

class Class
  def uses(trait)
    trait.metodos.each { |metodo| define_method(metodo.original_name, metodo.to_proc) }
  end
end