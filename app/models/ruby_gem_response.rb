class RubyGemResponse
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  attr_accessor *%i(
    is_success items base_information
  )

  def self.parse(response)
    new.tap do |r|
      body = JSON.parse(response.body)
      header = response.headers
      r.is_success = response.success?
      name = if body['name'].present?
                 body['name']
               else
                 ""
               end
      version = if body['version'].present?
                 body['version']
               else
                 ""
               end
      homepage_uri = if body['homepage_uri'].present?
                       body['homepage_uri']
                     else
                       nil
                     end
      source_code_uri = if body['source_code_uri'].present?
                 body['source_code_uri']
               else
                 nil
               end
      r.base_information = {
        name: name,
        version: version,
        homepage_uri: homepage_uri,
        source_code_uri: source_code_uri
      }
      r.items = if body['dependencies']['runtime'].present?
                  body['dependencies']['runtime'].map { |v| HashObject.new(v) }
                else
                  []
                end
    end
  end

end
