<div align="center">

# codename goose

</div>

## 環境構築

### 前提条件
- Docker
- Docker Compose
- Git
- SSHキー（GitHub等との連携に必要）

### セットアップ手順

1. リポジトリのクローン
```bash
git clone git@github.com:fuminopen/goose.git
cd goose
```

2. 環境変数の設定
必要な環境変数を`.env`ファイルに設定します：

```bash
# .env
ANTHROPIC_API_KEY=your_api_key
GOOSE_PROVIDER=your_provider
GOOSE_MODEL=your_model
GIT_AUTHOR_NAME=your_name
GIT_AUTHOR_EMAIL=your_email
```

3. Dockerイメージのビルド
```bash
docker-compose -f documentation/docs/docker/docker-compose.yml build
```

4. Dockerコンテナへの接続
```bash
docker-compose -f documentation/docs/docker/docker-compose.yml run --rm goose-cli
```

### 注意事項
- SSHキーはホストの`~/.ssh`ディレクトリがコンテナにマウントされます
- エディタはデフォルトでvimが設定されています

### トラブルシューティング
- SSHキーの問題が発生した場合は、ホストの`~/.ssh`ディレクトリの権限を確認してください
