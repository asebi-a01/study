# Postfix コマンド

このドキュメントでは、Postfix メールサーバーの管理に使用される最も一般的なコマンドラインツールについて説明します。

## サービス管理 (`postfix`)

`postfix` コマンドは、メールシステムを制御するための主要なインターフェースです。`sudo` 権限で実行する必要があります。

-   **Postfix サービスを開始する:**
    ```bash
    sudo postfix start
    ```

-   **Postfix サービスを停止する:**
    ```bash
    sudo postfix stop
    ```

-   **設定をリロードする:**
    このコマンドは、サービスを停止せずに `main.cf` と `master.cf` ファイルを再読み込みします。これは設定変更を適用する推奨される方法です。
    ```bash
    sudo postfix reload
    ```

-   **Postfix の設定を確認する:**
    このコマンドは、設定ファイルの構文エラーをチェックし、ファイルのパーミッションや所有権の不一致を報告します。
    ```bash
    sudo postfix check
    ```

-   **Postfix サービスの状態を表示する:**
    ```bash
    sudo postfix status
    ```

-   **メールキューをフラッシュする:**
    現在キューにあるすべてのメールの配信を強制的に試みます。
    ```bash
    sudo postfix flush
    ```

## キュー管理

これらのコマンドは、Postfix のメールキューを表示および管理するために使用されます。

-   **`postqueue`**: キュー操作のメインコマンドです。
    -   **メールキューを一覧表示する:**
        ```bash
        postqueue -p
        ```
    -   **キューをフラッシュする (`postfix flush` と同じ):**
        ```bash
        postqueue -f
        ```
    -   **特定のサイトのメールをフラッシュする:**
        ```bash
        postqueue -s example.com
        ```
    -   **特定のメッセージの配信を再試行する:**
        ```bash
        postqueue -i QUEUE_ID
        ```

-   **`mailq`**: `postqueue -p` と同等の互換コマンドです。Sendmail に慣れているユーザーにおなじみのインターフェースを提供します。
    ```bash
    mailq
    ```

-   **`postsuper`**: キューの管理タスクに使用されます。
    -   **キューから単一のメッセージを削除する:**
        ```bash
        sudo postsuper -d QUEUE_ID
        ```
    -   **キューからすべてのメッセージを削除する (注意して使用してください!):**
        ```bash
        sudo postsuper -d ALL
        ```
    -   **すべての遅延メッセージを削除する:**
        ```bash
        sudo postsuper -d ALL deferred
        ```
    -   **メッセージを再キューイングする:**
        メッセージを `maildrop` キューに戻して再処理します。
        ```bash
        sudo postsuper -r QUEUE_ID
        ```
    -   **メッセージを「保留」にして配信試行を防ぐ:**
        ```bash
        sudo postsuper -h QUEUE_ID
        ```
    -   **「保留」されていたメッセージを解放する:**
        ```bash
        sudo postsuper -H QUEUE_ID
        ```

## 設定管理 (`postconf`)

`postconf` コマンドは、Postfix の設定パラメータを表示および編集するために使用されます。

-   **特定のパラメータの値を表示する:**
    ```bash
    postconf myhostname
    ```

-   **デフォルト以外のすべての設定を表示する:**
    ```bash
    postconf -n
    ```

-   **すべてのデフォルト設定を表示する:**
    ```bash
    postconf -d
    ```

-   **`main.cf` のパラメータを編集する:**
    ```bash
    sudo postconf -e "relayhost = [smtp.example.com]"
    ```

## ルックアップテーブル管理

-   **`postmap`**: Postfix のルックアップテーブル（例：`transport`, `virtual`）を作成またはクエリします。
    -   **テキストファイルからデータベースファイルを作成する:**
        ```bash
        sudo postmap /etc/postfix/transport
        ```
        これにより `/etc/postfix/transport.db` が作成されます。
    -   **テーブルをクエリする:**
        ```bash
        postmap -q "user@example.com" /etc/postfix/virtual
        ```

-   **`postalias`**: エイリアスデータベースを維持します。
    -   **`/etc/aliases` からエイリアスデータベースを再構築する:**
        ```bash
        sudo postalias /etc/aliases
        ```

-   **`newaliases`**: `postalias /etc/aliases` を実行する互換コマンドです。これは `/etc/aliases` ファイルを編集した後に実行する標準的なコマンドです。
    ```bash
    sudo newaliases
    ```

## その他のユーティリティ

-   **`postcat`**: メッセージヘッダーと本文を含むキューファイルの内容を表示します。
    ```bash
    sudo postcat -q QUEUE_ID
    ```

-   **`postdrop`**: `sendmail` がメールを `maildrop` キューにドロップするために使用するメール投稿ユーティリティです。通常、管理者によって直接使用されることはありません。
