require 'rspec'
require 'trait'
require 'trait_api'

describe 'Trait' do

  it 'cuando una clase usa un trait, luego puede responder los metodos de ese trait' do
    un_trait = TraitBuilder.with_definition do
      def un_metodo_del_trait
        10
      end
    end

    una_clase = Class.new do
      uses un_trait
    end

    una_instancia_de_la_clase = una_clase.new
    expect(una_instancia_de_la_clase.respond_to?(:un_metodo_del_trait)).to be_truthy
    expect(una_instancia_de_la_clase.un_metodo_del_trait).to eq 10
  end

  it 'cuando una clase usa un trait, luego puede responder los mensajes que ya definia esta clase' do

    un_trait = TraitBuilder.with_definition do
      def un_metodo_del_trait
        10
      end
    end

    una_clase = Class.new do
      uses un_trait

      def un_metodo_de_la_clase
        15
      end
    end

    una_instancia_de_la_clase = una_clase.new
    expect(una_instancia_de_la_clase.respond_to?(:un_metodo_de_la_clase)).to be_truthy
    expect(una_instancia_de_la_clase.un_metodo_de_la_clase).to eq 15
  end

  it 'cuando una clase usa un trait y este ultimo tiene algun metodo que la clase ya lo define de alguna forma, luego este sigue utilizando los metodos ya definidos y puede responder a los nuevos metodos' do
    trait = TraitBuilder.with_definition do
      def metodo_del_trait
        "from trait"
      end

      def algun_metodo
        "from trait"
      end

      def algun_metodo_2
        "from trait"
      end

      def algun_metodo_3
        "from trait"
      end
    end

    un_mixin = Module.new do
      def algun_metodo
        "from module"
      end
    end

    una_super_clase = Class.new do
      def algun_metodo_2
        "from superclass"
      end
    end

    una_clase = Class.new(una_super_clase) do
      include un_mixin
      uses trait

      def algun_metodo_3
        "from class"
      end
    end

    una_instancia_de_la_clase = una_clase.new
    expect(una_instancia_de_la_clase.metodo_del_trait).to eq "from trait"
    expect(una_instancia_de_la_clase.algun_metodo).to eq "from module"
    expect(una_instancia_de_la_clase.algun_metodo_2).to eq "from superclass"
    expect(una_instancia_de_la_clase.algun_metodo_3).to eq "from class"

  end

  it 'cuando una clase usa un trait que requiere un metodo, este lanza una excepcion si la clase no implementa algun metodo requerido' do
    trait = TraitBuilder.with_definition do
      requires :algun_metodo, :metodo_requerido

      def un_metodo_del_trait
        metodo_requerido << algun_metodo
      end
    end

    clase = Class.new do
      uses trait

      def algun_metodo
        "sarasa"
      end
    end

    expect { clase.new.un_metodo_del_trait }.to raise_error("Metodo requerido no implementado")

  end

  it 'cuando una clase usa un trait que requiere un metodo y esta clase define dicho metodo, puede instanciarse' do
    trait = TraitBuilder.with_definition do
      requires :algun_metodo

      def un_metodo_del_trait
        10
      end
    end

    una_clase = Class.new do
      uses trait

      def algun_metodo
        "sarasa"
      end
    end

    una_instancia_de_la_clase = una_clase.new
    expect(una_instancia_de_la_clase.respond_to?(:algun_metodo)).to be_truthy
  end

  it 'cuando una clase usa un trait que requiere un metodo y una superclase de esta clase define dicho metodo, puede instanciarse' do
    trait = TraitBuilder.with_definition do
      requires :algun_metodo

      def un_metodo_del_trait
        10
      end
    end

    una_superclase = Class.new do
      def algun_metodo
        "sarasa"
      end
    end

    una_clase = Class.new(una_superclase) do
      uses trait
    end

    una_instancia_de_la_clase = una_clase.new
    expect(una_instancia_de_la_clase.respond_to?(:algun_metodo)).to be_truthy
  end

  it 'cuando una clase usa un trait que requiere un metodo y esta clase usa un mixin que define dicho metodo, puede instanciarse' do
    trait = TraitBuilder.with_definition do
      requires :algun_metodo

      def un_metodo_del_trait
        10
      end
    end

    un_mixin = Module.new do
      def algun_metodo
        "sarasa"
      end
    end

    una_clase = Class.new do
      include un_mixin
      uses trait
    end

    una_instancia_de_la_clase = una_clase.new
    expect(una_instancia_de_la_clase.respond_to?(:algun_metodo)).to be_truthy
  end
end

class TraitBuilder
  def self.with_definition(&definition)
    TraitParser.new(:Trait, &definition).parse
  end

end