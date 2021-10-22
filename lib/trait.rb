require 'operacion'

class Trait

  def description
    subclass_responsability
  end

  def metodos
    subclass_responsability
  end

  def metodos_requeridos
    subclass_responsability
  end

  def +(trait)
    subclass_responsability
  end

  def -(arg_methods)
    subclass_responsability
  end

  def <<(metodos_a_renombrar)
    subclass_responsability
  end

  def to_s
    description
  end

  private
  def subclass_responsability
    raise 'this method should be overriden in subclass'
  end
end
