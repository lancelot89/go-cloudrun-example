## Go×GCP Cloud Run アプリ設計書

本ドキュメントは、Goで作成したHTTPアプリケーションをCloud Run上にデプロイし、Cloud BuildでCI/CDを実現するための設計書です。

---

### 1. システム構成概要

```
┌──────────────┐       Git Push       ┌──────────────┐
│ Developer PC │ ─────────────▶ │   GitHub Repo  │
└──────────────┘                    └──────────────┘
       ▲                                        │
       │                                        ▼
┌────────────────────────────────────────────────────┐
│                Cloud Build Trigger                 │
│ ──────────────────────────────────────────────── │
│   1. cloudbuild.yamlに従ってDockerビルド            │
│   2. Artifact RegistryにイメージPush               │
│   3. Cloud RunへDeploy                             │
└────────────────────────────────────────────────────┘
                                                 ▼
                                       ┌────────────────┐
                                       │  Cloud Run     │
                                       │  (https/API)   │
                                       └────────────────┘
```

---

### 2. 使用技術スタック

| 項目        | 使用技術 / サービス                  |
| --------- | ---------------------------- |
| 言語        | Go 1.21                      |
| サーバ       | net/http（標準ライブラリ）            |
| インフラ      | Google Cloud Platform        |
| 実行環境      | Cloud Run                    |
| CI/CD     | Cloud Build                  |
| コンテナレジストリ | Artifact Registry            |
| イベントトリガー  | GitHub連携のCloud Build Trigger |

---

### 3. Goアプリ設計

#### 3-1. 基本仕様

* `/` にアクセスすると `Hello, {TARGET}` を返す
* 環境変数 `TARGET` により表示名を切り替え可能
* ポート番号 `8080` 固定（Cloud Run要件）

#### 3-2. ファイル構成

```
go-cloudrun-example/
├── main.go
├── go.mod
├── Dockerfile
├── cloudbuild.yaml
├── .gcloudignore
├── README.md  ← 実行手順やCloud Runの概要を記述
└── .gitignore

```

#### 3-3. main.go

```go
func handler(w http.ResponseWriter, r *http.Request) {
    name := os.Getenv("TARGET")
    if name == "" {
        name = "World"
    }
    fmt.Fprintf(w, "Hello, %s!\n", name)
}
```

---

### 4. Cloud Build設計

#### 4-1. cloudbuild.yamlの構成

```yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', IMAGE_URI, '.']

  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', IMAGE_URI]

  - name: 'gcr.io/google.com/cloudsdktool/cloud-sdk'
    entrypoint: gcloud
    args:
      - run
      - deploy
      - SERVICE_NAME
      - --image
      - IMAGE_URI
      - --region
      - asia-northeast1
      - --platform
      - managed
      - --allow-unauthenticated
```

#### 4-2. ビルドトリガー設定

* イベント: Push to `main` branch
* ビルド構成: `cloudbuild.yaml`
* ソース: GitHub連携

---

### 5. セキュリティと権限

#### 5-1. Cloud Build用サービスアカウントに付与すべきロール

* `Cloud Run Admin`
* `Storage Admin`
* `Artifact Registry Writer`

#### 5-2. デプロイ対象のCloud Runには `--allow-unauthenticated` を設定

（ただし、社内API用途の場合はIAM制限推奨）

---

### 6. 今後の拡張（想定）

* FirestoreやCloud SQLとの連携
* Pub/Subで非同期ワークフロー構築
* Cloud Schedulerでの定期バッチ
* Cloud MonitoringとError Reporting導入

---

この設計に基づいてGitHubへコードを公開し、チーム開発や技術共有のベースとすることを推奨します。
