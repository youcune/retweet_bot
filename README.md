# retweet_bot

設定ファイルを書くだけで指定したキーワードでTwitterを検索してランダムにリツイートするbot

# Getting started

以下インストール手順の例です。

```
$ git clone https://github.com/youcune/retweet_bot.git
$ cd retweet_bot
$ bundle install --path ./bundle/ --without development
$ mv ./config/config-example.yml ./config/config.yml
$ vim ./config/config.yml
  -> 設定方法は下記参照
$ crontab -e
# 17:00に実行する例
# デフォルトではcrontabで起動する場合にPATHが通っていないので、PATHを通しておくかフルパスで書く
# retweet_bot.rbの引数は、./config/以下のymlファイルのファイル名と対応させてください
# これにより、ひとつ設置したら複数の設定で実行できるようになります
# STDOUTのみリダイレクトしておくと（エラーはSTDERRに書かれるので）エラーの出た場合はcrontabがメールを送ってくれます
0 17 * * * BUNDLE_GEMFILE=/path/to/Gemfile bundle exec ruby /path/to/retweet_bot.rb config > /dev/null
```

# Config

## twitter:

空気を読んで設定してください

## logger:

* shift_age: ログファイルを切り替える期間を指定します。[daily, weekly, monthlyが指定可能](http://docs.ruby-lang.org/ja/2.0.0/class/Logger.html#S_NEW)です。

## search_queries:

配列で指定します。この中からどれかひとつランダムに選択して検索します。

## ng_words:

配列で指定します。この中のワードが含まれていたらリツイートしません。

## ng_clients:

配列で指定します。この中のワードが含まれていたるソースからのツイートはリツイートしません。

## ng_users:

配列で指定します。この中のユーザのツイートはリツイートしません。サクッと探して見つけたインターネットの癌みたいなアカウントをあらかじめ登録しておきました。

# License

* GPL
* パクツイアフィアカウントのようなインターネットの癌みたいな使い方はご遠慮ください
