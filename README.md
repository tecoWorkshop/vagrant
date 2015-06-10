# Vagrant

https://www.vagrantup.com/

## Vagrant とは

様々な環境に移行可能な開発環境を簡単に構築、管理及び配布することができる開発環境作成ツール

仮想マシン（VM）を動作させる仮想化ソフト操作を請け負ってくれるラッパーツール
VM の構成内容を Vagrantfile というテキストファイルとしてコード化できる

## メリット

- VM の構成を Vagrantfile にコードとして記述できる
- 同一構成の VM を複数簡単に作成できる
- ローカルのマシン（Windows、Mac）でも本番マシン（Linux）と同じ構成で開発できる
- 「自分の環境では動くのに…」がなくなる
- 構築した環境の使い捨てができるので、構成のテストが簡単

## デメリット

- VM の削除が簡単なので、本番環境の運用には適さない

## VirtualBox のインストール

https://www.virtualbox.org/wiki/Downloads からダウンロード＆インストール

Mac の場合は
```
$ brew-cask install virtualbox
```
でも OK

※ Vagrant は、VirtualBox の他に、VMware や AWS 等の仮想マシンも操作できるが、VirtualBox 用のプロバイダがはじめからインストールされたいるため、VirtualBox を使用する

## Vagrantのインストール

http://www.vagrantup.com/downloads からダウンロード＆インストール

Mac の場合は
```
$ brew-cask install vagrant
```
でも OK


## 基本的な使い方

### Vagrantfile を作成する

a. 新規で Vagrantfile を作成し、以下を記述する
```
Vagrant.configure("2") do |config|
  config.vm.box = “<box name>"
end
```

b. vagrant init コマンドで Vagrantfile のスケルトンを作成
```
$ vagrant init [box name]
```

### box の追加

atlas に公開されている box イメージは Vagrantfile に記述するだけで自動的にダウンロードされる

その他のイメージ（独自イメージ等）は以下のコマンドで、ローカルに登録する
```
$ vagrant box add <box name> <URL or path>
```

### VM の起動
```
$ vagrant up
```
※ ローカルに box イメージがない場合は自動的に atlas からダウンロードされる

### VM にログイン
```
$ vagrant ssh
```
※ vagrant ユーザでログインできる （パスワードは vagrant ）

### box を作成
```
$ vagrant package
```
VirtualBox 環境上で実行中のイメージから box を作成

※ 現バージョンでは VirtualBox のみをサポート


### 終了

仮想マシンを停止する場合
```
$ vagrant halt
```

仮想マシンを一時停止する場合
```
$ vagrant suspend
```

### 仮想マシン破棄
```
$ vagrant destroy
```

## Vagrantfile の書き方
Ruby で記述

```
Vagrant.configure(2) do |config|
  # ...
end
```
のブロック内に各設定を記述する  
"2" は設定オブジェクトのバージョンで、Vagrant 1.1+ では "2" を使用

### Vagrant のバージョン指定
```
Vagrant.require_version ">= 1.3.5"

Vagrant.require_version ">= 1.3.5", "< 1.4.0"
```

### 仮想マシンの設定

namespace: `config.vm`

`config.vm.box`:  
起動するマシン名  
インストールされている box か、Atlas 上にある box の名前を設定

`config.vm.box_url`:   
box がある URL を指定  
インストールされている box か、Atlas 上にある box の場合は不要

`config.vm.box_version`:   
box のバージョンを指定  
デフォルトは `">= 0"` で、最新バージョンを使用する

`config.vm.boot_timeout`:  
仮想マシンが起動するまでのタイムアウトを設定   
デフォルトは 300 秒

`config.vm.box_check_update`:  
`vagrant up` を実行するたびに box のアップデートを確認する  
デフォルトは "true"

`config.vm.graceful_halt_timeout`:   
`vagrant halt` 実行時に正常終了するまでのタイムアウトを設定  
デフォルトは 60 秒

`config.vm.network`:   
仮想マシンのネットワークを設定

`config.vm.provision`:  
仮想マシンのプロビジョニングを設定  
仮想マシン作成時にソフトウェアのインストールと設定を行う

`config.vm.synced_folder`:  
ホストマシンとゲストマシンの同期ディレクトリの設定を行う

`config.vm.provider`:  
プロバイダ固有の設定を行う

### SSH の設定

namespace: `config.ssh`

`config.ssh.username`:   
SSH のデフォルトユーザ名を設定  
デフォルトでは "vagrant"

`config.ssh.password`:   
SSH ユーザのパスワードを記述   
ただし Vagrant ではキーによる認証の方が推奨されている  
`insert_key` が "true" の場合、Vagrant は自動でキーペアを挿入する

`config.ssh.host`:   
SSH 接続先のホスト名または IP   
デフォルトでは指定する必要はない

`config.ssh.port`:   
SSH 接続先のポート番号  
デフォルトは 22

`config.ssh.private_key_path`:   
プライベートキーのパス  
公開されている box を使用する場合、デフォルトのキーは安全とはいえない

`config.ssh.insert_key`:   
自動でキーペア（安全ではない）を挿入   
デフォルトは "true"

## 同期ディレクトリ
Vagrant  ではホストマシンのディレクトリをゲストマシンと同期することができる

デフォルトでは、Vagrantfile のあるプロジェクトディレクトリがゲストマシンの `/vagrant` と同期される

### 基本的な使い方
#### 設定
```
Vagrant.configure("2") do |config|
	# ...

	config.vm.synced_folder "<host dir>", "<guest dir>"
end
```

host dir
: ホストマシンのディレクトリ
  相対パスの場合はプロジェクトルートからのパスとなる

guest dir
: ゲストマシンのディレクトリ（絶対パス）
  ディレクトリが存在しない場合は自動で作成される

#### オプション

`create` (boolean)
: "true" の場合、ホストのディレクトリを自動で作成する
デフォルトは "false"

`disabled` (boolead)
: "true" にした場合同期ディレクトリを無効にする

`group` (string)
: 同期ディレクトリのグループを設定する
デフォルトでは SSH のユーザとなる

`owner` (string)
: 同期ディレクトリのオーナーを設定する
デフォルトでは SSH のユーザとなる

`mount_options` (array)
: `mount` コマンドに渡されるオプション

`type` (string)
: 同期ディレクトリのタイプを設定する


### NFS
Network File System の仕組みを利用してディレクトリを同期する  

VirtualBox よりもパフォーマンス面で有利  

Mac/Linux 限定  
Windows の場合、設定しても無視されてデフォルトの設定が適用される

#### 前提条件
ホストマシンには `nfsd` がインストールされていて、 NFS サーバデーモンが動作している必要がある  
通常は、Mac も Linux も初期状態でインストールされている

また、ゲストマシンも NFS をサポートしている必要がある  

VirtualBox プロバイダーを使用する場合は、 private network の設定を行っている必要がある

#### 有効化

```
Vagrant.configure("2") do |config|
	# ...

	config.vm.synced_folder ".", "/vagrant", type: "nfs"
end
```

#### NFS オプション
NFS 特有のオプションは `config.vm.synced_folder` のパートに記述する

`nfs_export` (boolean)
: "false" にすると、自動で `/etc/exports` に設定を書き込まない

`nfs_udp` (boolean)
: "true" にすると UDP を使用して通信する

`nfs_version` (string | integer)
: NFS プロトコルのバージョンを指定する
デフォルトは 3


### RSync
`rsync` を利用してディレクトリの同期を行う

デフォルトでは、 `vagrant up` と `vagrant reload` 実行時、または、 `vagant rsync` コマンド実行時に同期する

`vagrant rsync-auto` コマンドを実行すると、ファイルに変更があった時に自動で同期する

#### 前提条件
ホストマシンに `rsync` または `rsync.exe` にパスが通っている必要がある  
Windows の場合は、 Cygwin か MinGW での導入が推奨されている

ゲストマシンにも `rsync` は必要であるが、普通 Vagrant が自動でインストールしてくれる

#### オプション
`rsync__args` (array of strings)
: `rsync` コマンドに渡す引数
デフォルトは、 `["--verbose", "--archive", "--delete", "-z", "--copy-links"]`

`rsync__auto` (boolean)
: "false" にすると `rsync-auto` の監視対象から除外される
デフォルトは "true"

`rsync__chown` (boolean)
: "false" にすると、同期ディレクトリに対する `owner` と `group` オプションは無視され、 Vagrant は同期時に `chown -R` を実行しない
デフォルトは "true"

`rsync__exclude` (string or array of strings)
: 除外するファイルまたはディレクトリのリスト
デフォルトで ".vagrant" ディレクトリは除外される
".git" などのバージョン管理ディレクトリも除外することが推奨される

#### 例
```
Vagrant.configure("2") do |config|
	config.vm.synced_folder ".", "/vagrant", type: "rsync", rsync__exclude: ".git/"
end
```

#### 制限のあるディレクトへの同期
`vagrant` ユーザが権限を持っていないディレクトリへ同期したい場合は、`"--rsync-path='sudo rsync'"` を使うことで、ゲストマシン上で sudo 実行できる

```
Vagrant.configure("2") do |config|
	config.vm.synced_folder "bin", "/usr/local/bin", type: "rsync", rsync__exclude: ".git/", rsync__args: ["--verbose", "--rsync-path='sudo rsync'", "--archive", "--delete", "-z"]
end
```

### SMB
SMB を利用してゲストマシンとホストマシン間のファイルの共有が出来る

SMB は Windows に組み込まれており、 VirtualBox 共有フォルダよりも良いパフォーマンスが期待できる

ゲストマシン側は Linux でもよい

#### 前提条件
Vagrant が Windows 上で動作している必要がある

また、共有ネットワークフォルダを作成するために、 Vagrant が管理者権限で実行されている必要がある

ゲストマシンが Linux の場合、 SMB ファイルシステムをマウントするために、`smbfs` または `cifs` が必要であるが、普通 Vagrant によって自動でインストールされる

#### オプション
`smb_host` (string)
: マウントしたいホストの IP アドレス
デフォルトでは Vagrant によって自動で設定される

`smb_username` (string)
: マウントの認証に使用するユーザ名
設定しない場合は起動時に入力する

`smb_password` (string)
: マウントの認証に使用するパスワード
設定しない場合は起動時に入力する

#### 例
```
Vagrant.configure("2") do |config|
	config.vm.synced_folder ".", "/vagrant", type: "smb"
end
```

### VirtualBox
プロバイダを VirtualBox にしている場合デフォルトで設定される

VirtualBox 共有フォルダシステムを利用して双方向にファイルの変更を同期する

#### 注意事項
`sendfile` に関連する VirtualBox のバグで、ファイルが破損したり更新できない場合がある  
Web サーバの設定で `sendfile` を無効にする必要がある

Nginx
: 
```
sendfile off;
```

Apache
: 
```
EnableSendfile off 
```

## ネットワーク

### 基本的な使い方
#### 設定
Vagrantfile で `config.vm.network` メソッドをコールして設定を行う
```
Vagrant.configure("2") do |config|
	# other config here

	config.vm.network "forwarded_port", guest: 80, host: 8080
end
```
それぞれのネットワークタイプには `:forwarded_port` のような識別子がある  
それぞれの識別子のあとに続くパラメータによって設定を行う

#### 複数ネットワーク
Vagrantfile 内で `config.vm.network` を複数コールすることで、ネットワークの設定を複数行うことが出来る

#### 設定の有効化
`vagrant up` または `vagrant reload` 実行時に設定が反映される

### ポートフォワーディング
ネットワーク識別子: `forwarded_port`

#### 例
```
Vagrant.configure("2") do |config|
	config.vm.network "forwarded_port", guest: 80, host: 8080
end
```
ホストの 8080 番ポートを通してゲストの 80 番ポートにアクセスする

#### オプション
`guest` (int) 必須
: ゲストマシン上のホストに対して開けたいポート番号  
任意のポートを指定できる

`guest_ip` (string)
: forwarded port にバインドさせたいゲストの IP アドレス  
指定しない場合、ポートは全ての IP に対して有効になる  
デフォルトは空

`host` (int) 必須
: ゲストのポートにアクセスさせたいホストマシン上のポート番号  
Vagrant が root 権限で実行（非推奨）されていない場合、 1024 より大きい番号を指定する必要がある

`host_ip` (string)
: forwarded port にバインドさせたいホストの IP アドレス  
指定しない場合、ポートは全ての IP に対して有効になる  
デフォルトは空

`protcol` (string)
: forwarded port に対して許可するプロトコルを "tcp" か "udp" で指定する  
デフォルトは "tcp"

#### Forwarded Port プロトコル
同じポートで両方のプロトコルを待ち受けたい場合、以下のように設定する
```
Vagrant.configure("2") do |config|
	config.vm.network "forwarded_port", guest: 2003, host: 12003, protocol: 'tcp'
	config.vm.network "forwarded_port", guest: 2003, host: 12003, protocol: 'udp'
end
```

### プライベートネットワーク
ネットワーク識別子: `private_network`

プライベートネットワーク設定を行うことで、プライベートネットワーク内でゲストマシンへアクセスすることができる

普通、プライベートアドレス空間内のアドレスが割り振られる

同じプライベートネットワーク内のマシン同士で通信できるようになる

#### DHCP
DHCP を指定することで自動的に IP が割り振られる

```
Vagrant.configure("2") do |config|
	config.vm.network "private_network", type: "dhcp"
end
```

割り振られた IP は、 `vagrant ssh` でゲストマシンに入って、 `ifconfig` などのコマンドで確認できる

#### Static IP
以下の設定で静的な IP を設定することができる

```
Vagrant.configure("2") do |config|
	config.vm.network "private_network", ip: "192.168.50.4"
end
```

同じネットワーク内で IP が衝突しないように気をつける必要がある

プライベートアドレス空間内のアドレスを設定することが推奨される

#### 自動設定の無効化
Vagrant による自動設定を無効化することで、ネットワークインターフェースを手動で設定することができる

```
Vagrant.configure("2") do |config|
	config.vm.network "private_network", ip: "192.168.50.4", auto_config: false
end
```

### パブリックネットワーク
ネットワーク識別子: `public_network`

パブリックネットワーク設定を行うことで、パブリックからのアクセスを許可することができる

※ Vagrant box はデフォルトのままではパスワードや SSH キーペアなどに対して、セキュアではない  
パブリックネットワークを設定する場合には、セキュリティに関して設定をよくレビューする必要がある

#### DHCP
デフォルトの場合 DHCP を利用して IP が割り振られる

```
Vagrant.configure("2") do |config|
	config.vm.network "public_network"
end
```

割り振られた IP は、 `vagrant ssh` でゲストマシンに入って、 `ifconfig` などのコマンドで確認できる

#### Static IP
手動で IP を設定することもできる

```
Vagrant.configure("2") do |config|
	config.vm.network "public_network", ip: "192.168.0.17"
end
```

## プロビジョニング
プロビジョニングの設定を行うことで、ソフトウェアのインストールなど、 `vagrant up` のプロセス内で行うこと以上のことができる

`vagarnt ssh` でゲストマシンにログインして手動でソフトをインストールすることもできるが、プロビジョニング機能を使用することで、トライアンドエラーでの環境構築が簡単になる

```
T.B.D.
```

## Guest Additions

### VirtualBox Guest Additions とは
VirtualBox Guest Additions とは、 VirtualBox 上に作成したゲストマシンにインストールするソフトウェア

ホストマシンとゲストマシン間の操作を便利にしてくれる機能が含まれる

VirtualBox Guest Additions をゲスト OS にインストールすると、以下のような事が可能になる
* クリップボードの共有
* フォルダの共有
* 自動ログイン
* ホストマシンとの時刻同期

### Guest Additions の更新
Box にインストール済みの Guest Additions のバージョンと VirtualBox が対応していない場合、 Guest Additions を更新する必要がある

#### vagrant-vbguest プラグイン
vagrant-vbguest プラグインは、利用している VirtualBox のバージョンとゲストマシンにインストールされている Guest Additions のバージョンを調べて、 Guest Additions のバージョンが古ければアップデートしてくれる

#### 更新
vagrant-vbguest のインストール
```
$ vagrant plugin install vagrant-vbguest
```

Guest Additions のアップデート
```
$ vagrant vbguest
```

## プラグイン
インストール
```
$ vagrant plugin install <plugin>
```
更新
```
$ vagrant plugin update [plugin]
```
アンインストール
```
$ vagrant plugin uninstall <plugin>
```
一覧
```
$ vagrant plugin list
```

### vagrant-vbox-snapshot
仮想マシンのスナップショットをとってくれるプラグイン
```
# スナップショットをとる
$ vagrant snapshot take <NAME>

# 直前のスナップショットの復元
$ vagrant snapshot back

# 任意のスナップショットの復元
$ vagrant snapshot go <NAME>

# スナップショットの削除
$ vagrant snapshot delete <NAME>

# スナップショットの一覧表示
$ vagrant snapshot list
```

### vagrant-aws
https://github.com/mitchellh/vagrant-aws

プロバイダとして Amazon EC2 をサポート

Vagrant 組み込みのプロビジョニング機能でインスタンスの構成管理が可能

`rsync` による最低限の同期ディレクトリをサポート

```
$ vagrant plugin install vagrant-aws
...
$ vagrant up --provider=aws
...
```


