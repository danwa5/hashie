require 'spec_helper'

module Hashie
  module Extensions
    describe DeepFetch do
      subject { Class.new(Hash) { include Hashie::Extensions::DeepFetch } }
      let(:hash) do
        {
          library: {
            books: [
              { title: 'Call of the Wild' },
              { title: 'Moby Dick' }
            ],
            location: {
              address: '123 Library St.'
            }
          }
        }
      end
      let(:instance) { subject.new.update(hash) }

      describe '#deep_fetch' do
        it 'extracts a value from a nested hash' do
          instance.deep_fetch(:library, :location, :address).should eq('123 Library St.')
        end

        it 'extracts a value from a nested array' do
          instance.deep_fetch(:library, :books, 1, :title).should eq('Moby Dick')
        end

        context 'when one of the keys is not present' do
          context 'when a block is provided' do
            it 'returns the value of the block' do
              value = instance.deep_fetch(:library, :unknown_key, :location) { 'block value' }
              value.should eq('block value')
            end
          end

          context 'when a block is not provided' do
            context 'when the nested object is an array' do
              it 'raises an UndefinedPathError' do
                lambda do
                  instance.deep_fetch(:library, :books, 2)
                end.should(
                  raise_error(
                    DeepFetch::UndefinedPathError,
                    'Could not fetch path (library > books > 2) at 2'
                  )
                )
              end
            end

            context 'when the nested object is a hash' do
              it 'raises a UndefinedPathError' do
                lambda do
                  instance.deep_fetch(:library, :location, :unknown_key)
                end.should(
                  raise_error(
                    DeepFetch::UndefinedPathError,
                    'Could not fetch path (library > location > unknown_key) at unknown_key'
                  )
                )
              end
            end
          end
        end
      end
    end
  end
end