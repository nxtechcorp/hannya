require 'spec_helper'
require 'hannya'
require 'nokogiri'

include Hannya

xmlstring = <<-EOT
<Root>
  <Policy>
    <PolicyNumber>123456</PolicyNumber>
    <InsuredName>Joe Smith</InsuredName>
    <Address>
      <AddressId>1</AddressId>
      <Street>123 Mockingbird Ln.</Street>
      <City>Sacramento</City>
      <State>CA</State>
      <Zip>59815</Zip>
    </Address>
    <Address>
      <AddressId>2</AddressId>
      <Street>123 Mockingbird Ln.</Street>
      <City>Sacramento</City>
      <State>CA</State>
      <Zip>59815</Zip>
    </Address>
    <TransactionType>XLC</TransactionType>
  </Policy>
</Root>
EOT

nested_data = { 'THUD' => 'PLUGH',
                'BLETCH' => { 'SNORK' => 'BORK',
                              'CORGE' => 'BAZ',
                              'QUX' => 'QUUX', },
                'XYZZY' => %w(GARPLY FRED WALDO FUBAR BAR),
                'GRAULT' => 'PLOVER',
                'QUUX' => 'BAZ' }
RSpec.describe 'a data accessor object' do

  context 'when the source data is a simple hash' do

    subject(:acc) do
      HashAccessor.new('THUD' => 'PLUGH',
                       'XYZZY' => 'PLOVER',
                       'QUUX' => 'BAZ')
    end

    it 'allows access to data as an instance method' do
      expect(acc.thud).to eq 'PLUGH'
    end

    it 'allows access to data by string' do
      expect(acc['XYZZY']).to eq 'PLOVER'
    end

    it 'returns a list of values when given a list' do
      expect(acc.list(:quux, :thud, :xyzzy)).to eq %w(BAZ PLUGH PLOVER)
    end

    context 'when a nonexistent value is specified' do

      context 'and force_array is not set' do
        it 'returns nil' do
          expect(acc.grault).to be_nil
        end
      end

      context 'and force_array is set' do
        acc_with_fa = HashAccessor.new({ 'THUD' => 'PLUGH',
                                         'XYZZY' => 'PLOVER',
                                         'QUUX' => 'BAZ' }, force_array: true)
        it 'returns an empty array' do
          expect(acc_with_fa.grault).to eq []
        end
      end
    end
  end

  context 'when the source data is a complex hash' do
    subject(:acc) { HashAccessor.new(nested_data) }

    context 'when the result is a data structure' do
      it 'returns the result' do
        expect(acc.bletch).to eq nested_data['BLETCH']
      end
    end

    context 'when the input is a list' do

      context 'and all the items are data structures' do
        it 'returns the items' do
          expect(acc.list(:bletch, :xyzzy)).to eq [nested_data['BLETCH'],
                                                   nested_data['XYZZY']]
        end
      end

      context 'and all the items are strings' do
        it 'returns a list of strings' do
          expect(acc.list(:thud, :grault, :quux)).to eq %w(PLUGH PLOVER BAZ)
        end
      end

    end

  end

  context 'when the source data is XML' do
    subject(:acc) do
      xml = Nokogiri::XML(xmlstring)
      XMLAccessor.new(xml.at_xpath('Root/Policy'))
    end

    it 'allows access to data using method calls' do
      expect(acc.policy_number).to eq '123456'
    end

    it 'allows access to data by xpath' do
      expect(acc['Address[1]/Street']).to eq '123 Mockingbird Ln.'
    end

    it 'returns a list of values when given a list' do
      expect(acc.list(:policy_number, :transaction_type, :insured_name)).to eq \
        ['123456', 'XLC', 'Joe Smith']
    end

    context 'when the result is a single node' do

      context 'and force_array is not set' do

        it 'returns the node text' do
          expect(acc.policy_number).to eq '123456'
        end

      end

      context 'and force_array is set' do
        subject(:acc) do
          xml = Nokogiri::XML(xmlstring)
          XMLAccessor.new(xml.at_xpath('Root/Policy'), force_array: true)
        end

        it 'returns an array' do
          expect(acc.policy_number).to eq %w(123456)
        end

      end

    end

    context 'when the result is a nodeset' do

      it 'returns a data accessor' do
        expect(acc['Address[1]']).to be_an_instance_of(XMLAccessor)
      end

    end

    context 'when the input is an array' do

      it 'returns an array of data accessors' do
        expect(acc.list(:insured_name, :transaction_type)).to be_an_instance_of(Array)
      end

    end
  end

end
