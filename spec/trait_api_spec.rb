require 'rspec'
require 'trait'
require 'trait_api'

describe 'Trait API' do

  it 'cuando una clase usa un trait con sus metodos, luego puede responder los metodos de ese trait' do
    trait :Trait1 do
      def metodo_del_trait1
        10
      end
    end

    trait :Trait2 do
      def metodo_del_trait2
        "sarasa"
      end
    end

    clase_1 = Class.new do
      uses Trait1
    end

    clase_2 = Class.new do
      uses Trait2
    end

    una_instancia_de_clase_1 = clase_1.new
    una_instancia_de_clase_2 = clase_2.new

    expect(una_instancia_de_clase_1.respond_to?(:metodo_del_trait1)).to be_truthy
    expect(una_instancia_de_clase_1.metodo_del_trait1).to eq 10

    expect(una_instancia_de_clase_2.respond_to?(:metodo_del_trait2)).to be_truthy
    expect(una_instancia_de_clase_2.metodo_del_trait2).to eq "sarasa"
  end

  it 'cuando una clase usa un trait que requiere ciertos metodos y esta clase no los implementa,
      se levanta una excepcion' do
    trait :UnTrait do
      requires :metodo_requerido_1, :metodo_requerido_2

      def metodo_del_trait
        10
      end
    end

    expect do
      Class.new do
        uses UnTrait
      end
    end.to raise_error

  end

  it 'x' do
    trait :UnTrait do
      requires 'un_metodo'

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
