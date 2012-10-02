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

      it "parses mbus frame to xml" do
        xml = @frame.to_xml
        doc = REXML::Document.new(xml)
        doc.elements["MBusData/SlaveInformation/Id"].text.should == "828331"
        result = []
        doc.elements.each("MBusData/DataRecord") {|e| result << e}
        result.should have(12).elements
      end

      it "has a secondary id" do
        @frame.serial.should == "008283312D2C0104"
      end

      describe "mapping data fields" do
        before :each do
          @data = @frame.map_data_fields do |h|
            h
          end
        end

        it "finds 12 data fields" do
          @data.should have(12).elements
        end

        it "finds first data field" do
          @data[0][:quantity].should == "Energy"
          @data[0][:function].should == "Instantaneous value"
          @data[0][:unit].should == "J"
          @data[0][:value].should == 355780000000
        end

        it "finds second data field" do
          @data[1][:quantity].should == "Volume"
          @data[1][:function].should == "Instantaneous value"
          @data[1][:unit].should == "m^3"
          @data[1][:value].should == 3740.92
        end
      end
    end

    describe "package with extra data after first telegram" do
      before :each do
        str =  "\x68\x43\x43\x68\x08\x00\x72\x70\x84\x46\x00\x42\x04\x06\x02\x35"
        str << "\x00\x00\x00\x0e\x04\x10\x73\x11\x04\x00\x00\x0d\xfd\x0e\x08\x31"
        str << "\x30\x31\x2d\x35\x32\x33\x44\x07\xfd\x17\x40\x00\x00\x00\x00\x00"
        str << "\x00\x00\x01\xff\x18\x01\x0a\xff\x68\x00\x02\x0a\xff\x69\x01\x00"
        str << "\x1f\x00\x00\x00\x00\x00\x00\x17\x16\x68\x74\x74\x68\x08\x00\x72"
        str << "\x70\x84\x46\x00\x42\x04\x06\x02\x36\x00\x00\x00\x04\x29\x73\x23"
        str << "\x00\x00\x04\xa9\xff\x01\xdb\x0b\x00\x00\x04\xa9\xff\x02\x64\x0f"
        str << "\x00\x00\x04\xa9\xff\x03\x33\x08\x00\x00\x04\xfd\xc8\xff\x01\xa4"
        str << "\x08\x00\x00\x04\xfd\xc8\xff\x02\xaa\x08\x00\x00\x04\xfd\xc8\xff"
        str << "\x03\xa5\x08\x00\x00\x04\xfd\xda\xff\x01\x0f\x00\x00\x00\x04\xfd"
        str << "\xda\xff\x02\x12\x00\x00\x00\x04\xfd\xda\xff\x03\x0b\x00\x00\x00"
        str << "\x0a\xff\x59\x99\x49\x1f\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00"
        str << "\x00\x25\x16\x68\x16\x16\x68\x08\x00\x72\x70\x84\x46\x00\x42\x04"
        str << "\x06\x02\x37\x00\x00\x00\x02\xff\x60\x8d\x03\x0f\x00\x39\x16"
        @frame = Frame.parse(str)
      end

      it "parses mbus frame to xml" do
        xml = @frame.to_xml
        doc = REXML::Document.new(xml)
        doc.elements["MBusData/SlaveInformation/Id"].text.should == "468470"
        result = []
        doc.elements.each("MBusData/DataRecord") {|e| result << e}
        result.should have(7).elements
      end

      it "has a secondary id" do
        @frame.serial.should == "0046847042040602"
      end

      describe "mapping data fields" do
        before :each do
          @data = @frame.map_data_fields do |h|
            h
          end
        end

        it "finds 12 data fields" do
          @data.should have(7).elements
        end

        it "finds first data field" do
          @data[0][:quantity].should == "Energy"
          @data[0][:function].should == "Instantaneous value"
          @data[0][:unit].should == "Wh"
          @data[0][:value].should == 41173100
        end
      end
    end

    describe "with invalid mbus frame" do
      it "returns no frame" do
        frame = Frame.parse("dummy1")
        frame.should be_nil
      end
    end
  end
end
