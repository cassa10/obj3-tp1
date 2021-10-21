require 'trait'
require 'trait_parser'

def trait(trait_name, &definitions)
  Object.const_set(trait_name, TraitParser.new(trait_name, &definitions).parse)
end

class Class

  def uses(trait, on_conflict: [])
    trait.metodos_sin_conflictos(on_conflict).each do |metodo_de_trait|
      define_method(metodo_de_trait.nombre, metodo_de_trait.metodo) unless is_method_defined(metodo_de_trait.nombre)
    end
    trait.metodos_requeridos.each do |simbolo|
      define_method(simbolo) { raise 'Metodo requerido no implementado' } unless is_method_defined(simbolo)
    end
  end

  private

  def is_method_defined(simbolo)
    instance_methods.any? { |m| m.equal? simbolo }
  end
end