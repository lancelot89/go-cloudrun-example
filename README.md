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
この設定を行うことで、GitHubとGCPが連携し、ソースコードの変更をトリガーに自動でデプロイが実行されるようになります。

#### 1. GitHubとGCPの接続

Cloud BuildがGitHubリポジトリの変更を検知できるように、GCPプロジェクトとGitHubアカウントを接続します。

1.  **GCPコンソールでCloud Buildを開く**:
    - [Cloud Build のページ](https://console.cloud.google.com/cloud-build)に移動します。
2.  **「トリガー」タブを選択し、「リポジリを接続」をクリック**:
    - 初めて接続する場合、ここでGitHubアカウントとの連携を求められます。
    - 「ソースを選択」で `GitHub (Cloud Build GitHub App)` を選択し、認証を進めます。
    - GitHubの認証画面が表示されたら、連携を許可するリポジトリを選択します。このプロジェクトのリポジトリ（フォークしたもの）を選択してください。
3.  **リポジリを接続**:
    - 画面の指示に従い、選択したリポジトリをGCPプロジェクトに接続します。

#### 2. Artifact Registry リポジリの作成

ビルドしたコンテナイメージを保存するためのリポジトリをArtifact Registryに作成します。

```bash
gcloud artifacts repositories create cloud-run-source-deploy \
    --repository-format=docker \
    --location=asia-northeast1 \
    --description="Docker repository for Cloud Run source deployments"
```

#### 3. Cloud Build トリガーの作成

GitHubリポジトリへのPushをトリガーにしてCloud Buildを実行するための設定です。

1.  **Cloud Buildの「トリガー」ページで「トリガーを作成」をクリック**:
    - **名前**: 任意（例: `deploy-to-cloud-run`）
    - **イベント**: `ブランチにプッシュ`
    - **ソースリポジリ**: 先ほど接続したGitHubリポジトリを選択
    - **ブランチ**: `^main# Go Cloud Run Example

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

 （mainブランチへのPush時のみ実行）
    - **ビルド構成**: `Cloud Build 構成ファイル (yaml または json)`
    - **場所**: `リポジリ`
    - **Cloud Build構成ファイルの場所**: `/cloudbuild.yaml`
2.  **「作成」をクリックしてトリガーを保存します。**

#### 4. Cloud Build サービスアカウントへの権限付与

Cloud BuildがCloud RunへのデプロイやArtifact Registryへの書き込みを行えるように、必要なIAMロールを付与します。

1.  **GCPの[IAMページ](https://console.cloud.google.com/iam-admin/iam)に移動します。**
2.  **Cloud Buildのサービスアカウントを見つけます**:
    - プリンシパル: `[PROJECT_NUMBER]@cloudbuild.gserviceaccount.com`
3.  **以下のロールを付与します**:
    - `Cloud Run 管理者` (`roles/run.admin`): Cloud Runへのデプロイに必要
    - `サービス アカウント ユーザー` (`roles/iam.serviceAccountUser`): Cloud Runサービスにサービスアカウントを関連付けるために必要
    - `Artifact Registry 書き込み` (`roles/artifactregistry.writer`): Artifact RegistryへのコンテナイメージのPushに必要

#### 5. デプロイの実行

これで、ローカルで変更したコードをGitHubリポジリの`main`ブランチにPushすると、自動でCloud Buildが実行され、ビルドとCloud Runへのデプロイが行われます。

```bash
git push origin main
```

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