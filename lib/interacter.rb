# goven and process the interactions with external entiries like humans.
class Interacter
  attr_reader :username, :feature

  def initialize(username)
    @username = username
    @feature = Feature.find_last_feature_for_user(username)
  end

  def process_command(cmd)
    cmd.strip!
    (cmd, args) = if cmd =~ /\s/
      if m = cmd.match(/([a-z0-9]+)\s+(.+)/)
        [m[1].downcase, m[2]]
      else
        [cmd.downcase,nil]
      end
    else
      [cmd.downcase,nil]
    end
  end

  def normalize_command(cmd)
    case cmd
    when 'hello', 'help'
      'hello'
    when 'start', 'feature'
      'feature'
    when /^yes/, /^yea/, 'y'
      'yes'
    when 'no', 'nope', 'n'
      'no'
    else
      cmd
    end
  end

  def command(command_string)
    (cmd, args) = process_command(command_string)
    response = self.send("command_#{normalize_command(cmd)}".to_sym, args)
  end

  def command_hello(garbage)
    if @feature
      "Hello #{username}, we are working on #{@feature.name.blank? ? 'a feature' : @feature.name}."
    else
      str = "Hello, we're not working on a feature right now."
      if (features = Feature.find_all_by_username(username)).present?
        str << " We have worked on #{features.size} features in the past."
      end
      str
    end
  end

  def command_list(garbage)
    if (features = Feature.find_all_by_username(username)).present?
      str = "In the past we have worked on #{features.size} features."
      if features.size > 3
        str << " The last 3 were:"
      else
        str << " They are:"
      end
      fs=[]
      features[0..2].each do |f|
        fs << " #{f.name}(#{f.created_at.strftime("%b %d %Y")})"
      end
      str << fs.join(', ')
      str
    else
      "I have never worked on any features with you, #{@username}."
    end
  end

  def command_feature(name)
    if @feature.nil? || @feature.finished?
      @feature = Feature.find_or_create_by_username_and_name(:username => username, :name => name)
      "starting feature #{@feature.name}. #{@feature.question}"
    else
      "You are in the middle of #{@feature.name}! You can't start a new feature until you complete the old one!"
    end
  end

  def command_where(garbage)
    @feature.present? ? "We were at: #{@feature.question}" : "We're not working on anything yet."
  end

  def command_what(garbage)
    @feature.present? ? "We are working on #{@feature.name}" : "We're not working on anything yet."
  end

  def command_yes(garbage)
    answer('yes')
  end

  def command_no(garbage)
    answer('no')
  end

  def answer(answer)
    if @feature.completed?(answer)
      @feature.next!
      return @feature.question
    else
      str = @feature.negative_answer
      @feature.test! if @feature.refactor?
      return str
    end
  end

  def method_missing(m, *args, &block)
    if m.to_s =~ /^command_/
      "I don't know what you meant there."
    else
      super
    end
  end
end