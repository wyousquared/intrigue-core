module Intrigue
module Entity
class PhysicalLocation < Intrigue::Model::Entity

  def self.metadata
    {
      :name => "PhysicalLocation",
      :description => "A Physical Location"
    }
  end

  def validate_entity
    name =~ /^\w.*$/ #&&
    #details["latitude"] =~ /^([-+]?\d{1,2}[.]\d+)$/ &&
    #details["longitude"] =~ /^([-+]?\d{1,3}[.]\d+)$/
  end

end
end
end
