# goven and process the interactions with external entiries like humans.
class Interactor
  attr_reader :username, :feature
  def initialize(username)
    @username = username
    @feature = Feature.find_last_feature_for_user(username)
  end
end