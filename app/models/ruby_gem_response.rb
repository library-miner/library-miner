class RubyGemResponse
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor *%i(
    is_success items
  )

  def self.parse(response)
    new.tap do |r|
      body = JSON.parse(response.body)
      header = response.headers
      r.is_success = response.success?
      r.items = if body['dependencies']['runtime'].present?
                  body['dependencies']['runtime'].map { |v| HashObject.new(v) }
                else
                  []
                end
    end
  end

end
