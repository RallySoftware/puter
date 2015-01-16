# require_relative '../../lib/puter/providers/vm'

# # note - we're assuming a .vmonkey for now that really goes to vsphere, need to think about mocking

# describe Puter::Provider::Vm do
#   let(:vm) { Puter::Provider::Vm.new }
#   let(:templates_path) { '/Templates'}

#   describe '#images' do
#     #vm.stub!(:vmonkey).and_return(MockVMonkey.new) hard to mock...
#     it 'should return a list of images' do
#       expect(vm.images(templates_path).length).to be > 0
#     end
#   end

# end