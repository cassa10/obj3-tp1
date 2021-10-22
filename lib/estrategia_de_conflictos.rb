#TODO: Refactorizar metodos
class EstrategiaDeConflictos
  def initialize(metodos = [])
    super()
    @nombre_metodos = [*metodos]
  end

  def es_para?(metodo)
    @nombre_metodos.empty? || @nombre_metodos.include?(metodo)
  end

  def manejar_conflicto(metodos)
    raise 'this method should be overriden'
  end

end

class CualquierImplementacion < EstrategiaDeConflictos
  def manejar_conflicto(metodos)
    metodos_resueltos = []
    @nombre_metodos.each do |nombre_metodo|
      metodos_repetidos = metodos.filter { |metodo| metodo.mismo_simbolo? nombre_metodo }
      metodos_resueltos << metodos_repetidos.first
    end
    metodos_resueltos
  end
end

class ImplementacionDeTodos < EstrategiaDeConflictos

  def manejar_conflicto(metodos)
    metodos_resueltos = []
    @nombre_metodos.each do |nombre_metodo|
      metodos_repetidos = metodos.filter { |metodo| metodo.mismo_simbolo? nombre_metodo }
      metodos_resueltos << combinar(nombre_metodo, metodos_repetidos)
    end
    metodos_resueltos
  end

  def combinar(nombre_metodo, metodos)
    modulo_temporal = Module.new
    modulo_temporal.define_method(nombre_metodo) do |*args|
      metodos.each { |m| m.metodo.bind(self).call(*args) }
    end
    metodo_nuevo = modulo_temporal.instance_method(nombre_metodo)
    TraitMethod.new(metodo_nuevo, "")
  end

end

class InjectReduce < EstrategiaDeConflictos

  def initialize(metodos = [], valor_inicial, funcion_combinadora)
    super(metodos)
    @valor_inicial = valor_inicial
    @funcion_combinadora = funcion_combinadora
  end

  def manejar_conflicto(metodos)
    metodos_resueltos = []
    @nombre_metodos.each do |nombre_metodo|
      metodos_repetidos = metodos.filter { |metodo| metodo.mismo_simbolo? nombre_metodo }
      metodos_resueltos << combinar(nombre_metodo, metodos_repetidos, @valor_inicial, @funcion_combinadora)
    end
    metodos_resueltos
  end

  def combinar(nombre_metodo, metodos, acum, func_comb)
    modulo_temporal = Module.new
    modulo_temporal.define_method(nombre_metodo) do |*args|
      metodos.inject(acum) { |acum, m| func_comb.call(acum, m.metodo.bind(self).call(*args)) }
    end
    metodo_nuevo = modulo_temporal.instance_method(nombre_metodo)
    TraitMethod.new(metodo_nuevo, "")
  end
end

class Personalizable < EstrategiaDeConflictos

  def initialize(metodos = [], bloque_combinador)
    super(metodos)
    @proc_resolver_conflicto = bloque_combinador
  end

  def manejar_conflicto(metodos)
    metodos_resueltos = []
    @nombre_metodos.each do |nombre_metodo|
      metodos_repetidos = metodos.filter { |metodo| metodo.mismo_simbolo? nombre_metodo }
      metodos_resueltos << combinar(nombre_metodo, metodos_repetidos, @proc_resolver_conflicto)
    end
    metodos_resueltos
  end

  def combinar(nombre_metodo, metodos, func_combinadora)
    modulo_temporal = Module.new
    modulo_temporal.define_method(nombre_metodo) do |*args|
      func_combinadora.call(metodos.map {|m| m.metodo.bind(self)}, *args)
    end
    metodo_nuevo = modulo_temporal.instance_method(nombre_metodo)
    TraitMethod.new(metodo_nuevo, "")
  end
end
