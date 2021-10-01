require 'trait'

def trait(traitName, &definitions)
  method_parser = MethodParser.new(&definitions)
  Object.const_set(traitName, Trait.new(method_parser.obtener_metodos))
end

class Class
  def uses(trait)
    raise "no tiene definido los metodos requeridos" unless trait.metodos_requeridos.all? {|metodo_req| self.instance_methods.include? metodo_req }
    trait.metodos.each { |metodo| define_method(metodo.original_name, metodo.to_proc) }
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