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

end
