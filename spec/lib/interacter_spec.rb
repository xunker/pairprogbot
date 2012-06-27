require 'spec_helper'

describe Interacter do
  before(:each) do
    @valid_username = 'xxx'

    @interacter = Interacter.new(@valid_username)
  end

  describe ".process_command" do
    it "should chop the command down the constituent parts and downcase/strip them" do
      @interacter.process_command('hello').should == ['hello',nil]
      @interacter.process_command('HEllo').should == ['hello',nil]
      @interacter.process_command(' hello ').should == ['hello',nil]

      @interacter.process_command('hello dolly').should == ['hello','dolly']
      @interacter.process_command('hello Dolly').should == ['hello','Dolly']
      @interacter.process_command('hello Dolly ').should == ['hello','Dolly']

      @interacter.process_command('hello dolly bear').should == ['hello','dolly bear']
    end
  end

end
