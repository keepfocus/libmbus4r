require 'spec_helper'

require "rexml/document"

module LibMbus
  describe Frame do
    describe "package from abb meter" do
      before :each do
        str =  "\x68\x82\x82\x68\x08\x1f\x72\x31\x83\x82\x00\x2d\x2c\x01\x04"
        str << "\x02\x00\x00\x00\x0c\x0f\x78\x55\x03\x00\x0c\x14\x92\x40\x37"
        str << "\x00\x0c\x22\x81\x84\x10\x00\x0c\x59\x60\x20\x00\x00\x0c\x5d"
        str << "\x86\x20\x00\x00\x0c\x61\x00\x00\x00\x00\x0c\x2d\x00\x00\x00"
        str << "\x00\x0c\x3b\x00\x00\x00\x00\x4c\x0f\x78\x55\x03\x00\x4c\x14"
        str << "\x92\x40\x37\x00\x42\x6c\x61\x16\x0f\x31\x83\x82\x00\x00\x00"
        str << "\x00\x00\x00\x00\x00\x00\x01\x00\x24\x20\x00\x00\x00\x00\x00"
        str << "\x00\x30\x20\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
        str << "\x00\x00\x19\x21\x02\x00\x00\x00\x76\x03\x17\x07\x11\x00\xde"
        str << "\x16"
        @frame = Frame.parse(str)
      end

      it "Parses mbus frame to xml" do
        xml = @frame.to_xml
        doc = REXML::Document.new(xml)
        doc.elements["MBusData/SlaveInformation/Id"].text.should == "828331"
        result = []
        doc.elements.each("MBusData/DataRecord") {|e| result << e}
        result.should have(12).elements
      end

      it "has a secondary id" do
        @frame.serial.should == "8283312D2C0104"
      end

      it "runs block over each data field" do
        data = @frame.map_data_fields do |h|
          h
        end
        data.should have(12).elements
        data[0][:quantity].should == "Energy"
        data[0][:function].should == "Instantaneous value"
        data[0][:unit].should == "J"
        data[0][:value].should == 355780000000
        data[1][:quantity].should == "Volume"
        data[1][:function].should == "Instantaneous value"
        data[1][:unit].should == "m^3"
        data[1][:value].should == 3740.92
      end
    end
  end
end
