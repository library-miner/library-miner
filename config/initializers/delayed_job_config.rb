Delayed::Worker.destroy_failed_jobs = false # 失敗したジョブをDBから削除しない=false
Delayed::Worker.sleep_delay = 60 # 実行ジョブがない場合に次回実行までのSleep時間（秒）
Delayed::Worker.max_attempts = 5 # リトライ回数
Delayed::Worker.max_run_time = 60.minutes # 最大実行時間
