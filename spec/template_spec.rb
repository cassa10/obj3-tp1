require 'rspec'
require 'template'

trait :Dummy do
  def un_metodo_del_trait
    10
  end
end

trait :Dummy2 do
  def un_metodo_del_trait2
    20
  end
end

class Prueba
  uses Dummy - :sarasa + Dummy2 + Dummy

  def initialize
    super
    @hp = 0
  end


end

describe 'template tests' do

  it 'xd' do

    prueba = Prueba.new

    expect(prueba.respond_to?(:un_metodo_del_trait)).to be_truthy
    expect(prueba.un_metodo_del_trait).to eq 10
    expect(Dummy.description).to eq "Dummy"
    expect((Dummy + Dummy2).description).to eq "Dummy + Dummy2"
    expect((Dummy - :sarasa + Dummy2).description).to eq "Dummy - [:sarasa] + Dummy2"
    expect((Dummy - [:sarasa, :sarasa2, :sarasa3] + Dummy2).description).to eq "Dummy - [:sarasa, :sarasa2, :sarasa3] + Dummy2"
    expect((Dummy - :sarasa + (Dummy2 + Dummy)).description).to eq "Dummy - [:sarasa] + Dummy2 + Dummy"

  end
end