class Redis
  module Emulator
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
