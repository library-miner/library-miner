# Library Miner

Library Miner は指定したライブラリを利用しているオープンソースプロジェクトを検索できるサービスです。
http://lminer.net で稼働中です。

## Library Miner の構成
Library Minerは下記のリポジトリから構成されています。

- [library-miner](https://github.com/library-miner/library-miner) 
- [library-miner-infra](https://github.com/library-miner/library-infra)
- [library-miner-web-api](https://github.com/library-miner/library-miner-web-api)	
- [library-miner-frontyard]	(https://github.com/library-miner/library-miner-frontyard)	
- [library-miner-zabbix-template]	(https://github.com/library-miner/library-miner-zabbix-template)

## 本リポジトリの役割
本リポジトリでは主に次の役割を果たします。
- プロジェクト/ライブラリ情報の収集
- プロジェクトで利用しているライブラリの解析
- 解析済み情報をWeb側に連携
- 解析状況・Job実行状況の閲覧

***DEMO:***


## Requirement
- Rails 4
- Ruby 2.2.1+

## 動作に必要な設定

* config/database.yml 

     config/database.yml.exampleを参照
     
* config/setting.yml

  - github_crawl_token : github api tokenを設定
  - client_node_id : 複数サーバーで同時実行させる場合、各サーバー間で一意になる値を設定する
  - detail_crawler_process_count : 収集同時実行プロセス数

***SAMPLE:***
```
defaults: &defaults

development:
  github_crawl_token: 'xxxxxx'
  client_node_id: 1
  detail_crawler_process_count: 5
  <<: *defaults

test:
  github_crawl_token: 'xxxxx'
  client_node_id: 1
  detail_crawler_process_count: 1
  <<: *defaults

production:
  github_crawl_token: 'xxxxx'
  client_node_id: 1
  detail_crawler_process_count: 5
  <<: *defaults
```

* .env
  -- MINER_APP_ROOT : 配置先を設定
  -- LIBRARY_MINER_SECRET_KEY : secret key を設定

***SAMPLE:***
```
MINER_APP_ROOT="/var/www/library-miner/current"
LIBRARY_MINER_SECRET_KEY="xxxxx"
```

## 主要機能

* 基本情報収集		
  -	2015/01/01 ~ 2015/01/02 で作成されたプロジェクト基本情報収集	
  ```
	./script/jobs/github_project_crawler_first_time_gnu.sh -e production -from 20150101 -to 20150102
	```
	
  - ヘルプ
  ```
	./script/jobs/github_project_crawler_first_time_gnu.sh  -h
  ```
	
  -	Macでは次のスクリプトを使用する	
  ```	
	./script/jobs/github_project_crawler_first_time.sh -e production -from 20150101 -to 20150102
  ```
	
* 詳細情報収集		
  -	詳細情報未収集の情報を100件取得する	
  ```
	./script/jobs/github_project_detail_crawler.sh -e production -c 100
  ```
	
  -	ヘルプ
  ```
	./script/jobs/github_project_detail_crawler.sh  -h
  ```
	
* プロジェクト情報解析		
  -	収集済みの情報を100件解析する	
  ```
	./script/jobs/project_analyzer.sh -e production -c 100
	```
	
  - ヘルプ
  ```
	./script/jobs/project_analyzer.sh -e production -h
	```
		
* プロジェクト/ライブラリ紐付け解析		
  -	プロジェクト/ライブラリの紐付けされていないデータに対して処理	
  ```
	./script/jobs/library_relation.sh -e production
	```
		
  -	ヘルプ
  ```
	./script/jobs/library_relation.sh -h
	```
	
* プロジェクト基本情報収集チェック		
  初回情報をどこまで収集したか確認したい際に使用する		
		
  -	2015/01/01 ~ 2015/12/31 で基本情報収集をどこまで行ったか確認する	
  ```
	rails runner script/runner/github_init_crawl_check.rb 20150101 20151231
	```
	
	未収集の日付が表示される
		
		
* Delayed Job		
  -	基本/詳細情報収集Job起動	
  ```
	./tools/delayed_job_crawler.sh -e production start	
	```	
  -	詳細情報のみ収集Job起動	
  ```
	./tools/delayed_job_crawler.sh -e production start -o	
	```
	
  -	解析Job起動	
  ```
	./tools/delayed_job_analyzer.sh -e production start	
  ```
