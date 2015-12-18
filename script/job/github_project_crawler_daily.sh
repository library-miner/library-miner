#!/bin/bash

# ヘルプメッセージ
usage() {
  echo "Usage: $PROGNAME -e production -date 20150101 -time 07 -term 1"
  echo
  echo "オプション:"
  echo "  -h, --help"
  echo "  -e <ARG>     <必須> (development/production)"
  echo "  -date <DATE> ex. 20150101"
  echo "  -time <DATE> ex. 07"
  echo "  -term <ARG> ex. 1 (timeの1時間前からtimeまで)"
  echo
  exit 1
}

PROGNAME=$(basename $0)
HELP_MSG="'$PROGNAME -h'と指定することでヘルプを見ることができます"

# オプション解析
for OPT in "$@"
do
  case "$OPT" in
    # ヘルプメッセージ
    '-h'|'--help' )
    usage
    exit 1
    ;;

    # 環境指定
    '-e' )
    FLG_ENV=1
    # オプションに引数がなかった場合（必須）
    if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
      echo "$PROGNAME:「$1」オプションには引数(development または production)が必要です" 1>&2
      exit 1
    fi
    ARG_ENV="$2"
    if [[ "$ARG_ENV" != "development" ]] && [[ "$ARG_ENV" != "production" ]]; then
      echo "$PROGNAME:「$1」オプションにはdevelopment または productionが使用できます" 1>&2
      exit 1
    fi
    shift 2
    ;;

    '-date' )
    CURRENT_DATE="$2"
    # オプションに引数がなかった場合（必須）
    if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
      echo "$PROGNAME:「$1」オプションには引数(ex. 20150101)が必要です" 1>&2
      exit 1
    fi

    shift 2
    ;;

    '-time' )
    CURRENT_TIME="$2"
    # オプションに引数がなかった場合（必須）
    if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
      echo "$PROGNAME:「$1」オプションには引数(ex. 07)が必要です" 1>&2
      exit 1
    fi

    shift 2
    ;;

    '-term' )
    RUN_TERM="$2"
    # オプションに引数がなかった場合（必須）
    if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
      echo "$PROGNAME:「$1」オプションには引数(ex. 1)が必要です" 1>&2
      exit 1
    fi

    shift 2
    ;;


  esac
done

# -e パラメータがない場合
if [ -z $FLG_ENV ]; then
  echo "$PROGNAME:「-e」オプションは必須です。正しいオプションを指定してください" 1>&2
  echo $HELP_MSG 1>&2
  exit 1
fi

# -date パラメータがない場合
if [ -z $CURRENT_DATE ]; then
  echo "$PROGNAME:「-date」オプションは必須です。正しいオプションを指定してください" 1>&2
  echo $HELP_MSG 1>&2
  exit 1
fi

# -time パラメータがない場合
if [ -z $CURRENT_TIME ]; then
  echo "$PROGNAME:「-to」オプションは必須です。正しいオプションを指定してください" 1>&2
  echo $HELP_MSG 1>&2
  exit 1
fi

# -term パラメータがない場合
if [ -z $RUN_TERM ]; then
  echo "$PROGNAME:「-term」オプションは必須です。正しいオプションを指定してください" 1>&2
  echo $HELP_MSG 1>&2
  exit 1
fi

current=$(date -j -f %Y%m%d%H "$CURRENT_DATE$CURRENT_TIME" +%Y%m%d%H)

for (( i=0; i < $RUN_TERM; i++ )); do
  # 起動処理
  arg1=$( date -j -v-1H -f %Y%m%d%H $current +%Y%m%d%H)
  arg2=$current
  bundle exec rails runner "GithubProjectCrawler.perform_later(\"$arg1\",\"$arg2\",mode: \"UPDATED\")" -e $ARG_ENV
  echo "enqueue github_project_crawler $arg1 - $arg2"
  current=$( date -j -v-1H -f %Y%m%d%H $current +%Y%m%d%H)
done


