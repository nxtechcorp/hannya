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
RSpec.describe "a data accessor object" do

  context "when the source data is a hash" do

    subject(:acc) do
      DataAccessor.new({ 'THUD' => 'PLUGH',
                         'XYZZY' => 'PLOVER',
                         'QUUX' => 'BAZ' })
    end

    it 'allows access to data by symbol' do
      expect(acc[:thud]).to eq 'PLUGH'
    end

    it 'allows access to data by string' do
      expect(acc['XYZZY']).to eq 'PLOVER'
    end

    it 'returns a list of values when given a list' do
      expect(acc[:quux, :thud, :xyzzy]).to eq %w(BAZ PLUGH PLOVER)
    end

  end

  context "when the source data is XML" do
    subject(:acc) do
      xml = Nokogiri::XML(xmlstring)
      XMLDataAccessor.new(xml.at_xpath('Root/Policy'))
    end

    it 'allows access to data by symbol' do
      expect(acc[:policy_number]).to eq '123456'
    end

    it 'allows access to data by xpath' do
      expect(acc['Address[1]/Street']).to eq '123 Mockingbird Ln.'
    end

    it 'returns a list of values when given a list' do
      expect(acc[:policy_number, :transaction_type, :insured_name]).to eq \
        ['123456', 'XLC', 'Joe Smith']
    end

  end

end


RSpec.describe "a data finder object" do

  context "when the source is a hash" do

    subject(:fnd) do
      DataFinder.new(nested_data)
    end

    context 'when the result is a string' do

      context 'and force_array is set' do
        it 'returns an empty array' do
          expect(fnd.get(:grault, force_array: true)).to eq []
        end
      end

      context 'and force_array is not set' do
        it 'returns nil' do
          expect(fnd.get(:grault)).to be_nil
        end
      end

    end

    context 'when the result is a data structure' do
      it 'returns the result' do
        expect(fnd.get(:bletch)).to eq nested_data['BLETCH']
      end
    end

    context 'when the input is a list' do

      context 'and one or more items in the list are strings' do
        it 'excludes those items from the result' do
          expect(fnd.get([:thud, :xyzzy])).not_to include('PLUGH')
        end
      end

      context 'and all the items are data structures' do
        it 'returns the items' do
          expect(fnd.get([:bletch, :xyzzy])).to eq [ nested_data['BLETCH'],
                                                     nested_data['XYZZY'] ]
        end
      end

      context 'and all the items are strings' do
        it 'returns an empty list' do
          expect(fnd.get([:thud, :grault, :quux])).to be_empty
        end
      end

    end

  end

  context "when the source is XML" do
    subject(:fnd) do
      xml = Nokogiri::XML(xmlstring)
      XMLDataFinder.new(xml.at_xpath('Root/Policy'))
    end

    context "when the result is a single node" do

      context "and force_array is not set" do

        it "returns a data accessor" do
          expect(fnd.get(:policy_number)).to be_an_instance_of(XMLDataAccessor)
        end

      end

      context "and force_array is set" do

        it "returns an array" do
          expect(fnd.get(:policy_number, force_array: true)).to be_an_instance_of(Array)
        end

      end

    end

    context "when the result is a nodeset" do

      it "returns a data accessor" do
        expect(fnd.get('Address[1]')).to be_an_instance_of(XMLDataAccessor)
      end


    end

    context "when the input is an array" do

      it "returns an array of data accessors" do
        expect(fnd.get([:insured_name, :transaction_type])).to be_an_instance_of(Array)
      end

    end

  end

end
