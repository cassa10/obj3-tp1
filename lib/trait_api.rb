require 'trait'

def trait(traitName, &definitions)
  method_parser = MethodParser.new(&definitions)
  Object.const_set(traitName, Trait.new(method_parser.obtener_metodos))
end

class Class
  alias :new_viejo :new
  attr_reader :trait

  def self.new(*args, &bloque)
    instance = new_viejo(*args, &bloque)
    instance.trait&.validar_metodos(instance)
    instance
  end

  def uses(trait)
    trait.metodos.each { |metodo| define_method(metodo.original_name, metodo.to_proc) }
    @trait = trait
  end
end

class MethodParser

  def initialize(&metodos_bloque)
    super()
    @methods = metodos_bloque
  end

  def obtener_metodos()
    clase_temporal = Class.new
    clase_temporal.class_eval &@methods

    instancia_de_clase = clase_temporal.new
    metodos_a_agregar = instancia_de_clase.methods - clase_temporal.superclass.methods
    metodos_a_agregar.map { |metodo| instancia_de_clase.method(metodo) }
  end
end