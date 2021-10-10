require 'trait'

def trait(traitName, &definitions)
  Object.const_set(traitName, TraitParser.new(&definitions).parse)
end

class Class
  alias :new_viejo :new
  attr_reader :trait

  def self.new(*args, &bloque)
    # TODO puede que no necesite explotar aca, sino que la evaluacion de si los metodos los tiene o no se puede hacer cuando se instancie quizas
    instance = new_viejo(*args, &bloque)
    instance.trait&.validar_metodos(instance)
    instance
  end

  def uses(trait)
    trait.metodos.each do |metodo|
      define_method(metodo.original_name, metodo) unless instance_methods.any?{ |m| m.equal? metodo.original_name}
    end
    @trait = trait
  end
end

class TraitParser

  def initialize(&metodos_bloque)
    super()
    @methods = metodos_bloque
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

    Trait.new(obtener_metodos(modulo_temporal), nuevos_metodos_requeridos)
  end

  def obtener_metodos(clase_temporal)
    metodos_a_agregar = clase_temporal.instance_methods(false)
    metodos_a_agregar.map { |metodo| clase_temporal.instance_method(metodo) }
  end

  def self.with_body(&body)
    self.new(&body)
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