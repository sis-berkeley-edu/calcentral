class HubEdos::ClassesApi::V1::Section
  attr_accessor :attrs

  attr_accessor :id, :sectionAttributes, :instructionMode

  alias :section_attributes :sectionAttributes

  def initialize(attrs={})
    @attrs = attrs

    attrs.each do |key, value|
      self.send("#{key}=", value) if respond_to?("#{key}=")
    end
  end

  def as_json(options={})
    {
      ccn: id.to_s,
      async: is_async?,
      cloud: semester_in_the_cloud?,
      timeConflictOverride: time_conflict_override?,
      instructionMode: instruction_mode,
      instructionModeCode: instruction_mode_code,
    }
  end

  def is_async?
    attribute_description_for_code_pair('WEB', 'ASYNCH')
  end

  def semester_in_the_cloud?
    attribute_description_for_code_pair('WEB', 'CLOUD')
  end

  def time_conflict_override?
    attribute_description_for_code_pair('TCOR', 'TCEOVRD')
  end

  def instruction_mode
    instructionMode['description']
  end

  def instruction_mode_code
    instructionMode['code']
  end

  private

  def collected_attributes
    @collected_attributes || section_attributes.collect do |item|
      SectionAttribute.new(item)
    end
  end

  def attribute_description_for_code_pair(attr_code, value_code)
    found = collected_attributes.find do |section_attr|
      section_attr.code == attr_code && section_attr.value == value_code
    end

    found&.description
  end

  SectionAttribute = Struct.new(:data) do
    def code
      data['attribute']['code']
    end

    def value
      data['value']['code']
    end

    def description
      data['value']['description']
    end

    def as_json(options={})
      {
        code: code,
        description: description,
        value: data['value']
      }
    end
  end
end
