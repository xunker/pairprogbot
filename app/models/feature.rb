class Feature < ActiveRecord::Base
  VALID_STATES = %w[
    new test refector finished
  ]

  QUESTIONS = {
    'new' => 'Do you have a test for that?',
    'test' => 'Does the test pass?',
    'refactor' => 'Need to refactor?',
    'finished' => 'Feature complete. Select a new feature to implement.'
  }

  NEGATIVE_ANSWER_TEXT = {
    'new' => 'Write a test.',
    'test' => 'Write just enough code for the test to pass. Does the test pass?',
    'refactor' => 'Refactor the code. Does the test pass?'
  }
  TEST_PASS_APPEND = "Does the test pass?"

  attr_accessible :username, :name, :state

  before_create :set_initial_state

  validates_presence_of :username
  # validates_inclusion_of :state, :in => Feature::VALID_STATES

  def self.find_last_feature_for_user(username)
    Feature.find(
      :last,
      :conditions => ['username = ? AND state <> ?', username, Feature.finished_state]
    )
  end

  def self.initial_state
    VALID_STATES.first
  end

  def self.finished_state
    VALID_STATES.last
  end

  def question
    QUESTIONS[state]
  end

  def negative_answer
    NEGATIVE_ANSWER_TEXT[state]
  end

  def finished?
    state == VALID_STATES.last
  end

  def refactor?
    state == 'refactor'
  end

  def name
    if super.blank?
      'unnamed feature'
    else
      super
    end
  end

  def test!
    update_attributes(:state => 'test')
  end

  def finish!
    update_attributes(:state => 'finished')
  end


  def next!
    return false if finished?
    next_state = case state
    when 'new'
      'test'
    when 'test'
      'refactor'
    when 'refactor'
      'finished'
    end
    update_attributes(:state => next_state)
  end

  # since 'yes' is 'affirmatve' for all but the "refactor" state, check to see
  # if the answer passed by the user for each question indicates they can move
  # to the next state.
  def completed?(answer_text)
    if state == 'refactor'
      # note the reverse logic here
      if Feature.answer_text_to_boolean(answer_text) == true
        false
      else
        true
      end
    else
      Feature.answer_text_to_boolean(answer_text)
    end
  end

  def self.answer_text_to_boolean(answer_text)
    case answer_text.downcase
    when 'y', /^yes/, /^yea/
      true
    when 'n', /^no/
      false
    else
      nil
    end
  end

private

  def set_initial_state
    self.state = Feature.initial_state
  end
end
