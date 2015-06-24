# 新開発環境の使い方

## ローカル環境の設定

開発環境を使用するために必要なアプリをインストールする。

---

### VirtualBox

[download](https://www.virtualbox.org/wiki/Downloads)  ※最新を選ぶ

**インストール**

インストール後にインストールしたディレクトリにPATHを通す。
デフォでは「C:\Program Files\Oracle\VirtualBox」にインストールされた。

1. 「田(windows key) + Pause 」でシステムを起動
1. 左の「システムの詳細設定」→「詳細設定」→「環境変数」
1. 「ユーザ環境変数」から「Path」を選択して「編集」
1. 「変数値」の値の最後に「;(上記インストールディレクトリ)」を追加

---

### Vagrant

[download](http://downloads.vagrantup.com/)  ※最新を選ぶ

**[20150624]**  
Latest [vagrant_1.7.2](https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2.msi) だと、saharaプラグインのインストールでエラーになる。  
Old Version [vagrant_1.7.1](https://www.vagrantup.com/download-archive/v1.7.1.html) で、環境構築可能となる。

**インストール**

ダイアログに従ってインストールする。

**BOXの追加**

コマンドプロンプトにて作業

```
$ vagrant box add centos64 https://github.com/2creatives/vagrant-centos/releases/download/v0.1.0/centos64-x86_64-20131030.box
```

**saharaプラグインのインストール**

コマンドプロンプトにて作業

```
$ vagrant plugin install sahara
```

**Macはvagrant-triggersのプラグインもインストール**

```
$ vagrant plugin install vagrant-triggers
```


---

## 開発環境の構築

開発環境でTESTの動作が行えるようにようにする。

### 設定ファイルの準備

svnから「vagrant」ディレクトリをチェックアウトする。

現在のディレクトリ構成

```
/app
/framework
/library
```

チェックアウト後のディレクトリ構成

```
/app
/framework
/library
/vagrant
```

「vagrant」ディレクトリから「Vagrantfile.chef」と「Vagrantfile.win」もしくは「Vagrantfile.mac」を「Vagrantfile」としてコピーする

チェックアウト後のディレクトリ構成

```
/app
/framework
/library
/vagrant
Vagrantfile
Vagrantfile.chef
```

※最新のvagrantディレクトリを周りの人にもらいましょう！

### VMのプロビジョニング

vagrantコマンドは全てプロジェクトのディレクトリで行う。

**vagrantをsandboxモードにしてVMのロールバックをできるように**

コマンドプロンプトにて作業

```
$ cd <TESTのプロジェクトのディレクトリ>
$ vagrant up --no-provision  # 起動時にプロビジョニングされるのでしないように引数を渡す
$ vagrant sandbox on
```

**プロビジョニング**

コマンドプロンプトにて作業

```
$ vagrant provision
$ vagrant sandbox commit
$ vagrant sandbox off
```

### VMに接続

macとかだと vagrant sshでいけるけどwinだと無理なので下記の方法で接続する。
ログインして問題がないかチェック
```
ホスト：127.0.0.1
ポート：2222
ユーザ：vagrant
パスワード：vagrant
秘密鍵：(ユーザディレクトリ)/.vagrant.d/insecure_private_ke
```

http://localtest-hoge/ のような個人のホスト名でアクセスして動作できるかチェックする。
問題がなければコミットしてVMの状態を保存する。
※保存しないと前回のコミットまで戻るので注意

コマンドプロンプトにて作業

```
$ vagrant sandbox commit
```


### VMがうまく起動しない場合

VT-ｘが有効になっていないエラーが出る場合は、BIOSの設定でVT-x(Intel(R) Virtualization Technology)を
有効にしてください。
参考URL：http://futurismo.biz/archives/1647

timezoneがゴニョゴニョ言われる場合はvagrant/cookbooks/timezone/metadata.rbの中身に以下を追加
```
version          "0.0.2"
name             "timezone"　←ここを追加
```

### 韓国版について

日本版とは別に韓国版を作成する場合は
vagrantファイルのポート設定を変更する必要がある
たとえばこんな感じ
```
  config.vm.network :forwarded_port, guest: 80, host: 2223
  config.vm.network :forwarded_port, guest: 8080, host: 8081
```
あとは、日本版と同じように設定を行う。
puttyからの接続は実際にプロビジョニングした際に割り当てられるポートを使用する

ポート指定しないと繋げられないので
プロクシを導入するか、ソースコードでsmarty/confの個人設定のURLに「:2223」をくっつける（index.phpのURL_MAINのdefineも変える）
プロクシを導入したほうがソースコードを間違えてコミットしないので推奨

chromeならば「Switchy!」というプラグインがあるので
こいつをインストールする
proxy prifilesのmanual configurationにローカルのサーバー名（localtest-koria-hoge）とポート番号（2223）を入れてsave
switch rulesのURLパターンにhttp://localtest-kor-hoge/*を入れてproxy profileの項目は↑で設定した名前を選択してsave
あとは、プラグインのauto switch modeにすれば、勝手に別のポートに接続されます。

ポート変更した際にmemcachedのエラーが多発するようになり
確認してみると本番のmemcachedやDBを見に行く状態になっていました。
localtest-kor-hoge.iniファイルに以下のものを追加すると直りました。
```
[memcached]
servers.0.host = localhost
servers.0.port = 11211
servers.0.persistent = TRUE
```

### キャッシュの消し方

キャッシュすべて消えます。

```
$ sudo service memcached restart
```

### php-timecopの設定

vagrantファイルにtimecopのインストールが書かれていれば
以下の作業はいりません

上記で一通りの設定が終わったら
puttyなどでログインを行い、php-timecopのインストールを行います。
rootのパスワードはvagrantです

```
su -
git clone https://github.com/hnw/php-timecop.git
cd php-timecop
phpize
./configure
make
make install

vi /etc/php.ini

↓を追加
extension=timecop.so

:wq

/etc/init.d/httpd restart
```

## vagrantの使い方

起動

```
$ vagrant up
```

終了

```
$ vagrant halt
```

ログイン

```
$ vagrant ssh
```

Vagrantfile作成

```
$ vagrant init
```

再起動(Vagrantfileリロード)

```
$ vagrant reload
```

sandoboxモード
offにすると前回のコミットまで戻り、sandoboxモードを抜ける。

```
$ vagrant sandbox on
$ vagrant sandbox off
```

sandbox状態確認

```
$ vagrant sandbox status
```

sandboxコミット

```
$ vagrant sandbox commit
```

sandboxロールバック

```
$ vagrant sandbox rollbak
```

---

## エラー対処

基本的に1度設定してしまえば2回目からはvagrant upをすれば起動するようになるが
まれに以下のようなエラーが出る場合がある
```
Bringing machine 'default' up with 'virtualbox' provider...
Your VM has become "inaccessible." Unfortunately, this is a critical error
with VirtualBox that Vagrant can not cleanly recover from. Please open VirtualBox
and clear out your inaccessible virtual machines or find a way to fix
them.
```
この場合は、virtual-boxが設定されているディレクトリ（\user\(ユーザー名)\VirtualBox VMs\(環境名)）に行き
(設定名).vbox-tmpファイルをリネームで(設定名).vboxに変更することで直った

---

## 開発環境の使い方

「localtest-hoge」は個人が開発環境で設定しているホスト名

**通常アクセス**

通常の開発環境にアクセスする。

```
http://localtest-hoge/
```

**プロファイリング**

開発環境にアクセスしプロファイリングをする。

```
http://localtest-hoge:8080/
```

**プロファイリング結果確認**

上記でプロファイリングを行った結果を解析する。
※初回のアクセス時はプロファイリングを行ったあとでなければ表示されないので注意。

```
http://localhost/xhgui/webroot/
```

---

## XHGuiの使い方

### メニュー

Recent
```
最近のアクセス順で表示する
```

Longest wall time
```
処理時間が長い順で表示する
```

Most CPU
```
CPUの処理時間が長い順で表示
```

Most memory
```
メモリ使用量が多い順で表示
```

Custom View
```
条件を指定して解析結果から検索
```

Watch Functions
```
監視する関数を指定する
設定された関数はアクセスの詳細にて抽出して表示される
```

Waterfall
```
条件で抽出し、アクセスをウォーターフォールで表示
```

---

### 解析リスト

URL

```
解析したURL
クリックするとページ単位の解析結果に移動
```


Time
```
解析した日時
クリックするとアクセス単位の解析結果に移動
```

wt
```
処理にかかった時間
```

cpu
```
CPUの処理にかかった時間
```

mu
```
処理が呼び出された時点でのメモリの使用容量(たぶん)
```

pmu
```
処理中のメモリ使用容量の最大値(たぶん)
```

---

### ページ単位の解析結果

解析リストからURLをクリックして移動
ページ単位で過去に解析した履歴が表示される。

---

### アクセス単位の解析結果

解析リストからTimeをクリックして移動

THIS RUN
```
解析結果の要約
```

GET
```
GETで送信されたパラメータ一覧
```

SERVER
```
HTTPリクエスト情報
```

WATERFALL
```
ウォーターフォールへのリンク
```

Watch Functions
```
監視している関数の抽出リスト
```

Exclusive Wall Time
```
処理時間のTOP6をグラフで表示
```

Memory Hogs
```
メモリ使用量のTOP6をグラフで表示
```


Function
```
コールされた関数名
```

Call Count
```
コールされた回数
```

Exclusive Wall Time
```
この関数単体の処理時間
(この関数から呼び出された関数の処理時間を除外した処理時間)
```

Exclusive CPU
```
この関数単体のCPU処理時間
(この関数から呼び出された関数のCPU処理時間を除外したCPU処理時間)
```

Exclusive Memory Usage
```
この関数単体の呼び出された時のメモリ使用量(たぶん)
(この関数から呼び出された関数のメモリ使用量を除外したメモリ使用量)

```
Exclusive Peak Memory Usage
```
この関数単体の実行中のメモリ使用量のピーク(たぶん)
(この関数から呼び出された関数のメモリ使用量のピークを除外したメモリ使用量のピーク)
```

Inclusive Wall Time
```
この関数から呼び出された関数の処理時間も含むトータルの処理時間
```

Inclusive CPU
```
この関数から呼び出された関数のCPU処理時間も含むトータルのCPU処理時間
```

Inclusive Memory Usage
```
この関数から呼び出された関数のメモリ使用量も含む、関数呼び出し時のメモリ使用量(たぶん)
```

Inclusive Peak Memory Usage
```
この関数から呼び出された関数を含む関数の処理全体でのメモリ使用量のピーク
```


---

## xdebugの使い方

新開発環境ではxdebugを使用し、リモートデバッグが可能。

```
ポート：9001
```
