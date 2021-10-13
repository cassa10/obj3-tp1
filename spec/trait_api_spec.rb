require 'rspec'
require 'trait'
require 'trait_api'

describe 'Trait API' do

  around do |test|
    constantes_ya_definidas = Object.constants

    test.run

    constantes_definidas_por_el_test = Object.constants - constantes_ya_definidas
    constantes_definidas_por_el_test.each do |nombre_constante|
      Object.send(:remove_const, nombre_constante)
    end
  end

  it 'cuando una clase usa un trait con sus metodos, luego puede responder los metodos de ese trait' do
    trait :UnTrait do
      def metodo_del_trait
        10
      end
    end

    class UnaClase
      uses UnTrait
    end

    una_instancia_de_clase = UnaClase.new

    expect(una_instancia_de_clase.respond_to?(:metodo_del_trait)).to be_truthy
    expect(una_instancia_de_clase.metodo_del_trait).to eq 10

  end

  it 'cuando una clase usa un trait que requiere ciertos metodos y esta clase no los implementa,
      pero estos metodos no se usan, no se levanta excepcion' do
    trait :UnTrait do
      requires :metodo_requerido

      def metodo_del_trait
        10
      end
    end

    class UnaClase
      uses UnTrait
    end

    expect do
      UnaClase.new.metodo_del_trait
    end.to_not raise_error

  end

  it 'cuando una clase implementa un trait con un metodo que utiliza self, luego self hace referencia a la instancia de la clase' do
    trait :UnTrait do

      def metodo_del_trait
        self
      end
    end

    class Cosa
      uses UnTrait
    end

    instancia = Cosa.new
    expect(instancia.metodo_del_trait).to eq instancia
  end

  it 'cuando una clase usa un trait que requiere un metodo, este lanza una excepcion si la clase no implementa algun metodo requerido' do
    trait :UnTrait do
      requires 'un_metodo'

      def metodo_del_trait
        un_metodo
      end
    end

    class Cosa
      uses UnTrait
    end

    expect { Cosa.new.metodo_del_trait }.to raise_error
  end

  it 'cuando una clase compone dos traits, luego sabe responder los metodos de ambos traits' do
    trait :UnTrait do
      def metodo_del_trait_1
        10
      end
    end

    trait :OtroTrait do
      def metodo_del_trait_2
        20
      end
    end

    class UnaClase
      uses UnTrait + OtroTrait
    end

    expect(UnaClase.new.metodo_del_trait_1).to eq(10)
    expect(UnaClase.new.metodo_del_trait_2).to eq(20)
  end

  it 'la composicion de traits es asociativa' do
    trait :UnTrait do
      def metodo_del_trait_1
        10
      end
    end

    trait :OtroTrait do
      def metodo_del_trait_2
        20
      end
    end

    trait :OtroTraitMas do
      def metodo_del_trait_3
        30
      end
    end

    class UnaClase
      uses UnTrait + (OtroTrait + OtroTraitMas)
    end

    class UnaClase2
      uses (UnTrait + OtroTrait) + OtroTraitMas
    end

    expect(UnaClase.new.metodo_del_trait_1).to eq(10)
    expect(UnaClase.new.metodo_del_trait_2).to eq(20)
    expect(UnaClase.new.metodo_del_trait_3).to eq(30)

    expect(UnaClase2.new.metodo_del_trait_1).to eq(10)
    expect(UnaClase2.new.metodo_del_trait_2).to eq(20)
    expect(UnaClase2.new.metodo_del_trait_3).to eq(30)
  end

  it 'cuando una clase compone dos traits con metodos requeridos y este no implementa alguno, entonces se lanza una excepcion al tratar de utilizarlo' do
    trait :UnTrait do
      requires :metodo_del_trait_2

      def metodo_del_trait_1
        metodo_del_trait_2
      end
    end

    trait :OtroTrait do
      requires :metodo_requerido

      def metodo_del_trait_2
        metodo_requerido
      end
    end

    class UnaClase
      uses UnTrait + OtroTrait
    end

    expect(UnaClase.new.respond_to?(:metodo_del_trait_1)).to be_truthy
    expect(UnaClase.new.respond_to?(:metodo_del_trait_2)).to be_truthy
    expect { UnaClase.new.metodo_del_trait_1 }.to raise_error 'Metodo requerido no implementado'
    expect { UnaClase.new.metodo_del_trait_2 }.to raise_error 'Metodo requerido no implementado'
  end

  it 'cuando una clase compone dos traits que implementan el mismo metodo, se levanta una excepcion' do
    trait :UnTrait do

      def un_metodo
        "Vengo de UnTrait"
      end
    end

    trait :OtroTrait do

      def un_metodo
        "Vengo de OtroTrait"
      end
    end

    expect do
      class UnaClase
        uses UnTrait + OtroTrait
      end
    end.to raise_error("Conflicto entre metodos de traits")
  end

  it 'cuando una clase compone dos veces el mismo trait, luego la clase hereda los mensajes correctamente' do
    trait :UnTrait do

      def un_metodo
        10
      end
    end

    class UnaClase
      uses UnTrait + UnTrait
    end

    expect(UnaClase.new.un_metodo).to eq(10)
  end

  it 'cuando una clase compone un trait excluyendo un metodo, luego la clase no sabe responder a este metodo' do
    trait :UnTrait do
      def un_metodo
        10
      end

      def otro_metodo
        50
      end
    end

    class UnaClase
      uses UnTrait - :otro_metodo
    end

    expect(UnaClase.new.respond_to?(:otro_metodo)).to be_falsey
  end

end
=begin
  comentado hasta que pasemos a operaciones
  it 'sarasa' do
    prueba = Prueba.new




    expect(Dummy.description).to eq "Dummy"
    expect((Dummy + Dummy2).description).to eq "Dummy + Dummy2"
    expect((Dummy - :sarasa + Dummy2).description).to eq "Dummy - [:sarasa] + Dummy2"
    expect((Dummy - [:sarasa, :sarasa2, :sarasa3] + Dummy2).description).to eq "Dummy - [:sarasa, :sarasa2, :sarasa3] + Dummy2"
    expect((Dummy - :sarasa + (Dummy2 + Dummy)).description).to eq "Dummy - [:sarasa] + Dummy2 + Dummy"

  end
=end
