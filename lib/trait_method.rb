class TraitMethod
  attr_reader :metodo, :nombre_del_trait

  def initialize(metodo, nombre_del_trait)
    super()
    @metodo = metodo
    @nombre_del_trait = nombre_del_trait
  end

  def mismo_nombre?(otro_metodo)
    @metodo.original_name.eql? otro_metodo.metodo.original_name
  end

  def distinto_trait?(otro_metodo)
    !@nombre_del_trait.eql? otro_metodo.nombre_del_trait
  end

  def mismo_simbolo?(simbolo)
    @metodo.original_name.eql? simbolo
  end

  def duplicar_con_nombre(nombre)
    old_method = @metodo.clone
    modulo_temporal = Module.new

    modulo_temporal.define_method(nombre) do |*args|
      old_method.bind(self).call(*args)
    end
    metodo_duplicado = modulo_temporal.instance_method(nombre)
    TraitMethod.new(metodo_duplicado, @nombre_del_trait)
  end

  def combinar_con(otro)
    este_metodo = @metodo.clone
    otro_metodo = otro.metodo.clone
    modulo_temporal = Module.new

    modulo_temporal.define_method(@metodo.original_name) do |*args|
      este_metodo.bind(self).call(*args)
      otro_metodo.bind(self).call(*args)
    end
    metodo_nuevo = modulo_temporal.instance_method(@metodo.original_name)
    TraitMethod.new(metodo_nuevo, @nombre_del_trait)
  end
end