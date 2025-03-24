# AWS ECSへのデプロイ手順

## 前提条件
- AWS CLIがインストールされていること
- Dockerがインストールされていること
- AWSアカウントの認証情報が設定されていること

## 環境変数の設定
```bash
# AWSアカウントIDの取得
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION="ap-northeast-1"
```

## デプロイ手順

### 1. ECRリポジトリの作成
```bash
aws ecr create-repository --repository-name goose-cli
```

### 2. ECSクラスターの作成
```bash
aws ecs create-cluster --cluster-name goose-cluster
```

### 3. タスク実行ロールの作成
```bash
# ロールの作成
aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document file://task-execution-assume-role.json

# 必要なポリシーのアタッチ
aws iam attach-role-policy \
    --role-name ecsTaskExecutionRole \
    --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
```

### 4. Dockerイメージのビルドとプッシュ
```bash
# ECRにログイン
aws ecr get-login-password --region ${AWS_REGION} | \
docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# イメージのビルド
docker build -t goose-cli -f documentation/docs/docker/Dockerfile .

# タグ付け
docker tag goose-cli:latest ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/goose-cli:latest

# プッシュ
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/goose-cli:latest
```

### 5. 環境変数の設定
AWS Systems Manager Parameter Storeに環境変数を保存：
```bash
# 環境変数の保存
aws ssm put-parameter --name "/goose/ANTHROPIC_API_KEY" --type "SecureString" --value "your_api_key"
aws ssm put-parameter --name "/goose/GOOSE_PROVIDER" --type "String" --value "anthropic"
aws ssm put-parameter --name "/goose/GOOSE_MODEL" --type "String" --value "claude-3-5-sonnet"
aws ssm put-parameter --name "/goose/GIT_AUTHOR_NAME" --type "String" --value "your_name"
aws ssm put-parameter --name "/goose/GIT_AUTHOR_EMAIL" --type "String" --value "your_email"
```

### 6. CloudWatchロググループの作成
```bash
aws logs create-log-group --log-group-name /ecs/goose-cli
```

### 7. タスク定義の登録
```bash
# タスク定義の登録
aws ecs register-task-definition --cli-input-json file://task-definition.json
```

### 8. セキュリティグループの作成と設定
```bash
# セキュリティグループの作成
aws ec2 create-security-group --group-name goose-cli-sg --description "Security group for goose-cli"

# 必要なインバウンドルールの追加（特定のIPからのみアクセスを許可）
aws ec2 authorize-security-group-ingress \
    --group-id ${SECURITY_GROUP_ID} \
    --protocol tcp \
    --port 22 \
    --cidr ${YOUR_IP}/32
```

### 9. サービスの作成
```bash
# VPCとサブネットの確認
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,Tags[?Key==`Name`].Value|[0]]' --output table
aws ec2 describe-subnets --filters "Name=vpc-id,Values=${VPC_ID}" --query 'Subnets[*].[SubnetId,AvailabilityZone]' --output table

# サービスの作成
aws ecs create-service \
    --cluster goose-cluster \
    --service-name goose-cli \
    --task-definition goose-cli \
    --desired-count 1 \
    --launch-type FARGATE \
    --network-configuration "awsvpcConfiguration={subnets=[${SUBNET_ID}],securityGroups=[${SECURITY_GROUP_ID}],assignPublicIp=ENABLED}"
```

## 注意事項
- セキュリティグループの設定は、必要最小限のポートのみを開放してください
- 環境変数は適切に管理し、機密情報はSecureStringとして保存してください
- コストを考慮して、不要なリソースは削除してください

## トラブルシューティング
- タスクが起動しない場合は、CloudWatchログを確認してください
- セキュリティグループの設定が正しいか確認してください
- タスク実行ロールに必要な権限が付与されているか確認してください