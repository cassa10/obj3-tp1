require 'trait'

def trait(trait_name, &definitions)
  Object.const_set(trait_name, TraitParser.new(trait_name, &definitions).parse)
end

class Class

  def uses(trait)
    trait.metodos.each do |metodo_de_trait|
      define_method(metodo_de_trait.metodo.original_name, metodo_de_trait.metodo) unless is_method_defined(metodo_de_trait.metodo.original_name)
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

class TraitParser

  def initialize(nombre_trait, &metodos_bloque)
    super()
    @methods = metodos_bloque
    @nombre_trait = nombre_trait
  end

  def parse
    modulo_temporal = Module.new
    nuevos_metodos_requeridos = []
    modulo_temporal.module_eval do
      define_singleton_method(:requires) do |*metodos_requeridos|
        nuevos_metodos_requeridos = metodos_requeridos
      end
    end
    modulo_temporal.module_eval &@methods

    Trait.new(@nombre_trait, obtener_metodos(modulo_temporal), nuevos_metodos_requeridos)
  end

  def obtener_metodos(clase_temporal)
    metodos_a_agregar = clase_temporal.instance_methods(false)
    metodos_a_agregar.map { |metodo| clase_temporal.instance_method(metodo) }
  end

  private

  def obtener_metodos_requeridos(clase_temporal)
    if clase_temporal.respond_to? :metodos_requeridos
      clase_temporal.metodos_requeridos
    else
      []
    end
  end

end