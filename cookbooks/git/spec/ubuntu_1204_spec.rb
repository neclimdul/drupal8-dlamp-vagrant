require 'spec_helper'

describe 'Ubuntu 12.04 client install' do
  let(:chef_run) do
    runner = ChefSpec::Runner.new(platform: 'ubuntu', version: '12.04')
    runner.converge 'git::default'
  end

  it 'installs the correct packages' do
    expect(chef_run).to install_package('git')
  end

end
