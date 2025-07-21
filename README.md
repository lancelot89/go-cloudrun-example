# Go Cloud Run Example

このリポジリは、Go言語で作成したシンプルなWebアプリケーションを、Google Cloud Buildを使用してGoogle Cloud Runに自動でデプロイするためのサンプルプロジェクトです。

## 概要

- Goの `net/http` パッケージを使用したHTTPサーバーです。
- `/` にアクセスすると、`Hello, {TARGET}!` というメッセージを返します。
  - `TARGET` の値は環境変数 `TARGET` で変更可能です。指定がない場合は `World` になります。
- Cloud Build を利用して、GitHubリポジトリへのPushをトリガーに、自動でビルドとCloud Runへのデプロイが行われます。

## 技術スタック

| カテゴリ          | 使用技術 / サービス                  |
| ----------------- | ------------------------------------ |
| 言語              | Go                                   |
| Webフレームワーク | `net/http` (標準ライブラリ)          |
| クラウドプラットフォーム | Google Cloud Platform (GCP)          |
| 実行環境          | Cloud Run                            |
| CI/CD             | Cloud Build                          |
| コンテナレジストリ   | Artifact Registry                    |
| コンテナ化        | Docker                               |

## ローカルでの実行方法

### 1. Goで直接実行

```bash
# サーバーを起動
go run main.go

# 別のターミナルからアクセス
curl http://localhost:8080
# Hello, World!

# 環境変数を設定してアクセス
export TARGET="Gopher"
curl http://localhost:8080
# Hello, Gopher!
```

### 2. Dockerで実行

```bash
# Dockerイメージをビルド
docker build -t go-cloudrun-example .

# Dockerコンテナを起動
docker run -p 8080:8080 -e TARGET="Docker" --rm go-cloudrun-example

# 別のターミナルからアクセス
curl http://localhost:8080
# Hello, Docker!
```

## GCPへのデプロイ

このプロジェクトはCloud Buildを使って自動でデプロイされます。

### 前提条件

1.  GCPプロジェクトが作成済みであること。
2.  課金が有効になっていること。
3.  以下のAPIが有効になっていること。
    - Cloud Build API (`serviceusage.googleapis.com`)
    - Cloud Run Admin API (`run.googleapis.com`)
    - Artifact Registry API (`artifactregistry.googleapis.com`)
4.  `gcloud` CLIがインストールおよび認証済みであること。

### 自動デプロイ (CI/CD)

`cloudbuild.yaml` に定義された手順に従い、`main` ブランチにPushすると自動でデプロイが実行されます。

1.  **GitHubリポジトリをフォーク**
2.  **GCPでArtifact Registryリポジトリを作成**
    ```bash
    gcloud artifacts repositories create cloud-run-source-deploy \
        --repository-format=docker \
        --location=asia-northeast1 \
        --description="Docker repository for Cloud Run source deployments"
    ```
3.  **Cloud Build トリガーを作成**
    - GCPコンソールからCloud Buildのページに移動し、「トリガー」を選択します。
    - 「トリガーを作成」をクリックし、フォークしたGitHubリポジトリと連携します。
    - イベント: `ブランチにプッシュ`
    - ブランチ: `^main$`
    - ビルド構成: `Cloud Build 構成ファイル (yaml または json)`
    - 場所: `リポジトリ`
    - `cloudbuild.yaml` のパスを指定します。
4.  **Cloud Build サービスアカウントに権限を付与**
    - GCPのIAMページで、Cloud Buildのサービスアカウント (`[PROJECT_NUMBER]@cloudbuild.gserviceaccount.com`) に以下のロールを付与します。
      - `Cloud Run 管理者` (roles/run.admin)
      - `サービス アカウント ユーザー` (roles/iam.serviceAccountUser)
      - `Artifact Registry 書き込み` (roles/artifactregistry.writer)
5.  **コードをPush**
    - ローカルで変更をコミットし、GitHubリポジリにPushすると、Cloud Buildが実行され、Cloud Runにデプロイされます。

### 手動デプロイ

`gcloud` コマンドを使用して手動でデプロイすることも可能です。

```bash
# 環境変数を設定
export PROJECT_ID="YOUR_GCP_PROJECT_ID"
export REGION="asia-northeast1"
export SERVICE_NAME="go-cloudrun-example"

# Cloud Build を使ってビルドとデプロイを実行
gcloud builds submit --config cloudbuild.yaml .

# または、gcloud run deploy を直接使う場合
# gcloud run deploy ${SERVICE_NAME} \
#   --source . \
#   --platform managed \
#   --region ${REGION} \
#   --allow-unauthenticated
```

## ファイル構成

```
.
├── main.go          # Goアプリケーションのソースコード
├── go.mod           # Goモジュールの依存関係定義
├── Dockerfile       # コンテナイメージをビルドするための設定
├── cloudbuild.yaml  # Cloud BuildでのCI/CDパイプライン定義
├── .gcloudignore    # gcloudコマンドで無視するファイル/ディレクトリの指定
├── README.md        # このファイル
└── DESIGN.md        # アプリケーションの設計書
```