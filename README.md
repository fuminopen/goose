<div align="center">

# codename goose

</div>

## 環境構築

### 前提条件
- Docker
- Docker Compose
- Git
- SSHキー（GitHub等との連携に必要）
- Make
- AWS CLI

### セットアップ手順

1. リポジトリのクローン
```bash
git clone git@github.com:fuminopen/goose.git
cd goose
```

2. 環境設定とビルド
```bash
make setup
```
このコマンドは以下の処理を実行します：
- `.env.example`から`.env`ファイルを作成
- Dockerイメージのビルド

3. 環境変数の設定
`.env`ファイルを編集して、必要な環境変数を設定します：
```bash
# .env
ANTHROPIC_API_KEY=your_api_key
GOOSE_PROVIDER=your_provider
GOOSE_MODEL=your_model
GIT_AUTHOR_NAME=your_name
GIT_AUTHOR_EMAIL=your_email
```

4. コンテナへの接続
```bash
make up
```

### 注意事項
- SSHキーはホストの`~/.ssh`ディレクトリがコンテナにマウントされます
- エディタはデフォルトでvimが設定されています

### トラブルシューティング
- SSHキーの問題が発生した場合は、ホストの`~/.ssh`ディレクトリの権限を確認してください
