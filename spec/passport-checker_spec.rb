# -*- encoding : utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe PassportChecker do

  describe "#valid?" do

    it "should return true for a valid id-number" do
      PassportChecker.valid?("T213224133AUT6904041M1810253<<<<<<<<<<<<<<<6").should be_true
    end

    it "should return false for am expired id-number" do
      PassportChecker.valid?("G0571952<9AUT5001068M1005075<<<<<<<<<<<<<<<2").should be_false
    end

    it "should return false if the profile-birthday and the idcard-birthday differ" do
      PassportChecker.valid?("G0571952<9AUT5001068M1005075<<<<<<<<<<<<<<<2", Date.civil(1950, 1, 7)).should be_false
    end

    it "should return true if the profile-birthday and the idcard-birthday are equal and the number is valid" do
      PassportChecker.valid?("T213224133AUT6904041M1810253<<<<<<<<<<<<<<<6", Date.civil(1969, 4, 4)).should be_true
    end

    it "should return false when the format is illegal" do
      PassportChecker.valid?("G057195<9AUT5001068M1005075<<<<<<<<<<<<<<<2", Date.civil(1979, 9, 12)).should be_false
    end

  end

  describe "#calculate_checksum" do

    before(:each) do
      @number = "T21322413"
    end

    it "should calculate the correct checksum" do
      PassportChecker.calculate_checksum(@number).should == 3
    end

  end

end
