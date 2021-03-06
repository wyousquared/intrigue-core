module Intrigue
module Entity
class EmailAddress < Intrigue::Model::Entity

  def self.metadata
    {
      :name => "EmailAddress",
      :description => "An Email Address"
    }
  end

  def validate_entity
    name =~ /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,8}/
  end

  def detail_string
    "#{details["extracted_from"]}"
  end

end
end
end
