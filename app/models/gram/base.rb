module Gram
  class Base < ActiveRecord::Base
    self.abstract_class = true
    establish_connection GRAM_DB_CONF
  end
end