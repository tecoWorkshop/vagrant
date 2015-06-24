# 新開発環境の使い方

## ローカル環境の設定

開発環境を使用するために必要なアプリをインストールする。

---

### VirtualBox

*ダウンロード*

[download](https://www.virtualbox.org/wiki/Downloads)

* VirtualBox 4.3.2 ※最新を選ぶ

*インストール*

インストール後にインストールしたディレクトリにPATHを通す。
デフォでは「C:\Program Files\Oracle\VirtualBox」にインストールされた。

1. 「田(windows key) + Pause 」でシステムを起動
1. 左の「システムの詳細設定」→「詳細設定」→「環境変数」
1. 「ユーザ環境変数」から「Path」を選択して「編集」
1. 「変数値」の値の最後に「;(上記インストールディレクトリ)」を追加

---

### Vagrant

*ダウンロード*

[download](http://downloads.vagrantup.com/)

* Vagrant_1.3.5.msi  ※最新を選ぶ
[20150624]  
Latest [vagrant_1.7.2](https://dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2.msi) だと、saharaプラグインのインストールでエラーになる。  
Old Version [vagrant_1.7.1](https://www.vagrantup.com/download-archive/v1.7.1.html) で、環境構築可能となる。

*インストール*

ダイアログに従ってインストールする。

*BOXの追加*

コマンドプロンプトにて作業

<code>
$ vagrant box add centos64 https://github.com/2creatives/vagrant-centos/releases/download/v0.1.0/centos64-x86_64-20131030.box
</code>

*saharaプラグインのインストール*

コマンドプロンプトにて作業

<code>
$ vagrant plugin install sahara
</code>

*Macはvagrant-triggersのプラグインもインストール*

<code>
$ vagrant plugin install vagrant-triggers
</code>


---

## 開発環境の構築

開発環境でTESTの動作が行えるようにようにする。

### 設定ファイルの準備

svnから「vagrant」ディレクトリをチェックアウトする。

現在のディレクトリ構成

<code>
/app
/framework
/library
</code>

チェックアウト後のディレクトリ構成

<code>
/app
/framework
/library
/vagrant
</code>

「vagrant」ディレクトリから「Vagrantfile.chef」と「Vagrantfile.win」もしくは「Vagrantfile.mac」を「Vagrantfile」としてコピーする

チェックアウト後のディレクトリ構成

<code>
/app
/framework
/library
/vagrant
Vagrantfile
Vagrantfile.chef
</code>

※最新のvagrantディレクトリを周りの人にもらいましょう！

### VMのプロビジョニング

vagrantコマンドは全てプロジェクトのディレクトリで行う。

*vagrantをsandboxモードにしてVMのロールバックをできるように*

コマンドプロンプトにて作業

<code>
$ cd <TESTのプロジェクトのディレクトリ>
$ vagrant up --no-provision  # 起動時にプロビジョニングされるのでしないように引数を渡す
$ vagrant sandbox on
</code>

*プロビジョニング*

コマンドプロンプトにて作業

<code>
$ vagrant provision
$ vagrant sandbox commit
$ vagrant sandbox off
</code>

### VMに接続

macとかだと vagrant sshでいけるけどwinだと無理なので下記の方法で接続する。
ログインして問題がないかチェック
<code>
ホスト：127.0.0.1
ポート：2222
ユーザ：vagrant
パスワード：vagrant
秘密鍵：(ユーザディレクトリ)/.vagrant.d/insecure_private_ke
</code>

http://localtest-hoge/ のような個人のホスト名でアクセスして動作できるかチェックする。
問題がなければコミットしてVMの状態を保存する。
※保存しないと前回のコミットまで戻るので注意

コマンドプロンプトにて作業

<code>
$ vagrant sandbox commit
</code>


### VMがうまく起動しない場合

VT-ｘが有効になっていないエラーが出る場合は、BIOSの設定でVT-x(Intel(R) Virtualization Technology)を
有効にしてください。
参考URL：http://futurismo.biz/archives/1647

timezoneがゴニョゴニョ言われる場合はvagrant/cookbooks/timezone/metadata.rbの中身に以下を追加
<code>
version          "0.0.2"
name             "timezone"　←ここを追加
</code>

### 韓国版について

日本版とは別に韓国版を作成する場合は
vagrantファイルのポート設定を変更する必要がある
たとえばこんな感じ
<code>
  config.vm.network :forwarded_port, guest: 80, host: 2223
  config.vm.network :forwarded_port, guest: 8080, host: 8081
</code>
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
<code>
[memcached]
servers.0.host = localhost
servers.0.port = 11211
servers.0.persistent = TRUE
</code>

### キャッシュの消し方

キャッシュすべて消えます。

<code>
$ sudo service memcached restart
</code>

### php-timecopの設定

vagrantファイルにtimecopのインストールが書かれていれば
以下の作業はいりません

上記で一通りの設定が終わったら
puttyなどでログインを行い、php-timecopのインストールを行います。
rootのパスワードはvagrantです

<code>
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
</code>

## vagrantの使い方

起動

<code>
$ vagrant up
</code>

終了

<code>
$ vagrant halt
</code>

ログイン

<code>
$ vagrant ssh
</code>

Vagrantfile作成

<code>
$ vagrant init
</code>

再起動(Vagrantfileリロード)

<code>
$ vagrant reload
</code>

sandoboxモード
offにすると前回のコミットまで戻り、sandoboxモードを抜ける。

<code>
$ vagrant sandbox on
$ vagrant sandbox off
</code>

sandbox状態確認

<code>
$ vagrant sandbox status
</code>

sandboxコミット

<code>
$ vagrant sandbox commit
</code>

sandboxロールバック

<code>
$ vagrant sandbox rollbak
</code>

---

## エラー対処

基本的に1度設定してしまえば2回目からはvagrant upをすれば起動するようになるが
まれに以下のようなエラーが出る場合がある
<code>
Bringing machine 'default' up with 'virtualbox' provider...
Your VM has become "inaccessible." Unfortunately, this is a critical error
with VirtualBox that Vagrant can not cleanly recover from. Please open VirtualBox
and clear out your inaccessible virtual machines or find a way to fix
them.
</code>
この場合は、virtual-boxが設定されているディレクトリ（\user\(ユーザー名)\VirtualBox VMs\(環境名)）に行き
(設定名).vbox-tmpファイルをリネームで(設定名).vboxに変更することで直った

---

## 開発環境の使い方

「localtest-hoge」は個人が開発環境で設定しているホスト名

*通常アクセス*

通常の開発環境にアクセスする。

<code>
http://localtest-hoge/
</code>

*プロファイリング*

開発環境にアクセスしプロファイリングをする。

<code>
http://localtest-hoge:8080/
</code>

*プロファイリング結果確認*

上記でプロファイリングを行った結果を解析する。
※初回のアクセス時はプロファイリングを行ったあとでなければ表示されないので注意。

<code>
http://localhost/xhgui/webroot/
</code>

---

## XHGuiの使い方

### メニュー

Recent
<code>
最近のアクセス順で表示する
</code>

Longest wall time
<code>
処理時間が長い順で表示する
</code>

Most CPU
<code>
CPUの処理時間が長い順で表示
</code>

Most memory
<code>
メモリ使用量が多い順で表示
</code>

Custom View
<code>
条件を指定して解析結果から検索
</code>

Watch Functions
<code>
監視する関数を指定する
設定された関数はアクセスの詳細にて抽出して表示される
</code>

Waterfall
<code>
条件で抽出し、アクセスをウォーターフォールで表示
</code>

---

### 解析リスト

URL

<code>
解析したURL
クリックするとページ単位の解析結果に移動
</code>


Time
<code>
解析した日時
クリックするとアクセス単位の解析結果に移動
</code>

wt
<code>
処理にかかった時間
</code>

cpu
<code>
CPUの処理にかかった時間
</code>

mu
<code>
処理が呼び出された時点でのメモリの使用容量(たぶん)
</code>

pmu
<code>
処理中のメモリ使用容量の最大値(たぶん)
</code>

---

### ページ単位の解析結果

解析リストからURLをクリックして移動
ページ単位で過去に解析した履歴が表示される。

---

### アクセス単位の解析結果

解析リストからTimeをクリックして移動

THIS RUN
<code>
解析結果の要約
</code>

GET
<code>
GETで送信されたパラメータ一覧
</code>

SERVER
<code>
HTTPリクエスト情報
</code>

WATERFALL
<code>
ウォーターフォールへのリンク
</code>

Watch Functions
<code>
監視している関数の抽出リスト
</code>

Exclusive Wall Time
<code>
処理時間のTOP6をグラフで表示
</code>

Memory Hogs
<code>
メモリ使用量のTOP6をグラフで表示
</code>


Function
<code>
コールされた関数名
</code>

Call Count
<code>
コールされた回数
</code>

Exclusive Wall Time
<code>
この関数単体の処理時間
(この関数から呼び出された関数の処理時間を除外した処理時間)
</code>

Exclusive CPU
<code>
この関数単体のCPU処理時間
(この関数から呼び出された関数のCPU処理時間を除外したCPU処理時間)
</code>

Exclusive Memory Usage
<code>
この関数単体の呼び出された時のメモリ使用量(たぶん)
(この関数から呼び出された関数のメモリ使用量を除外したメモリ使用量)

</code>
Exclusive Peak Memory Usage
<code>
この関数単体の実行中のメモリ使用量のピーク(たぶん)
(この関数から呼び出された関数のメモリ使用量のピークを除外したメモリ使用量のピーク)
</code>

Inclusive Wall Time
<code>
この関数から呼び出された関数の処理時間も含むトータルの処理時間
</code>

Inclusive CPU
<code>
この関数から呼び出された関数のCPU処理時間も含むトータルのCPU処理時間
</code>

Inclusive Memory Usage
<code>
この関数から呼び出された関数のメモリ使用量も含む、関数呼び出し時のメモリ使用量(たぶん)
</code>

Inclusive Peak Memory Usage
<code>
この関数から呼び出された関数を含む関数の処理全体でのメモリ使用量のピーク
</code>


---

## xdebugの使い方

新開発環境ではxdebugを使用し、リモートデバッグが可能。

<code>
ポート：9001
</code>
