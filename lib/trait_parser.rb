class TraitParser

  def initialize(nombre_trait, &metodos_bloque)
    super()
    @methods = metodos_bloque
    @nombre_trait = nombre_trait
  end

  def parse
    inside_trait = nil
    modulo_temporal = Module.new
    nuevos_metodos_requeridos = []
    modulo_temporal.module_eval do
      define_singleton_method(:requires) do |*metodos_requeridos|
        nuevos_metodos_requeridos = metodos_requeridos
      end
      define_singleton_method(:uses) do |trait|
        inside_trait = trait
      end
    end
    modulo_temporal.module_eval &@methods
    agregar_trait_interno(Trait.new(@nombre_trait, obtener_metodos(modulo_temporal), nuevos_metodos_requeridos), inside_trait)
  end

  def obtener_metodos(clase_temporal)
    metodos_a_agregar = clase_temporal.instance_methods(false)
    metodos_a_agregar.map { |metodo| clase_temporal.instance_method(metodo) }
  end

  private

  def agregar_trait_interno(trait, inside_trait)
    if inside_trait.nil?
      trait
    else
      trait.+(inside_trait)
    end
  end

end

def uses(trait)
  trait
end
