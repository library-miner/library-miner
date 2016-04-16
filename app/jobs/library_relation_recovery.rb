# マスタライブラリを元にライブラリ紐付けを再構築する
#
# [使い方]
#   LibraryRelationRecovery.new.perform()
class LibraryRelationRecovery < LibraryRelation
  queue_as :analyzer

  def perform(library_project_id: '')
    # 紐付け再構築対象のマスタライブラリのステータスを未実施にする
    update_master_library_waiting
    # 未実施対象に対してライブラリ紐付け行う
    associate_library_and_project
  end

  private

  # 紐付け再構築対象のマスタライブラリのステータスを未実施にする
  def update_master_library_waiting
    MasterLibrary.update_all(
      status_id: GeneralStatus::WAITING,
      updated_at: Time.zone.now
    )
  end

  # 未実施対象に対してライブラリ紐付け行う
  def associate_library_and_project
    libraries = MasterLibrary.where(status_id: GeneralStatus::WAITING)
    libraries.find_each do |library|
      ProjectDependency.where(library_name: library.library_name).update_all(
        project_to_id: library.project_to_id,
        updated_at: Time.zone.now
      )
    end
  end
end
