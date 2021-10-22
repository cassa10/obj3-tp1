require 'trait'
class TraitSimple < Trait

  attr_reader :nombre, :metodos_requeridos

  def initialize(nombre, metodos, metodos_requeridos = [])
    super()
    @metodos = metodos
    @metodos_requeridos = metodos_requeridos
    @nombre = nombre
  end

  def description
    @nombre.to_s
  end

  def metodos
    @metodos.map { |metodo| TraitMethod.new(metodo, @nombre) }
  end

  def metodos_sin_conflictos(_)
    metodos
  end

  def +(trait)
    TraitCompuesto.new(self, trait, OperacionComposicion.new)
  end

  def -(arg_methods)
    methods = [*arg_methods]
    TraitCompuesto.new(self, methods, OperacionSubstraccion.new)
  end

  def <<(metodos_a_renombrar)
    TraitCompuesto.new(self, metodos_a_renombrar, OperacionRenombre.new)
  end

end
