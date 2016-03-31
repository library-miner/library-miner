require 'rails_helper'

RSpec.describe ProjectAnalyzer, type: :model do
  describe 'Project Analyzerテスト' do
    context '代表ケース' do
      before :each do
        # Input Project に テストデータ投入
        i1 = create(
          :input_project,
          full_name: 'test/full_name',
          github_updated_at: Time.zone.today,
          crawl_status_id: 2
        )
        create(:input_tree,
               input_project_id: i1.id,
               path: 'Gemfile'
              )
        create(:input_branch,
               input_project_id: i1.id)
        create(:input_tag,
               input_project_id: i1.id)
        create(:input_weekly_commit_count,
               input_project_id: i1.id)
        # テスト対象実行
        ProjectAnalyzer.new.perform(analyze_count: 1)
      end

      it 'InputProject の情報が Projectに格納されていること' do
        results = Project.all

        expect(results.count).to eq 1
        expect(results[0].full_name).to eq 'test/full_name'
      end

      it '初回作成後はweb連携フラグが0(未連携)となること' do
        results = Project.all

        expect(results.count).to eq 1
        expect(results[0].export_status_id).to eq 0
      end

      it '解析完了後はInputProject のステータスが 3(解析済み)となること' do
        results = InputProject.all

        expect(results[0].crawl_status_id).to eq 3
      end

      it 'ProjectTreeにInputTreeの内容がコピーされること' do
        results = ProjectTree.all

        expect(results.count).to eq 1
        expect(results[0].path).to eq 'Gemfile'
      end

      it 'ProjectBranchにInputBranchの内容がコピーされること' do
        results = ProjectBranch.all

        expect(results.count).to eq 1
        expect(results[0].name).to eq 'master'
      end

      it 'ProjectTagにInputTagの内容がコピーされること' do
        results = ProjectTag.all

        expect(results.count).to eq 1
        expect(results[0].name).to eq 'v1.0'
      end

      it 'ProjectWeeklyCommitCountにInputWeeklyCommitCountの内容がコピーされること' do
        results = ProjectWeeklyCommitCount.all

        expect(results.count).to eq 1
        expect(results[0].all_count).to eq 777
      end
    end

    context 'Tree情報に解析対象外のファイルが含まれる場合' do
      before :each do
        # Input Project に テストデータ投入
        i1 = create(
          :input_project,
          full_name: 'test/full_name',
          github_updated_at: Time.zone.today,
          crawl_status_id: 2
        )
        create(:input_tree,
               input_project_id: i1.id,
               path: 'NotAnalyzeTarget'
              )
        # テスト対象実行
        ProjectAnalyzer.new.perform(analyze_count: 1)
      end

      it 'Tree情報が格納されないこと' do
        results = ProjectTree.all
        expect(results.count).to eq 0
      end
    end

    context 'readme.mdファイルが含まれる場合' do
      before :each do
        # Input Project に テストデータ投入
        i1 = create(
          :input_project,
          id: 2,
          full_name: 'test/full_name',
          crawl_status_id: 2
        )
        create(:input_tree,
               input_project_id: i1.id,
               path: 'readme.md')
        # Readme
        create(:input_content,
               input_project_id: i1.id,
               path: 'readme.md',
               content: 'test'
              )
      end
      it 'InputContentに格納されているReadmeファイルの内容がProjectReadmeにコピーされること' do
        # テスト対象実行
        ProjectAnalyzer.new.perform(analyze_count: 1)

        # 検証
        results = ProjectReadme.all

        expect(results.count).to eq 1
        expect(results[0].content).to eq 'test'
      end
    end

    context 'readme.mdファイルが含まれない場合' do
      before :each do
        # Input Project に テストデータ投入
        i1 = create(
          :input_project,
          full_name: 'test/full_name',
          crawl_status_id: 2
        )
        create(:input_tree,
               input_project_id: i1.id,
               path: 'READREAD.md')
        # Readme
        create(
          :input_content,
          input_project_id: i1.id,
          path: 'READREAD.md'
        )
      end
      it 'InputContentに格納されている内容がProjectReadmeにコピーされないこと' do
        # テスト対象実行
        ProjectAnalyzer.new.perform(analyze_count: 1)

        # 検証
        results = ProjectReadme.all

        expect(results.count).to eq 0
      end
    end

    context 'Gemfileが存在する かつ RubyGemでない場合' do
      before :each do
        # Input Project に テストデータ投入
        i = create(
          :input_project,
          full_name: 'test/full_name',
          crawl_status_id: 2
        )
        c = File.read('spec/fixtures/gemfile01.txt')
        # Gemfile
        create(
          :input_content,
          input_project_id: i.id,
          path: 'Gemfile',
          content: c.to_s
        )
        InputDependencyLibrary.delete_all

        # テスト対象実行
        ProjectAnalyzer.new.perform(analyze_count: 1)
      end

      it 'Gemfileの内容が解析され ProjectDependencyに 外部ライブラリ情報が格納されること' do
        results = ProjectDependency.all

        expect(results.count).to eq 6
        expect(results[1].library_name).to eq 'sqlite3'
      end

      it 'dependencies ライブラリもProjectとして保存されている(is_incomplete = trueとする)' do
        results = Project.where(is_incomplete: 1)

        expect(results.count).to eq 7
      end
    end

    context 'Gemfileが存在する かつ RubyGemである場合' do
      before :each do
        # Input Project に テストデータ投入
        i = create(
          :input_project,
          full_name: 'test/full_name',
          crawl_status_id: 2
        )
        c = File.read('spec/fixtures/gemfile02.txt')
        # Gemfile
        create(
          :input_content,
          input_project_id: i.id,
          path: 'Gemfile',
          content: c.to_s
        )
        # RubyGem
        create(
          :input_dependency_library,
          input_project_id: i.id,
          name: 'test_lib'
        )

        # テスト対象実行
        ProjectAnalyzer.new.perform(analyze_count: 1)
      end

      it 'InputDependencyLibraryに格納されている情報も'\
        'ProjectDependency にライブラリ情報が格納されること' do
        results = ProjectDependency.all

        expect(results.count).to eq 7
        expect(results[6].library_name).to eq 'test_lib'
      end
      it 'dependencies ライブラリもProjectとして保存されている(is_incomplete = trueとする)' do
        results = Project.where(is_incomplete: 1)

        expect(results.count).to eq 8
      end
    end

    context 'InputContentに何も情報が格納されていない場合' do
      before :each do
        InputProject.destroy_all
        InputContent.delete_all
        # Input Project に テストデータ投入
        create(
          :input_project,
          full_name: 'test/full_name',
          crawl_status_id: 2
        )

        # テスト対象実行
        ProjectAnalyzer.new.perform(analyze_count: 1)
      end

      it 'InputProject のステータスが 3(解析済み)となること' do
        results = InputProject.where(crawl_status_id: 3)

        expect(results.count).to eq 1
      end
    end
  end

  describe 'Project情報作成テスト' do
    context 'Projectにgithub_item_idが存在する場合' do
      before :each do
        InputProject.destroy_all
        Project.destroy_all

        # Input Project に テストデータ投入
        @i1 = create(
          :input_project,
          full_name: 'test/name',
          name: 'name',
          crawl_status_id: 2,
          github_item_id: 100,
          size: 999
        )

        # Project にテストデータ投入
        @i2 = create(
          :project,
          full_name: 'test/name',
          name: 'name',
          github_item_id: 100,
          size: 777,
          export_status_id: 2
        )

        @i3 = create(
          :project,
          full_name: 'test2/name',
          name: 'name',
          github_item_id: 101,
          size: 777
        )

        # テスト対象実行
        ProjectAnalyzer.new.perform(analyze_count: 1)
      end

      it 'InputProjectのgithub_item_idと合致するProjectの情報が更新されること' do
        expect(Project.find(@i2.id).size).to eq 999
      end

      it 'InputProjectのgithub_item_idと合致するProjectの情報のWeb連携フラグが0(未連携)となること' do
        expect(Project.find(@i2.id).export_status_id).to eq 0
      end

      it 'InputProjectのgithub_item_idと合致しないProjectの情報が更新されないこと' do
        expect(Project.find(@i3.id).size).to eq 777
      end
    end

    context 'FullNameが異なる2つのプロジェクトが存在する場合 かつ 両者ともgithub_item_idが存在しない場合' do
      before :each do
        InputProject.destroy_all
        Project.destroy_all

        # Input Project に テストデータ投入
        @i1 = create(
          :input_project,
          full_name: 'test/name',
          name: 'name',
          crawl_status_id: 2,
          github_item_id: 100,
          size: 999
        )

        # Project にテストデータ投入
        @i3 = create(
          :project,
          full_name: 'test2/name',
          name: 'name',
          github_item_id: nil,
          size: 777
        )

        @i2 = create(
          :project,
          full_name: 'test/name',
          name: 'name',
          github_item_id: nil,
          size: 777
        )

        # テスト対象実行
        ProjectAnalyzer.new.perform(analyze_count: 1)
      end

      it 'InputProjectのfull_nameと合致するProjectの情報が更新されること' do
        expect(Project.find(@i2.id).size).to eq 999
      end
      it 'InputProjectのfull_nameと合致しないProjectの情報が更新されないこと' do
        expect(Project.find(@i3.id).size).to eq 777
      end
    end

    context 'Nameのみ存在する場合 と Nameは同じだがgithub_item_idが異なる場合' do
      before :each do
        InputProject.destroy_all
        Project.destroy_all

        # Input Project に テストデータ投入
        @i1 = create(
          :input_project,
          full_name: 'test/name',
          name: 'name',
          crawl_status_id: 2,
          github_item_id: 100,
          size: 999
        )

        # Project にテストデータ投入
        @i3 = create(
          :project,
          full_name: 'test2/name',
          name: 'name',
          github_item_id: 101,
          size: 777
        )

        @i2 = create(
          :project,
          full_name: nil,
          name: 'name',
          github_item_id: nil,
          size: 777
        )

        # テスト対象実行
        ProjectAnalyzer.new.perform(analyze_count: 1)
      end

      it 'github_item_idが存在せずnameと合致するProjectの情報が更新されること' do
        expect(Project.find(@i2.id).size).to eq 999
      end

      it 'github_item_idが合致しないProjectの情報が更新されないこと' do
        expect(Project.find(@i3.id).size).to eq 777
      end
    end

    context 'Nameのみ存在する場合 と Nameは同じだがfull_nameが異なる場合' do
      before :each do
        InputProject.destroy_all
        Project.destroy_all

        # Input Project に テストデータ投入
        @i1 = create(
          :input_project,
          full_name: 'test/name',
          name: 'name',
          crawl_status_id: 2,
          github_item_id: 100,
          size: 999
        )

        # Project にテストデータ投入
        @i3 = create(
          :project,
          full_name: 'test2/name',
          name: 'name',
          github_item_id: nil,
          size: 777
        )

        @i2 = create(
          :project,
          full_name: nil,
          name: 'name',
          github_item_id: nil,
          size: 777
        )

        # テスト対象実行
        ProjectAnalyzer.new.perform(analyze_count: 1)
      end

      it 'full_nameがなくnameと合致するProjectの情報が更新されること' do
        expect(Project.find(@i2.id).size).to eq 999
      end

      it 'full_nameが合致しないProjectの情報が更新されないこと' do
        expect(Project.find(@i3.id).size).to eq 777
      end
    end

    context 'InputProjectのnameと同じだが、full_nameが異なる場合' do
      before :each do
        InputProject.destroy_all
        Project.destroy_all

        # Input Project に テストデータ投入
        @i1 = create(
          :input_project,
          full_name: 'test/name',
          name: 'name',
          crawl_status_id: 2,
          github_item_id: 100,
          size: 999
        )

        # Project にテストデータ投入
        @i2 = create(
          :project,
          full_name: 'test2/name',
          name: 'name',
          github_item_id: nil,
          size: 777
        )
        # テスト対象実行
        ProjectAnalyzer.new.perform(analyze_count: 1)
      end

      it '新規にプロジェクト情報が作成されること' do
        expect(Project.all.count).to eq 2
      end

      it 'full_nameが合致しないProjectの情報が更新されないこと' do
        expect(Project.find(@i2.id).size).to eq 777
      end
    end
  end

  describe 'プロジェクト関連情報更新確認' do
    context 'Gemfileの内容が以前より減った(Gemfileからライブラリを消した)場合' do
      before :each do
        # Input Project に テストデータ投入
        i = create(
          :input_project,
          full_name: 'test/full_name',
          github_item_id: 10,
          crawl_status_id: 2
        )
        c = File.read('spec/fixtures/gemfile03.txt')
        # Gemfile
        create(
          :input_content,
          input_project_id: i.id,
          path: 'Gemfile',
          content: c.to_s
        )
        @p1 = create(
          :project,
          github_item_id: 10,
          full_name: 'test/full_name'
        )
        @pd1 = create(
          :project_dependency,
          project_from_id: @p1.id,
          library_name: 'rails'
        )
        @pd2 = create(
          :project_dependency,
          project_from_id: @p1.id,
          library_name: 'sqlite3'
        )
        @pd3 = create(
          :project_dependency,
          project_from_id: @p1.id,
          library_name: 'omniauth-eveonline'
        )

        # テスト対象実行
        ProjectAnalyzer.new.perform(analyze_count: 1)
      end

      it 'ProjectDependencyから減ったライブラリの情報が削除されること' do
        expect(ProjectDependency.all.count).to eq 2
        expect { ProjectDependency.find(@pd3.id) }.to raise_exception(
          ActiveRecord::RecordNotFound)
      end
    end
    context 'Gemfileの内容が以前より増えた(Gemfileからライブラリを増やした)場合' do
      before :each do
        # Input Project に テストデータ投入
        i = create(
          :input_project,
          full_name: 'test/full_name',
          github_item_id: 10,
          crawl_status_id: 2
        )
        c = File.read('spec/fixtures/gemfile03.txt')
        # Gemfile
        create(
          :input_content,
          input_project_id: i.id,
          path: 'Gemfile',
          content: c.to_s
        )
        @p1 = create(
          :project,
          github_item_id: 10,
          full_name: 'test/full_name'
        )
        @pd1 = create(
          :project_dependency,
          project_from_id: @p1.id,
          library_name: 'rails'
        )

        # テスト対象実行
        ProjectAnalyzer.new.perform(analyze_count: 1)
      end

      it 'ProjectDependencyから増えたライブラリの情報が追加されること' do
        expect(ProjectDependency.all.count).to eq 2
        expect(ProjectDependency.where(library_name: 'sqlite3').count).to eq 1
      end
    end
  end
end
