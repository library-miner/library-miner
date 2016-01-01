# == Schema Information
#
# Table name: library_relation_errors
#
#  id           :integer          not null, primary key
#  library_name :string(255)      not null
#  error_count  :integer          not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class LibraryRelationError < ActiveRecord::Base
  # Relations

  # Validations

  # Scopes

  # Delegates

  # Class Methods
  def self.count_up_error_library(library_name)
    library = LibraryRelationError.find_by(library_name: library_name)
    if library.nil?
      library = LibraryRelationError.new(
        library_name: library_name,
        error_count: 1
      )
    else
      library.error_count += 1
    end
    library.save
  end

  # Methods
end
