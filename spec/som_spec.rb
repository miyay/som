# coding: utf-8

require "spec_helper"
require "./som.rb"

describe "Som" do
  describe "#initialize" do
    subject do
      som = Som.new
      som.instance_variable_get("@weight")
    end
    it { subject.size.should == Som::UnitX }
    it { subject.first.size.should == Som::UnitY }
    it { subject.first.first.size.should == 21 }
    it { subject.first.first.first.should be_a_kind_of(Float)  }
  end

  describe "#read_file" do
    subject { Som.new }

    describe "@meta_data" do
      subject { super().instance_variable_get("@meta_data") }
      it { subject[:n].should == 21 }
      it { subject[:v].should == 17 }
      it { subject[:tags].should == ["dove", "cock", "duck", "w_duck", "owl", "hawk", "eagle", "crow", "fox", "dog", "wolf", "cat", "tiger", "lion", "horse", "zebra", "cattle"] }
    end

    describe "@data" do
      subject { super().instance_variable_get("@data") }
      it { subject.size.should == 17 }
      it { subject.first.size.should == 21 }
      it { subject.first.should == ["1.0", "0.0", "0.0", "0.0", "1.0", "0.0", "0.0", "0.0", "0.0", "1.0", "0.0", "0.0", "0.0", "1.0", "0.0", "0.0", "1.0", "0.0", "0.0", "0.0", "0.0"] }
    end
  end
end
