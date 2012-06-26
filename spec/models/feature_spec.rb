require 'spec_helper'

describe Feature do
  before(:each) do
    @valid_feature_params = {
      :username => 'foo',
      :name => 'bar'
    }

    @feature = Feature.new
  end

  # it "should be instantiated" do
  #   Feature.new.should be_an_instance_of(Feature)
  # end

  # it "should be saved successfully" do
  #   Feature.create(@valid_feature_params).should be_persisted
  # end

  it "should set the state of a new record to be the first state in the list of states" do
    feature = Feature.create!(@valid_feature_params)

    feature.state.should == Feature.initial_state
  end

  describe ".initial_state" do
    it "should return the first state in the list" do
      Feature.initial_state.should == 'new'
    end
  end

  describe ".finished_state" do
    it "should return the last state in the list" do
      Feature.finished_state.should == 'finished'
    end
  end

  describe ".find_last_feature_for_user" do
    context "user has one or more features in an unfinished state" do
      it "should return the first unfinished feature" do
        features = []
        3.times do |i|
          features << Feature.create!(:username => 'xxx', :name => "feature #{i}", :state => Feature.initial_state)
        end
        Feature.find_last_feature_for_user('xxx').id.should == features.last.id
      end
    end
    context "user has no features" do
      it "should return nil" do
        Feature.find_last_feature_for_user('xxx').should be_nil
      end
    end
    context "user has no features in unfinished state" do
      it "should return nil" do
        3.times do |i|
          f = Feature.create!(:username => 'xxx', :name => "feature #{i}", :state => Feature.finished_state)
          f.finish!
        end
        Feature.find_last_feature_for_user('xxx').should be_nil
      end
    end
  end

  describe '#finish!' do
    it 'should set the feature state to "finished"' do
      @feature.should_receive(:update_attributes).with({:state => Feature.finished_state})
      @feature.finish!
    end
  end

  describe "#question" do
    it "should return the question text for the right state" do
      Feature::VALID_STATES.each do |valid_state|
        feature = Feature.new
        feature.stub!(:state).and_return(valid_state)

        feature.question.should == Feature::QUESTIONS[valid_state]
      end
    end
  end

  describe "#negative_answer" do
    it "should return the negative answer text for the questing corresponding to the state" do
      Feature::VALID_STATES.each do |valid_state|
        feature = Feature.new
        feature.stub!(:state).and_return(valid_state)

        feature.negative_answer.should == Feature::NEGATIVE_ANSWER_TEXT[valid_state]
      end
    end
  end

  describe "#finished?" do
    context "state is 'finished'" do
      it "should be true" do
        @feature.stub!(:state).and_return(Feature::VALID_STATES.last)
        @feature.finished?.should be_true
      end
    end
    context "state is not 'finished'" do
      it "should be false" do
        @feature.stub!(:state).and_return(Feature::VALID_STATES.first)
        @feature.finished?.should be_false
      end
    end
  end

  describe "#completed?" do
    context "state is 'refactor'" do
      before(:each) do
        @feature.stub!(:state).and_return('refactor')
      end
      it "should be FALSE if the passed value indicates something like 'yes'" do
        @feature.completed?('yes').should be_false
      end
      it "should be TRUE if the passed value indicates something like 'no'" do
        @feature.completed?('no').should be_true
      end
    end
    context "state is not 'refactor'" do
      before(:each) do
        @feature.stub!(:state).and_return(Feature::VALID_STATES.first)
      end
      it "should be true if the passed value indicates something like 'yes'" do
        @feature.completed?('yes').should be_true
      end
      it "should be false if the passed value indicates something like 'no'" do
        @feature.completed?('no').should be_false
      end
    end
  end

  describe ".answer_text_to_boolean" do
    it "should convert things that look like 'yes' to true" do
      Feature.answer_text_to_boolean('y').should be_true
      Feature.answer_text_to_boolean('yes').should be_true

      Feature.answer_text_to_boolean('Y').should be_true
      Feature.answer_text_to_boolean('YES').should be_true

      Feature.answer_text_to_boolean('yea').should be_true
      Feature.answer_text_to_boolean('yes sir').should be_true
    end
    it "should convert things that look like 'no' to false" do
      Feature.answer_text_to_boolean('n').should be_false
      Feature.answer_text_to_boolean('no').should be_false

      Feature.answer_text_to_boolean('N').should be_false
      Feature.answer_text_to_boolean('NO').should be_false

      Feature.answer_text_to_boolean('nope').should be_false
    end
    it "should convert things that don't look like either to nil" do
      Feature.answer_text_to_boolean('poop').should be_nil
    end
  end

  describe '#test!' do
    it 'should set the current start to "test"' do
      @feature.should_receive(:update_attributes).with({:state => 'test'})
      @feature.test!
    end
  end

  describe '#refactor?' do
    before(:each) do
      @feature = Feature.new
    end
    it 'should be true if the state is "refactor"' do
      @feature.stub!(:state).and_return('refactor')
      @feature.refactor?.should be_true
    end
    it "should be false if the current state is not 'refactor'" do
      @feature.stub!(:state).and_return('test')
      @feature.refactor?.should be_false
    end
  end

  describe "#next!" do
    before(:each) do
      @feature = Feature.new
    end
    context "state is 'new'" do
      it "should change state to 'test'" do
        @feature.stub!(:state).and_return('new')

        @feature.should_receive(:update_attributes).with({:state => 'test'}).and_return(true)
        @feature.next!.should be_true
      end
    end
    context "state is 'test'" do
      it "should change state to 'refactor'" do
        @feature.stub!(:state).and_return('test')

        @feature.should_receive(:update_attributes).with({:state => 'refactor'}).and_return(true)
        @feature.next!.should be_true
      end
    end
    context "state is 'refactor'" do
      it "should change state to 'finished'" do
        @feature.stub!(:state).and_return('refactor')

        @feature.should_receive(:update_attributes).with({:state => 'finished'}).and_return(true)
        @feature.next!.should be_true
      end
    end
    context "state is 'finished'" do
      it "should not change the state" do
        @feature.stub!(:state).and_return('finished')

        @feature.should_not_receive(:update_attributes)
        @feature.next!.should be_false
        @feature.state.should == 'finished'
      end
    end
  end

end
