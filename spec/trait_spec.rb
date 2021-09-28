require 'rspec'
require 'trait'
require 'trait_api'

describe 'trait tests' do

  it 'cuando una clase usa un trait, luego puede responder los metodos de ese trait' do
      clase_temporal = Class.new do
        def un_metodo_del_trait
          10
        end
      end

    un_trait = Trait.new(clase_temporal.methods)

    una_clase = Class.new do
      uses un_trait
    end

    una_instancia_de_una_clase = una_clase.new

    expect(una_instancia_de_una_clase.respond_to?(:un_metodo_del_trait)).to be_truthy
    expect(una_instancia_de_una_clase.un_metodo_del_trait).to eq 10
  end

  it 'sadadasf' do

  end

  it 'sarasa' do
    prueba = Prueba.new

    expect(Dummy.description).to eq "Dummy"
    expect((Dummy + Dummy2).description).to eq "Dummy + Dummy2"
    expect((Dummy - :sarasa + Dummy2).description).to eq "Dummy - [:sarasa] + Dummy2"
    expect((Dummy - [:sarasa, :sarasa2, :sarasa3] + Dummy2).description).to eq "Dummy - [:sarasa, :sarasa2, :sarasa3] + Dummy2"
    expect((Dummy - :sarasa + (Dummy2 + Dummy)).description).to eq "Dummy - [:sarasa] + Dummy2 + Dummy"

  end
end