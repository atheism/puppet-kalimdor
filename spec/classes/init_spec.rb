require 'spec_helper'
describe 'kalimdor' do

  context 'with defaults for all parameters' do
    it { should contain_class('kalimdor') }
  end
end
