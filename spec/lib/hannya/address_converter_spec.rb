require 'spec_helper'
require 'hannya'

include Hannya

RSpec.describe "an address converter" do

  context "when it is set for uppercase" do

    it "converts a symbol to uppercase" do
      ac = DataAddressConverter.create(:upper)
      expect(ac.convert(:thud)).to eq 'THUD'
    end

  end

  context "when it is set for pascal case" do

    it "converts a symbol to pascal case" do
      ac = DataAddressConverter.create(:pascal)
      expect(ac.convert(:horaki_hikari)).to eq 'HorakiHikari'
    end

  end

  context "when it is set for camel case" do

    it "converts a symbol to camel case" do
      ac = DataAddressConverter.create(:camel)
      expect(ac.convert(:horaki_hikari)).to eq 'horakiHikari'
    end

  end

  context "when it is passed an anonymous lambda/proc" do

    it "executes the proc" do
      la = ->(sym) {
        ary = sym.to_s.split('_')
        out = ''
        ary.each_slice(2) do |s|
          out << s[0].capitalize
          out << s[1].upcase if s[1]
        end
        out
      }
      ac = DataAddressConverter.create(la)
      expect(ac.convert(:augustus_gloop_veruca_salt)).to eq 'AugustusGLOOPVerucaSALT'
    end

  end

end
