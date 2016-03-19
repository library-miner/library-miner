module JsonScrubbable
  extend ActiveSupport::Concern

  included do
    alias_method :original_to_json, :to_json

    def to_json
      attributes.to_json
    end
  end
end
