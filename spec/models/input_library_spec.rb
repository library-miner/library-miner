require 'rails_helper'

RSpec.describe InputLibrary, type: :model do

  describe 'Gem名からFullName取得' do
    context 'Gemが存在しない場合(InputLibrary非存在)' do
      before do
        @t1 = create(:input_project,
                     github_item_id: 100,
                     name: 'test',
                     full_name: 'owner/test')
      end
      it '返却値(full_name)がnilであること' do
        expect(InputLibrary.get_full_name_from_gem_name('test2')).to eq nil
      end
    end

    context 'Gemが存在しない場合(InputLibrary存在)' do
      before do
        @t1 = create(:input_project,
                     github_item_id: 100,
                     name: 'test',
                     full_name: 'owner/test')
        create(:input_library,
               input_project_id: @t1.id,
               name: 'test')
      end
      it '返却値(full_name)がnilであること' do
        expect(InputLibrary.get_full_name_from_gem_name('test2')).to eq nil
      end
    end

    context '対象Gemが存在するがgithubのURLが記載されてなくfullNameを取得できない場合' do
      before do
        @t1 = create(:input_project,
                     github_item_id: 100,
                     name: 'test',
                     full_name: 'owner/test')
        create(:input_library,
               input_project_id: @t1.id,
               name: 'test')
      end
      it '返却値(full_name)がnilであること' do
        expect(InputLibrary.get_full_name_from_gem_name('test')).to eq nil
      end
    end

    context '対象Gemが存在しgithubへのURLがhomepage_uriに存在する場合' do
      before do
        @t1 = create(:input_project,
                     github_item_id: 100,
                     name: 'test',
                     full_name: 'owner/test')
        create(:input_library,
               input_project_id: @t1.id,
               name: 'test',
               homepage_uri: 'http://github.com/owner/test',
              )
      end
      it 'homepage_uriの/区切り最後から2つの文字列が取得できること' do
        expect(InputLibrary.get_full_name_from_gem_name('test')).to eq 'owner/test'
      end
    end

    context '対象Gemが存在しgithub以外へのURLがhomepage_uriに存在する場合' do
      before do
        @t1 = create(:input_project,
                     github_item_id: 100,
                     name: 'test',
                     full_name: 'owner/test')
        create(:input_library,
               input_project_id: @t1.id,
               name: 'test',
               homepage_uri: 'http://github2.com/owner/test',
              )
      end
      it '返却値(full_name)がnilであること' do
        expect(InputLibrary.get_full_name_from_gem_name('test')).to eq nil
      end
    end

    context '対象Gemが存在しgithubへのURLがhomepage_uriに存在する場合 かつ 最後が/終わりの場合' do
      before do
        @t1 = create(:input_project,
                     github_item_id: 100,
                     name: 'test',
                     full_name: 'owner/test')
        create(:input_library,
               input_project_id: @t1.id,
               name: 'test',
               homepage_uri: 'http://github.com/owner/test/',
              )
      end
      it 'homepage_uriの/区切り最後から2つの文字列が取得でき,最後の/は除かれていること' do
        expect(InputLibrary.get_full_name_from_gem_name('test')).to eq 'owner/test'
      end
    end

    context '対象Gemが存在しgithubへのURLがsource_code_uriに存在する場合' do
      before do
        @t1 = create(:input_project,
                     github_item_id: 100,
                     name: 'test',
                     full_name: 'owner/test')
        create(:input_library,
               input_project_id: @t1.id,
               name: 'test',
               source_code_uri: 'http://github.com/owner/test',
              )
      end
      it 'homepage_uriの/区切り最後から2つの文字列が取得できること' do
        expect(InputLibrary.get_full_name_from_gem_name('test')).to eq 'owner/test'
      end
    end

    context '対象Gemが存在しgithub以外へのURLがsource_code_uriに存在する場合' do
      before do
        @t1 = create(:input_project,
                     github_item_id: 100,
                     name: 'test',
                     full_name: 'owner/test')
        create(:input_library,
               input_project_id: @t1.id,
               name: 'test',
               source_code_uri: 'http://github2.com/owner/test',
              )
      end
      it '返却値(full_name)がnilであること' do
        expect(InputLibrary.get_full_name_from_gem_name('test')).to eq nil
      end
    end


    context '対象Gemが存在しgithubへのURLがsource_code_uriに存在する場合 かつ 最後が/終わりの場合' do
      before do
        @t1 = create(:input_project,
                     github_item_id: 100,
                     name: 'test',
                     full_name: 'owner/test')
        create(:input_library,
               input_project_id: @t1.id,
               name: 'test',
               source_code_uri: 'http://github.com/owner/test/',
              )
      end
      it 'homepage_uriの/区切り最後から2つの文字列が取得でき,最後の/は除かれていること' do
        expect(InputLibrary.get_full_name_from_gem_name('test')).to eq 'owner/test'
      end
    end

    context '対象Gemが存在しgithubへのURLがsource_code_uriに存在する場合 かつ homepage_uri はgithub以外の場合' do
      before do
        @t1 = create(:input_project,
                     github_item_id: 100,
                     name: 'test',
                     full_name: 'owner/test')
        create(:input_library,
               input_project_id: @t1.id,
               name: 'test',
               source_code_uri: 'http://github.com/owner/test',
              )
        create(:input_library,
               input_project_id: @t1.id,
               name: 'test',
               homepage_uri: 'http://github2.com/owner/test2',
              )

      end
      it 'source_code_uriの/区切り最後から2つの文字列が取得できること' do
        expect(InputLibrary.get_full_name_from_gem_name('test')).to eq 'owner/test'
      end
    end

    context '対象Gemが存在しgithubへのURLがhomepage_uriに存在する場合 かつ source_code_uri はgithub以外の場合' do
      before do
        @t1 = create(:input_project,
                     github_item_id: 100,
                     name: 'test',
                     full_name: 'owner/test')
        create(:input_library,
               input_project_id: @t1.id,
               name: 'test',
               source_code_uri: 'http://github2.com/owner/test2',
              )
        create(:input_library,
               input_project_id: @t1.id,
               name: 'test',
               homepage_uri: 'http://github.com/owner/test',
              )

      end
      it 'homepage_uriの/区切り最後から2つの文字列が取得できること' do
        expect(InputLibrary.get_full_name_from_gem_name('test')).to eq 'owner/test'
      end
    end

  end
end
