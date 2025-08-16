# Postfix メールログ (`/var/log/maillog`) の分析

このドキュメントでは、Postfix のメールログである `/var/log/maillog` の内容を理解し、メールの流れを追跡する方法について説明します。

## 1. ログエントリの一般的な構造

`/var/log/maillog` の各行は、通常以下の要素で構成されています。

`日付 時刻 ホスト名 デーモン名[プロセスID]: メッセージ`

例:
`Aug 15 08:00:00 mailserver postfix/smtpd[12345]: connect from unknown[192.168.1.100]`
`Aug 15 08:00:01 mailserver postfix/cleanup[12346]: 1A2B3C4D5E: message-id=<test@example.com>`
`Aug 15 08:00:02 mailserver postfix/qmgr[12347]: 1A2B3C4D5E: from=<sender@example.org>, size=1234, nrcpt=1 (queue active)`
`Aug 15 08:00:03 mailserver postfix/smtp[12348]: 1A2B3C4D5E: to=<recipient@example.com>, relay=mail.example.com[203.0.113.1]:25, delay=3, delays=0.01/0.01/0.01/2.97, dsn=2.0.0 (ok), status=sent (250 2.0.0 Ok: queued as 12345ABCDE)`

*   **日付**: ログが記録された月と日。
*   **時刻**: ログが記録された時刻 (HH:MM:SS)。
*   **ホスト名**: メールサーバーのホスト名。
*   **デーモン名[プロセスID]**: メッセージを出力した Postfix デーモンの名前と、そのデーモンのプロセスID。
*   **メッセージ**: デーモンが出力した具体的な情報。

## 2. 主要な Postfix デーモンとログメッセージの例

Postfix は複数の小さなデーモンが連携して動作します。それぞれのデーモンは、メール処理の特定の段階でログを出力します。

### `smtpd` (SMTP デーモン)

受信メールの入り口です。SMTP プロトコルを使用してネットワークからの接続を受け付けます。

*   **接続の確立**:
    `Aug 15 08:00:00 mailserver postfix/smtpd[12345]: connect from unknown[192.168.1.100]`
    (`192.168.1.100` からの接続を受け付けたことを示します。)
*   **クライアントの識別**:
    `Aug 15 08:00:00 mailserver postfix/smtpd[12345]: EHLO example.org`
    `Aug 15 08:00:00 mailserver postfix/smtpd[12345]: client=example.org[192.168.1.100]`
*   **送信者と受信者の指定**:
    `Aug 15 08:00:00 mailserver postfix/smtpd[12345]: sender=<sender@example.org>`
    `Aug 15 08:00:00 mailserver postfix/smtpd[12345]: recipient=<recipient@example.com>`
*   **メッセージの受け入れ**:
    `Aug 15 08:00:01 mailserver postfix/smtpd[12345]: 1A2B3C4D5E: client=example.org[192.168.1.100]`
    (メッセージが受け入れられ、キューID `1A2B3C4D5E` が割り当てられたことを示します。)

### `cleanup` (クリーンアップデーモン)

受信したメッセージを正規化し、不足しているヘッダーを追加し、最終的にキューに配置します。

*   **メッセージIDの割り当て**:
    `Aug 15 08:00:01 mailserver postfix/cleanup[12346]: 1A2B3C4D5E: message-id=<test@example.com>`
    (メッセージに `Message-ID` ヘッダーが追加されたことを示します。`1A2B3C4D5E` はキューIDです。)

### `qmgr` (キューマネージャー)

Postfix の配送の中心です。メッセージをキュー間で移動させ、適切な配送エージェントに渡します。

*   **キューへの投入**:
    `Aug 15 08:00:02 mailserver postfix/qmgr[12347]: 1A2B3C4D5E: from=<sender@example.org>, size=1234, nrcpt=1 (queue active)`
    (キューID `1A2B3C4D5E` のメッセージがアクティブキューに入り、送信者、サイズ、受信者数が示されます。)
*   **遅延メッセージの再試行**:
    `Aug 15 08:10:00 mailserver postfix/qmgr[12347]: 5F6G7H8I9J: from=<sender@example.org>, size=5678, nrcpt=1 (queue deferred)`
    (遅延キューにあるメッセージが再試行のためにアクティブキューに移動されたことを示します。)

### `smtp` (SMTP クライアントデーモン)

リモートのメールサーバーへメールを送信します。

*   **メールの送信**:
    `Aug 15 08:00:03 mailserver postfix/smtp[12348]: 1A2B3C4D5E: to=<recipient@example.com>, relay=mail.example.com[203.0.113.1]:25, delay=3, delays=0.01/0.01/0.01/2.97, dsn=2.0.0 (ok), status=sent (250 2.0.0 Ok: queued as 12345ABCDE)`
    (キューID `1A2B3C4D5E` のメッセージが `recipient@example.com` へ送信されたことを示します。`relay` は接続先のサーバー、`status=sent` は成功、括弧内はリモートサーバーからの応答です。)
*   **一時的な失敗 (deferred)**:
    `Aug 15 08:05:00 mailserver postfix/smtp[12349]: 5F6G7H8I9J: to=<recipient@example.com>, relay=mail.example.com[203.0.113.1]:25, delay=5, delays=0.01/0.01/0.01/4.97, dsn=4.0.0 (temporary failure), status=deferred (host mail.example.com[203.0.113.1] said: 450 4.7.1 Service unavailable - try again later (in reply to RCPT TO command))`
    (一時的な問題によりメッセージが遅延キューに移動されたことを示します。)
*   **恒久的な失敗 (bounced)**:
    `Aug 15 08:15:00 mailserver postfix/smtp[12350]: 9K0L1M2N3O: to=<unknown@example.com>, relay=mail.example.com[203.0.113.1]:25, delay=10, delays=0.01/0.01/0.01/9.97, dsn=5.1.1 (unknown user), status=bounced (host mail.example.com[203.0.113.1] said: 550 5.1.1 User unknown (in reply to RCPT TO command))`
    (恒久的な問題によりメッセージがバウンスされたことを示します。)

### `local` (ローカル配送デーモン)

ローカルユーザーのメールボックスにメールを配送します。

*   **ローカル配送**:
    `Aug 15 08:00:04 mailserver postfix/local[12351]: 1A2B3C4D5E: to=<localuser@mailserver.com>, relay=local, delay=4, delays=0.01/0.01/0.01/3.97, dsn=2.0.0 (delivered), status=sent (delivered to mailbox)`
    (ローカルユーザー `localuser` のメールボックスにメッセージが配送されたことを示します。)

### `bounce` / `defer` (バウンス/遅延通知デーモン)

不達通知（バウンスメール）や遅延メール通知を処理します。

*   **バウンス通知の生成**:
    `Aug 15 08:15:01 mailserver postfix/bounce[12352]: 9K0L1M2N3O: sender non-delivery notification: 9K0L1M2N3O`
    (キューID `9K0L1M2N3O` のメッセージに対する不達通知が生成されたことを示します。)

## 3. キューIDを使用したメールの追跡

Postfix のログを分析する上で最も重要なのは、各メールに割り当てられる**キューID**です。メールがシステムに入ってから出るまで、同じキューIDがログエントリ全体で一貫して使用されます。

特定のメールのライフサイクルを追跡するには、以下の手順を実行します。

1.  **最初のキューIDを見つける**:
    メールがシステムに入ったときのログエントリ（通常は `smtpd` または `pickup` デーモンによるもの）からキューIDを特定します。
    例: `Aug 15 08:00:01 mailserver postfix/smtpd[12345]: 1A2B3C4D5E: client=example.org[192.168.1.100]`
    この例では、キューIDは `1A2B3C4D5E` です。

2.  **キューIDでログを検索する**:
    特定したキューIDを使用して、`/var/log/maillog` 全体を検索します。これにより、そのメールに関連するすべてのログエントリを時系列で確認できます。

    ```bash
    grep "1A2B3C4D5E" /var/log/maillog
    ```

    このコマンドを実行すると、以下のような出力が得られ、メールがどのように処理されたかを確認できます。

    ```
    Aug 15 08:00:01 mailserver postfix/smtpd[12345]: 1A2B3C4D5E: client=example.org[192.168.1.100]
    Aug 15 08:00:01 mailserver postfix/cleanup[12346]: 1A2B3C4D5E: message-id=<test@example.com>
    Aug 15 08:00:02 mailserver postfix/qmgr[12347]: 1A2B3C4D5E: from=<sender@example.org>, size=1234, nrcpt=1 (queue active)
    Aug 15 08:00:03 mailserver postfix/smtp[12348]: 1A2B3C4D5E: to=<recipient@example.com>, relay=mail.example.com[203.0.113.1]:25, delay=3, delays=0.01/0.01/0.01/2.97, dsn=2.0.0 (ok), status=sent (250 2.0.0 Ok: queued as 12345ABCDE)
    Aug 15 08:00:03 mailserver postfix/qmgr[12347]: 1A2B3C4D5E: removed
    ```

    この追跡により、メールがどこで問題に遭遇したか（例: `smtpd` で拒否された、`qmgr` で遅延した、`smtp` でバウンスされたなど）を正確に特定できます。

## 4. その他のログメッセージ

上記以外にも、Postfix は様々な状況でログを出力します。

*   **設定のリロード**:
    `Aug 15 08:00:05 mailserver postfix/master[12300]: reload -- version 3.6.4, configuration /etc/postfix`
*   **サービス開始/停止**:
    `Aug 15 08:00:06 mailserver postfix/master[12300]: daemon started -- version 3.6.4, configuration /etc/postfix`
*   **警告/エラー**:
    `Aug 15 08:00:07 mailserver postfix/smtpd[12353]: warning: hostname example.com does not resolve to address 192.0.2.1`
    `Aug 15 08:00:08 mailserver postfix/master[12300]: fatal: parameter "myhostname": no local interface found`

これらのログメッセージは、Postfix の動作状況や発生している問題を理解する上で非常に役立ちます。
