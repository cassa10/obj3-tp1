require 'rspec'
require 'trait'
require 'trait_api'

describe 'Trait' do

  it 'cuando una clase usa un trait, luego puede responder los metodos de ese trait' do
    #TODO: Agregar otro trait para triangu
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

    un_trait = Trait.new(metodos)

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

  it 'cuando una clase usa un trait que requiere un metodo, este lanza una excepcion si la clase no implementa algun metodo requerido' do
    #TODO: Revisar con profes o opiniones de esto (ESTRATEGIA DE TESTING/TRIANGULACION)
    trait_1 = TraitBuilder.with_definition do
      requires :metodo_requerido

      def un_metodo_del_trait
        10
      end
    end).obtener_metodos

    metodos_requeridos_trait1 = [:metodo_requerido]
    #TODO: Revisar con profes o opiniones de esto (ESTRATEGIA DE TESTING/TRIANGULACION)
    metodos_requeridos_trait2 = [:algun_metodo, :metodo_requerido]

    trait_1 = Trait.new(metodos, metodos_requeridos_trait1)
    trait_2 = Trait.new(metodos, metodos_requeridos_trait2)

    expect do
      Class.new do
        uses trait_1
      end
    end.to raise_error("no tiene definido los metodos requeridos")

    expect do
      Class.new do
        uses trait_2

        def algun_metodo
          "sarasa"
        end
      end
    end.to raise_error("no tiene definido los metodos requeridos")

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