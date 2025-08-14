# Postfix の設定

このドキュメントでは、特に Red Hat ベースの Linux システムにおける Postfix の設定ファイルと主要な設定の概要を説明します。

## 設定ファイル

Red Hat システムでは、Postfix の設定ファイルは `/etc/postfix` にあります。最も重要なファイルは次の2つです。

-   `main.cf`: Postfix のメイン設定ファイルです。メールシステムの動作を制御する数百のパラメータが含まれています。ほとんどの基本的な設定では、これらのうちのいくつかを変更するだけで済みます。
-   `master.cf`: `master` デーモンがさまざまな Postfix サービスをどのように実行するかを定義します。これを使用して、サービスの有効化/無効化、リソース制限の設定、chroot 環境の設定ができます。

`main.cf` または `master.cf` に変更を加えた場合、変更を有効にするには Postfix サービスをリロードする必要があります。

```bash
sudo postfix reload
```

## メイン設定 (`main.cf`)

`main.cf` の中で最も重要なパラメータのいくつかを紹介します。

### サーバーの識別情報

-   `myhostname`: メールサーバーの完全修飾ドメイン名（FQDN）です。
    ```
    myhostname = mail.example.com
    ```
-   `mydomain`: 組織のドメイン名です。設定されていない場合は、`myhostname` から派生します。
    ```
    mydomain = example.com
    ```
-   `myorigin`: 送信メールの `From:` ヘッダーに表示されるドメイン名です。一貫性を保つために、これはしばしば `$mydomain` に設定されます。
    ```
    myorigin = $mydomain
    ```

### メールの受信

-   `mydestination`: このサーバーがローカルでメールを受信するドメインのリストです。ドメインのプライマリメールサーバーである場合は、`$mydomain` を含める必要があります。
    ```
    mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain
    ```
-   `inet_interfaces`: Postfix が受信メールを待ち受けるネットワークインターフェースです。デフォルトは `all` です。
    ```
    inet_interfaces = all
    ```
-   `inet_protocols`: 使用するIPプロトコル（`ipv4`、`ipv6`、または `all`）です。
    ```
    inet_protocols = all
    ```

### メールの送信とリレー

-   `mynetworks`: このサーバーを介してメールをリレーすることが許可されている信頼できるIPアドレスまたはネットワークのリストです。これはローカルネットワークに制限する必要があります。
    ```
    # 例: localhost とローカルサブネットからのリレーを許可
    mynetworks = 127.0.0.0/8, 192.168.1.0/24
    ```
-   `relayhost`: すべての送信メールを直接配信する代わりに、経由させる外部SMTPサーバー（「スマートホスト」）です。ファイアウォールの内側にいる場合や、ISPがポート25をブロックしている場合に便利です。
    ```
    # 例: ISPのメールサーバーを使用
    relayhost = [smtp.isp.com]
    ```
-   `relay_domains`: 信頼できないクライアントからであっても、このサーバーがメールをリレーするドメインのリストです。デフォルトは `$mydestination` です。

### メールボックス設定

-   `home_mailbox`: ユーザーのホームディレクトリからの相対的なメールボックスの場所です。最も一般的な形式は `Maildir/` で、従来の `mbox` 形式よりも堅牢なディレクトリベースのメールボックスを作成します。
    ```
    home_mailbox = Maildir/
    ```
-   `mail_spool_directory`: `mbox` 形式のメールボックスを保存するディレクトリです。
    ```
    mail_spool_directory = /var/spool/mail
    ```

## その他の重要なファイルとテーブル

Postfix は、その動作を制御するためにさまざまなルックアップテーブルを使用します。これらは通常 `/etc/postfix` に保存され、`postmap` コマンドを使用してデータベース形式（`.db`）にコンパイルされます。

-   `/etc/aliases`: メールエイリアスを定義し、あるアドレスへのメールを別のアドレスにリダイレクトできるようにします。このファイルを編集した後、`newaliases` コマンドを実行する必要があります。
    ```
    # /etc/aliases
    postmaster: root
    root: your-email@example.com
    ```
-   **バーチャルドメイン**: `virtual_alias_maps` や `virtual_mailbox_maps` などのファイルは、単一のサーバーで複数のドメインをホストするために使用されます。
-   **アクセスコントロール**: `smtpd_recipient_restrictions` や `smtpd_client_restrictions` などのファイルは、テーブルを使用して、メールの受け入れまたは拒否に関する複雑なルールを定義できます。
