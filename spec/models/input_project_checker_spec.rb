require 'rails_helper'

RSpec.describe InputProjectChecker, type: :model do
  describe '収集日格納' do
    context '対象が存在しない場合' do
      before do
        InputProjectChecker.delete_all
        InputProjectChecker.insert_crawl_date('20160101')
      end
      it '新規作成されること' do
        expect(InputProjectChecker.all.count).to eq 1
      end
    end
    context 'すでに対象が存在する場合' do
      before do
        create(:input_project_checker,
               crawl_date: '20160101',
               updated_at: '2000-01-01')
        @r1 = InputProjectChecker.all[0]
        InputProjectChecker.insert_crawl_date('20160101')
      end
      it '更新されること' do
        @r2 = InputProjectChecker.all[0]
        expect(@r1.updated_at).not_to be @r2.updated_at
      end
    end
  end

  describe '基本情報抜けチェック' do
    context 'from to が正しく入力されている場合' do
      before do
        create(:input_project_checker,
               crawl_date: '2015-12-30')
        create(:input_project_checker,
               crawl_date: '2016-01-01')
        create(:input_project_checker,
               crawl_date: '2016-01-03')
      end
      it '抜け日を配列で返すこと' do
        results = InputProjectChecker.check_crawl('20151230', '20160104')
        expect(results).to match_array ['2015-12-31', '2016-01-02', '2016-01-04']
      end
    end

    context 'from が正しく入力されていない場合' do
      it '空配列を返す' do
        results = InputProjectChecker.check_crawl('', '20160104')
        expect(results).to match_array []
      end
    end

    context 'to が正しく入力されていない場合' do
      it '空配列を返す' do
        results = InputProjectChecker.check_crawl('20150101', '')
        expect(results).to match_array []
      end
    end
  end
end
