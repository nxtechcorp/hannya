require 'spec_helper'
require 'nokogiri'
require 'hannya'

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

RSpec.describe "the accessor factory" do

  context "when the data source is XML" do
    xml = Nokogiri::XML(xmlstring).at_xpath('Root/Policy')

    it "returns an XML accessor" do
      ac = Hannya::Accessor(xml, address_converter: :camel)
      expect(ac[:policy_number]).to eq '123456'
    end

  end

  context "when it is a hash" do

    it "returns a data accessor"

  end

end
