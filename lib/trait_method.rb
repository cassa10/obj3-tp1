class TraitMethod
  attr_reader :metodo, :nombre_del_trait

  def initialize(metodo, nombre_del_trait)
    super()
    @metodo = metodo
    @nombre_del_trait = nombre_del_trait
  end

  def mismo_nombre?(otro_metodo)
    nombre.eql? otro_metodo.nombre
  end

  def distinto_trait?(otro_metodo)
    !@nombre_del_trait.eql? otro_metodo.nombre_del_trait
  end

  def mismo_simbolo?(simbolo)
    nombre.eql? simbolo
  end

  def nombre
    @metodo.original_name
  end

  def clonar_metodo
    @metodo.clone
  end

  def duplicar_con_nombre(nombre)
    old_method = clonar_metodo
    modulo_temporal = Module.new

    modulo_temporal.define_method(nombre) do |*args|
      old_method.bind(self).call(*args)
    end
    metodo_duplicado = modulo_temporal.instance_method(nombre)
    TraitMethod.new(metodo_duplicado, @nombre_del_trait)
  end
end