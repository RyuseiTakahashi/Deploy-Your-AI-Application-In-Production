# Deploy Your AI Application In Production - デプロイされるAzureリソース完全一覧

このドキュメントでは、`azd up` を実行した際にデプロイされる**すべてのAzureリソース**を詳細に説明します。

---

## 📊 リソース概要

### デプロイされるリソース総数

| カテゴリ | リソース数 | デフォルト状態 |
|---------|-----------|---------------|
| **セキュリティ & ガバナンス** | 3 | ✅ 有効 |
| **ネットワークセキュリティグループ (NSG)** | 8 | ✅ 有効 |
| **ネットワークインフラ** | 18 | ✅ 有効 |
| **プライベートエンドポイント** | 8+ | ✅ 有効 |
| **監視 & ログ** | 2 | ✅ 有効 |
| **コンテナプラットフォーム** | 3+ | ✅ 有効 |
| **ストレージ & データ** | 3 | ✅ 有効 |
| **シークレット管理** | 1 | ✅ 有効 |
| **AI & 検索サービス** | 8 | ✅ 有効 |
| **API管理** | 1 | ❌ 無効 |
| **ゲートウェイ & ファイアウォール** | 4 | 一部有効 |
| **仮想マシン** | 9 | ✅ 有効 |
| **Microsoft Fabric** | 1 | ✅ 有効 |
| **RBAC (ロール割り当て)** | 20-50+ | 自動生成 |
| **ポストプロビジョン (Fabric/Purview)** | 7 | ✅ 有効 |
| **合計** | **77-107リソース** | - |

---

## 🔐 セキュリティ & ガバナンスレイヤー

### 1. Microsoft Defender for AI

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Security/pricings` |
| **SKU/Tier** | Standard |
| **目的** | AIワークロードの脅威保護 (Defender for Cloudの一部) |
| **用途** | - AIモデルへの攻撃検出<br>- 異常なAPI呼び出しの監視<br>- セキュリティアラート生成 |
| **依存関係** | なし |
| **デフォルト** | ✅ 有効 (`enableDefenderForAI: true`) |
| **月額コスト目安** | 無料 (一部機能) ~ $15/リソース |

### 2. Microsoft Defender for Storage

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Security/pricings` |
| **SKU/Tier** | Standard |
| **目的** | ストレージアカウントの脅威保護 |
| **用途** | - マルウェアアップロード検出<br>- 異常なアクセスパターン監視<br>- データ漏洩防止 |
| **依存関係** | Defender for AI有効時 |
| **デフォルト** | ✅ 有効 |
| **月額コスト目安** | $10-15/ストレージアカウント |

### 3. Microsoft Defender for Key Vault

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Security/pricings` |
| **SKU/Tier** | Standard |
| **目的** | Key Vaultの脅威保護 |
| **用途** | - 異常なシークレットアクセス検出<br>- 資格情報盗難の防止<br>- コンプライアンス監視 |
| **依存関係** | Key Vault |
| **デフォルト** | ✅ 有効 |
| **月額コスト目安** | $5/Key Vault |

---

## 🛡️ ネットワークセキュリティグループ (NSG)

### NSG一覧

| # | NSG名 | 対象サブネット | 目的 | デフォルト |
|---|-------|---------------|------|-----------|
| 4 | **Agent Subnet NSG** | AI Agentサブネット | AI Foundry Agent Serviceのトラフィック制御 | ✅ 有効 |
| 5 | **Private Endpoint Subnet NSG** | プライベートエンドポイントサブネット | PaaSサービスへのプライベート接続制御 | ✅ 有効 |
| 6 | **Application Gateway Subnet NSG** | Application Gatewayサブネット | L7ロードバランサーのトラフィック制御 | ✅ 有効 |
| 7 | **API Management Subnet NSG** | API Managementサブネット | APIゲートウェイのトラフィック制御 | ❌ 無効 |
| 8 | **Container Apps Environment Subnet NSG** | Container Appsサブネット | コンテナアプリのトラフィック制御 | ✅ 有効 |
| 9 | **Jumpbox Subnet NSG** | Jumpboxサブネット | 管理用VMのトラフィック制御 | ✅ 有効 |
| 10 | **DevOps Build Agents Subnet NSG** | Build VMサブネット | CI/CDエージェントのトラフィック制御 | ✅ 有効 |
| 11 | **Azure Bastion Subnet NSG** | Bastionサブネット | Bastion専用のトラフィック制御 | ✅ 有効 |

**リソースタイプ**: `Microsoft.Network/networkSecurityGroups`

**主な機能**:
- インバウンド/アウトバウンドトラフィックフィルタリング
- サービスタグベースのルール (AzureCloud, Storage, KeyVault など)
- ポートレベルのアクセス制御
- ログ記録とフロー分析

**月額コスト**: 無料（NSG自体）、フローログ有効時は別途課金

---

## 🌐 ネットワークインフラストラクチャ

### 12. Virtual Network (VNet)

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Network/virtualNetworks` |
| **SKU/Tier** | Standard |
| **アドレス空間** | カスタマイズ可能 (デフォルト: AI Landing Zoneの標準) |
| **サブネット** | 8-12サブネット |
| **目的** | 全リソースのプライベートネットワーク分離 |
| **用途** | - プライベートエンドポイント接続<br>- サブネット分離<br>- ネットワークセキュリティポリシー適用 |
| **主要サブネット** | - `pe-subnet` (プライベートエンドポイント)<br>- `jumpbox-subnet` (管理VM)<br>- `agent-subnet` (AI Agent Service)<br>- `bastion-subnet` (Azure Bastion)<br>- `appgw-subnet` (Application Gateway)<br>- `aca-subnet` (Container Apps)<br>- `build-subnet` (Build VM)<br>- `firewall-subnet` (Azure Firewall - オプション) |
| **デフォルト** | ✅ 有効 (`deployToggles.virtualNetwork: true`) |
| **月額コスト** | 無料 (VNet自体)、データ転送は別途課金 |

### 13-26. Private DNS Zones (14ゾーン)

| # | DNSゾーン名 | 目的 | 対象サービス |
|---|------------|------|-------------|
| 13 | `privatelink.cognitiveservices.azure.com` | Cognitive Services名前解決 | Azure OpenAI, AI Services |
| 14 | `privatelink.api.azureml.ms` | AI Foundry API名前解決 | AI Foundry Hub, Project |
| 15 | `privatelink.openai.azure.com` | OpenAI専用名前解決 | Azure OpenAI Service |
| 16 | `privatelink.aiservices.azure.com` | AI Services名前解決 | AI Services統合アカウント |
| 17 | `privatelink.search.windows.net` | AI Search名前解決 | Azure AI Search |
| 18 | `privatelink.documents.azure.com` | Cosmos DB名前解決 | Cosmos DB (SQL API) |
| 19 | `privatelink.blob.core.windows.net` | Blob Storage名前解決 | Storage Account (Blob) |
| 20 | `privatelink.file.core.windows.net` | File Storage名前解決 | Storage Account (Files) |
| 21 | `privatelink.vaultcore.azure.net` | Key Vault名前解決 | Azure Key Vault |
| 22 | `privatelink.azconfig.io` | App Configuration名前解決 | Azure App Configuration |
| 23 | `privatelink.azurecontainerapps.io` | Container Apps名前解決 | Container Apps Environment |
| 24 | `privatelink.azurecr.io` | Container Registry名前解決 | Azure Container Registry |
| 25 | `privatelink.monitor.azure.com` | Application Insights名前解決 | Application Insights |
| 26 | その他 | 追加サービス用 | 必要に応じて追加 |

**リソースタイプ**: `Microsoft.Network/privateDnsZones`

**目的**: プライベートエンドポイント経由でアクセスする際のDNS名前解決

**月額コスト**: ゾーンあたり $0.50 + クエリ料金

### 27. Application Gateway Public IP

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Network/publicIPAddresses` |
| **SKU/Tier** | Standard |
| **目的** | Application Gatewayのパブリックアクセス |
| **用途** | - Webアプリケーションへの外部アクセス<br>- SSL/TLS終端<br>- WAF保護 |
| **デフォルト** | ✅ 有効 (`deployToggles.applicationGatewayPublicIp: true`) |
| **月額コスト** | $4-5/IP |

### 28. Azure Firewall Public IP

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Network/publicIPAddresses` |
| **SKU/Tier** | Standard |
| **目的** | Azure Firewallのエグレストラフィック用 |
| **デフォルト** | ❌ 無効 (`deployToggles.firewall: false`) |
| **月額コスト** | $4-5/IP |

### 29. VNet Peering (Hub-to-Spoke)

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Network/virtualNetworks/virtualNetworkPeerings` |
| **目的** | Platform Landing Zone統合時のHub VNet接続 |
| **用途** | - オンプレミス接続<br>- 他のVNetとの接続<br>- ExpressRoute/VPN Gatewayアクセス |
| **デフォルト** | ⚠️ 条件付き (`flagPlatformLandingZone: true` 時) |
| **月額コスト** | データ転送量による ($0.01/GB) |

---

## 🔌 プライベートエンドポイント

すべてのPaaSサービスはプライベートエンドポイント経由で接続され、**パブリックインターネットに露出しません**。

| # | リソース | プライベートエンドポイント | 目的 | デフォルト |
|---|---------|-------------------------|------|-----------|
| 30 | App Configuration | App Config PE | 構成データへのプライベートアクセス | ✅ 有効 |
| 31 | API Management | APIM PE | APIゲートウェイへのプライベートアクセス | ⚠️ 条件付き |
| 32 | Container Apps Env | Container Apps PE | コンテナ環境へのプライベートアクセス | ✅ 有効 |
| 33 | Container Registry | ACR PE | コンテナイメージへのプライベートアクセス | ✅ 有効 |
| 34 | Storage Account | Storage Blob PE | Blobストレージへのプライベートアクセス | ✅ 有効 |
| 35 | Cosmos DB | Cosmos DB PE | データベースへのプライベートアクセス | ✅ 有効 |
| 36 | AI Search | AI Search PE | 検索サービスへのプライベートアクセス | ✅ 有効 |
| 37 | Key Vault | Key Vault PE | シークレットへのプライベートアクセス | ✅ 有効 |
| 38+ | AI Services (複数) | AI Foundry PE | AI Foundryコンポーネントへのプライベートアクセス | ✅ 有効 |

**リソースタイプ**: `Microsoft.Network/privateEndpoints`

**月額コスト**: エンドポイントあたり $7-10 + データ転送

---

## 📊 監視 & ログ

### 39. Log Analytics Workspace

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.OperationalInsights/workspaces` |
| **SKU/Tier** | PerGB2018 (従量課金) |
| **目的** | 集中ログ管理と分析 |
| **用途** | - 全リソースのログ集約<br>- Kusto Query Language (KQL) クエリ<br>- アラート設定<br>- ダッシュボード作成 |
| **収集データ** | - アプリケーションログ<br>- リソース診断ログ<br>- パフォーマンスメトリクス<br>- セキュリティイベント |
| **デフォルト** | ✅ 有効 (`deployToggles.logAnalytics: true`) |
| **月額コスト** | $2.76/GB (最初の5GBは無料) |

### 40. Application Insights

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Insights/components` |
| **SKU/Tier** | Standard |
| **目的** | アプリケーションパフォーマンス監視 (APM) |
| **用途** | - リクエスト/レスポンストレース<br>- 依存関係マップ<br>- エラー追跡<br>- パフォーマンスボトルネック特定 |
| **機能** | - Live Metrics Stream<br>- Application Map<br>- Smart Detection (異常検知)<br>- Availability Tests |
| **依存関係** | Log Analytics Workspace |
| **デフォルト** | ✅ 有効 (`deployToggles.appInsights: true`) |
| **月額コスト** | $2.76/GB (最初の5GBは無料) |

### 41. Diagnostic Settings (複数)

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Insights/diagnosticSettings` |
| **目的** | リソースごとのログ設定 |
| **用途** | - リソースログをLog Analyticsに送信<br>- メトリクス収集<br>- 監査ログ記録 |
| **デフォルト** | ✅ 有効 (各リソースに自動設定) |
| **月額コスト** | Log Analytics取り込み料金に含まれる |

---

## 🐳 コンテナプラットフォーム

### 42. Container Apps Environment

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.App/managedEnvironments` |
| **SKU/Tier** | Consumption または Dedicated |
| **目的** | サーバーレスコンテナアプリのホスティング |
| **用途** | - Webアプリケーションデプロイ<br>- マイクロサービスホスティング<br>- バックグラウンドジョブ実行 |
| **機能** | - 自動スケーリング<br>- リビジョン管理<br>- トラフィック分割<br>- Dapr統合 |
| **依存関係** | VNet (オプション), Log Analytics (オプション) |
| **デフォルト** | ✅ 有効 (`deployToggles.containerEnv: true`) |
| **月額コスト** | $0 (基本) + リソース使用量による |

### 43. Container Registry (ACR)

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.ContainerRegistry/registries` |
| **SKU/Tier** | Premium (プライベートリンクサポートのため) |
| **目的** | コンテナイメージの保存と管理 |
| **用途** | - Dockerイメージ保存<br>- Helmチャート保存<br>- OCI成果物管理<br>- 脆弱性スキャン |
| **機能** | - Geo-replication<br>- Content Trust<br>- Image Quarantine<br>- Webhooks |
| **デフォルト** | ✅ 有効 (`deployToggles.containerRegistry: true`) |
| **月額コスト** | $0.834/day (~$25/月) |

### 44. Container Apps (可変数)

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.App/containerApps` |
| **目的** | 実際のコンテナアプリケーション |
| **用途** | - チャットUIアプリ<br>- APIバックエンド<br>- データ処理ジョブ |
| **依存関係** | Container Apps Environment, Container Registry |
| **デフォルト** | ✅ 有効 (`deployToggles.containerApps: true`) |
| **月額コスト** | vCPU時間とメモリ使用量による |

---

## 💾 ストレージ & データ

### 45. Storage Account

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Storage/storageAccounts` |
| **SKU/Tier** | Standard_LRS (ローカル冗長) または構成可能 |
| **サービス** | Blob, File, Table, Queue |
| **目的** | 汎用ストレージ |
| **用途** | - AI Foundryのデータ保存<br>- モデルアーティファクト<br>- ログファイル<br>- アプリケーションデータ |
| **機能** | - Blob versioning<br>- Soft delete<br>- Lifecycle management<br>- 保存時暗号化 |
| **デフォルト** | ✅ 有効 (`deployToggles.storageAccount: true`) |
| **月額コスト** | $0.0184/GB (Hot tier) |

### 46. App Configuration

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.AppConfiguration/configurationStores` |
| **SKU/Tier** | Standard |
| **目的** | 集中構成管理 |
| **用途** | - アプリケーション設定の一元管理<br>- フィーチャーフラグ<br>- 環境別設定<br>- 動的構成更新 |
| **機能** | - Key-value store<br>- Feature management<br>- Point-in-time snapshot<br>- Managed Identity統合 |
| **デフォルト** | ✅ 有効 (`deployToggles.appConfig: true`) |
| **月額コスト** | $1.20/day (~$36/月) |

### 47. Cosmos DB Account

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.DocumentDB/databaseAccounts` |
| **SKU/Tier** | Standard |
| **API** | SQL (Core API) |
| **目的** | グローバル分散NoSQLデータベース |
| **用途** | - チャット履歴保存<br>- セッションデータ<br>- ユーザープロファイル<br>- リアルタイムデータ |
| **機能** | - マルチリージョンレプリケーション<br>- 自動スケーリング<br>- 変更フィード<br>- TTL (Time to Live) |
| **デフォルト** | ✅ 有効 (`deployToggles.cosmosDb: true`) |
| **月額コスト** | $24/月 (400 RU/s) + ストレージ |

---

## 🔑 セキュリティ & シークレット管理

### 48. Key Vault

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.KeyVault/vaults` |
| **SKU/Tier** | Standard (HSM非対応) または Premium (HSM対応) |
| **目的** | シークレット、キー、証明書の安全な管理 |
| **用途** | - APIキー保存<br>- 接続文字列管理<br>- 証明書管理<br>- 暗号化キー管理 |
| **機能** | - Soft delete<br>- Purge protection<br>- アクセスポリシー<br>- RBAC統合<br>- Private Link |
| **デフォルト** | ✅ 有効 (`deployToggles.keyVault: true`) |
| **月額コスト** | $0.03/10,000トランザクション |

---

## 🤖 AI & 検索サービス

### 49. Azure AI Search

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Search/searchServices` |
| **SKU/Tier** | Standard (デフォルト、構成可能) |
| **目的** | エンタープライズ検索とRAG (Retrieval-Augmented Generation) |
| **用途** | - ベクトル検索<br>- セマンティック検索<br>- フルテキスト検索<br>- OneLakeインデックス |
| **機能** | - ベクトルインデックス<br>- セマンティックランキング<br>- AIエンリッチメント<br>- スキルセット |
| **容量** | - レプリカ: 1-12<br>- パーティション: 1-12<br>- ストレージ: SKU依存 |
| **デフォルト** | ✅ 有効 (`deployToggles.searchService: true`) |
| **月額コスト** | $250/月 (Standard S1) |

### 50. AI Foundry Hub (Workspace)

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.MachineLearningServices/workspaces` |
| **SKU/Tier** | Standard |
| **目的** | AI開発の中央ハブ |
| **用途** | - AI Foundryプロジェクト管理<br>- リソース共有<br>- ネットワーク設定<br>- 認証・認可 |
| **機能** | - プロジェクト管理<br>- 共有コンピュート<br>- データセット管理<br>- モデルレジストリ |
| **依存関係** | Storage, Key Vault, App Insights, Container Registry |
| **デフォルト** | ✅ 有効 (必須) |
| **月額コスト** | 無料 (基本)、関連リソースは別途課金 |

### 51. AI Foundry Project

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.MachineLearningServices/workspaces` (kind: project) |
| **目的** | プロジェクトスコープのAI開発環境 |
| **用途** | - Playground<br>- Prompt Flow<br>- モデルデプロイ<br>- 実験管理 |
| **機能** | - モデルカタログ<br>- ファインチューニング<br>- エンドポイント管理<br>- バッチ推論 |
| **依存関係** | AI Foundry Hub |
| **デフォルト** | ✅ 有効 (必須) |
| **月額コスト** | 無料 (基本) |

### 52. Azure OpenAI Service (AI Services Account)

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.CognitiveServices/accounts` |
| **Kind** | AIServices (統合アカウント) または OpenAI |
| **SKU/Tier** | S0 (Standard) |
| **目的** | GPTモデルと埋め込みモデルのホスティング |
| **用途** | - チャット補完<br>- テキスト生成<br>- 埋め込み生成<br>- 画像生成 (DALL-E) |
| **機能** | - マネージドID認証<br>- コンテンツフィルター<br>- プロンプトキャッシング<br>- バッチ処理 |
| **デフォルト** | ✅ 有効 (必須) |
| **月額コスト** | 従量課金 (使用量による) |

### 53-55. AI Model Deployments (3デプロイメント)

#### 53. GPT-4 / GPT-4o (チャット補完)

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.CognitiveServices/accounts/deployments` |
| **モデル** | gpt-4 または gpt-4o |
| **バージョン** | 最新 (例: 2024-05-13) |
| **SKU** | Standard |
| **容量 (TPM)** | 10K-100K (構成可能) |
| **目的** | 高度なチャット補完と推論 |
| **用途** | - RAG応答生成<br>- コード生成<br>- 質問応答<br>- 要約 |
| **月額コスト** | $10/1Mトークン (入力), $30/1Mトークン (出力) |

#### 54. GPT-3.5-turbo (チャット補完)

| 項目 | 詳細 |
|------|------|
| **モデル** | gpt-35-turbo |
| **容量 (TPM)** | 10K-120K |
| **目的** | コスト効率の良いチャット補完 |
| **用途** | - 簡単な質問応答<br>- 分類<br>- 抽出 |
| **月額コスト** | $0.50/1Mトークン (入力), $1.50/1Mトークン (出力) |

#### 55. text-embedding-ada-002 / text-embedding-3-large (埋め込み)

| 項目 | 詳細 |
|------|------|
| **モデル** | text-embedding-ada-002 または text-embedding-3-large |
| **容量 (TPM)** | 50K-350K |
| **目的** | テキストのベクトル化 |
| **用途** | - ベクトル検索<br>- セマンティック類似度<br>- クラスタリング |
| **月額コスト** | $0.10/1Mトークン (ada-002), $0.13/1Mトークン (3-large) |

### 56. Bing Search Resource

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Bing/accounts` |
| **SKU/Tier** | S1 (Standard) |
| **目的** | Bing Search APIでのグラウンディング |
| **用途** | - リアルタイム情報取得<br>- 検索結果の統合<br>- 最新データでのAI応答強化 |
| **デフォルト** | ✅ 有効 (`deployToggles.groundingWithBingSearch: true`) |
| **月額コスト** | $7/1000クエリ |

### 57. Bing Search Connection

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.CognitiveServices/accounts/connections` |
| **目的** | Bing SearchをAI Servicesに接続 |
| **依存関係** | Bing Search, AI Services |
| **デフォルト** | ✅ 有効 (Bing Search有効時) |

---

## 🔌 API管理

### 58. API Management Service

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.ApiManagement/service` |
| **SKU/Tier** | Developer, Basic, Standard, Premium (構成可能) |
| **目的** | APIゲートウェイとAPI管理 |
| **用途** | - レート制限<br>- 認証・認可<br>- APIバージョニング<br>- 変換ポリシー |
| **機能** | - Developer Portal<br>- API Analytics<br>- 複数バックエンド統合<br>- OAuth 2.0 |
| **デフォルト** | ❌ 無効 (`deployToggles.apiManagement: false`) |
| **月額コスト** | $50/月 (Developer) ~ $2,800/月 (Premium) |

---

## 🚪 ゲートウェイ & ファイアウォール

### 59. Web Application Firewall (WAF) Policy

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies` |
| **SKU/Tier** | Standard_v2 または WAF_v2 |
| **目的** | Webアプリケーション保護ルール |
| **用途** | - OWASP Top 10保護<br>- SQLインジェクション防止<br>- XSS防止<br>- ボット保護 |
| **デフォルト** | ✅ 有効 (`deployToggles.wafPolicy: true`) |
| **月額コスト** | Application Gatewayに含まれる |

### 60. Application Gateway

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Network/applicationGateways` |
| **SKU/Tier** | Standard_v2 または WAF_v2 |
| **目的** | L7ロードバランサーとWAF |
| **用途** | - SSL/TLS終端<br>- URLルーティング<br>- セッションアフィニティ<br>- リダイレクト |
| **機能** | - Autoscaling<br>- Zone redundancy<br>- WAF統合<br>- Private Link |
| **依存関係** | Public IP, VNet, WAF Policy (オプション) |
| **デフォルト** | ✅ 有効 (`deployToggles.applicationGateway: true`) |
| **月額コスト** | $145/月 (固定) + $0.008/時間 (Compute Unit) + データ処理 |

### 61. Azure Firewall Policy

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Network/firewallPolicies` |
| **SKU/Tier** | Standard または Premium |
| **目的** | ファイアウォールルールと脅威インテリジェンス |
| **用途** | - ネットワークルール<br>- アプリケーションルール<br>- NATルール<br>- 脅威インテリジェンス |
| **デフォルト** | ❌ 無効 (`deployToggles.firewall: false`) |

### 62. Azure Firewall

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Network/azureFirewalls` |
| **SKU/Tier** | Standard または Premium |
| **目的** | ネットワークレベルのファイアウォール |
| **用途** | - エグレストラフィック制御<br>- FQDN filtering<br>- IDPS (Premium)<br>- TLS inspection (Premium) |
| **依存関係** | Public IP, VNet, Firewall Policy |
| **デフォルト** | ❌ 無効 (`deployToggles.firewall: false`) |
| **月額コスト** | $1.25/時間 (~$912/月) + データ処理 |

---

## 💻 仮想マシン

### 63-66. Build VM (Linux)

#### 63. Build VM Maintenance Configuration

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Maintenance/maintenanceConfigurations` |
| **目的** | Build VMのメンテナンススケジュール |

#### 64. Build VM

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Compute/virtualMachines` |
| **SKU/Tier** | Standard_D4s_v3 (4 vCPU, 16GB RAM) または構成可能 |
| **OS** | Ubuntu 22.04 LTS または構成可能 |
| **目的** | CI/CDビルドエージェント |
| **用途** | - Azure DevOps Agent<br>- GitHub Actions Runner<br>- コンテナビルド<br>- テスト実行 |
| **デフォルト** | ✅ 有効 (`deployToggles.buildVm: true`) |
| **月額コスト** | $140/月 (D4s_v3, 24/7稼働) |

#### 65. Build VM Network Interface

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Network/networkInterfaces` |

#### 66. Build VM Disk

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Compute/disks` |
| **SKU/Tier** | Premium_LRS (SSD) または Standard_LRS (HDD) |

### 67-70. Jump VM (Windows)

#### 67. Jump VM Maintenance Configuration

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Maintenance/maintenanceConfigurations` |
| **目的** | Jump VMのメンテナンススケジュール |

#### 68. Jump VM

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Compute/virtualMachines` |
| **SKU/Tier** | Standard_D2s_v3 (2 vCPU, 8GB RAM) または Standard_DAS_v5 |
| **OS** | Windows Server 2022 Datacenter または構成可能 |
| **目的** | プライベートリソースへの安全なアクセス |
| **用途** | - Azure Portal アクセス<br>- プライベートエンドポイント経由での管理<br>- ツールインストール<br>- デバッグ |
| **デフォルト** | ✅ 有効 (`deployToggles.jumpVm: true`) |
| **月額コスト** | $70/月 (D2s_v3, 24/7稼働) または $96/月 (DAS_v5) |

#### 69. Jump VM Network Interface

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Network/networkInterfaces` |

#### 70. Jump VM Disk

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Compute/disks` |
| **SKU/Tier** | Premium_LRS (SSD) |

### 71. Azure Bastion Host

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Network/bastionHosts` |
| **SKU/Tier** | Standard または Basic |
| **目的** | セキュアなRDP/SSHアクセス |
| **用途** | - パブリックIPなしでVMアクセス<br>- ブラウザベースのSSH/RDP<br>- MFA統合<br>- 監査ログ |
| **依存関係** | VNet (Bastion専用サブネット) |
| **デフォルト** | ✅ 有効 (`deployToggles.bastionHost: true`) |
| **月額コスト** | $140/月 (Basic) ~ $876/月 (Standard) |

---

## 🏭 Microsoft Fabric

### 72. Microsoft Fabric Capacity

| 項目 | 詳細 |
|------|------|
| **リソースタイプ** | `Microsoft.Fabric/capacities@2023-11-01` |
| **SKU/Tier** | F8 (デフォルト) |
| **選択可能SKU** | F2, F4, F8, F16, F32, F64, F128, F256, F512, F1024, F2048 |
| **目的** | Fabricワークロード用のコンピュートキャパシティ |
| **用途** | - Lakehouse<br>- Data Warehouse<br>- Data Engineering<br>- Data Science<br>- Power BI |
| **機能** | - 自動一時停止<br>- スケールアップ/ダウン<br>- 複数ワークスペース共有 |
| **デフォルト** | ✅ 有効 (`fabricCapacityMode: 'create'`) |
| **月額コスト** | - F2: $262/月<br>- F4: $525/月<br>- F8: $1,050/月<br>- F16: $2,100/月<br>- F32: $4,200/月 |

---

## 🔐 RBAC (ロールベースアクセス制御)

### 73-100+. Role Assignments (20-50+ 割り当て)

**リソースタイプ**: `Microsoft.Authorization/roleAssignments`

**目的**: マネージドIDを使用したサービス間のセキュアな認証・認可

#### 主要なロール割り当て例

| ソース | ターゲット | ロール | 目的 |
|--------|----------|--------|------|
| AI Foundry Hub | Storage Account | Storage Blob Data Contributor | Blobへの読み書き |
| AI Foundry Hub | Key Vault | Key Vault Secrets User | シークレット取得 |
| AI Foundry Hub | AI Search | Search Service Contributor | インデックス管理 |
| AI Foundry Hub | Azure OpenAI | Cognitive Services User | モデル呼び出し |
| AI Foundry Project | AI Foundry Hub | Contributor | Hub リソースへのアクセス |
| Container Apps | Container Registry | AcrPull | イメージプル |
| Container Apps | Key Vault | Key Vault Secrets User | シークレット取得 |
| User/ServicePrincipal | AI Foundry Hub | Azure ML Data Scientist | モデル開発 |
| User/ServicePrincipal | AI Search | Search Index Data Contributor | インデックス編集 |

**月額コスト**: 無料

---

## 📦 ポストプロビジョンリソース (PowerShellスクリプト経由)

これらのリソースは、Bicepデプロイ後にPowerShellスクリプトで作成されます。

### 101. Fabric Workspace

| 項目 | 詳細 |
|------|------|
| **プラットフォーム** | Microsoft Fabric (Power BI/Fabric API経由) |
| **目的** | Fabricアイテムのコンテナ |
| **用途** | - Lakehouse管理<br>- ノートブック管理<br>- データフロー管理 |
| **依存関係** | Fabric Capacity |
| **作成方法** | `CreateWorkspace.ps1` |
| **デフォルト** | ✅ 有効 (`fabricWorkspaceMode: 'create'`) |

### 102-104. Fabric Lakehouses (3インスタンス)

| # | Lakehouse名 | 目的 | 用途 |
|---|------------|------|------|
| 102 | **Bronze Lakehouse** | Raw データ層 | - ソースデータの取り込み<br>- 未加工データ保存<br>- 初期データレイク |
| 103 | **Silver Lakehouse** | Cleaned データ層 | - データクレンジング<br>- データ変換<br>- 標準化されたスキーマ |
| 104 | **Gold Lakehouse** | Curated データ層 | - 分析用データ<br>- ビジネスロジック適用<br>- レポート用集約データ |

| 項目 | 詳細 |
|------|------|
| **プラットフォーム** | Microsoft Fabric |
| **依存関係** | Fabric Workspace |
| **作成方法** | `create_lakehouses.ps1` |
| **デフォルト** | ✅ 有効 |

### 105. Purview Collection

| 項目 | 詳細 |
|------|------|
| **プラットフォーム** | Microsoft Purview |
| **目的** | データ資産の整理とガバナンス |
| **用途** | - データカタログ化<br>- アクセス管理<br>- コンプライアンス管理 |
| **依存関係** | 既存のPurviewアカウント (ユーザー提供) |
| **作成方法** | `create_purview_collection.ps1` |
| **デフォルト** | ⚠️ 条件付き (Purviewアカウント提供時) |

### 106. Purview Data Source Registration

| 項目 | 詳細 |
|------|------|
| **プラットフォーム** | Microsoft Purview |
| **目的** | Fabricデータソースの登録 |
| **用途** | - データスキャン<br>- メタデータ収集<br>- データ系列追跡 |
| **依存関係** | Purview Collection, Fabric Lakehouses |
| **作成方法** | `register_fabric_datasource.ps1` |

### 107. AI Search Index

| 項目 | 詳細 |
|------|------|
| **プラットフォーム** | Azure AI Search |
| **目的** | OneLakeデータのベクトルインデックス |
| **用途** | - RAG用ベクトル検索<br>- セマンティック検索<br>- ドキュメント検索 |
| **依存関係** | AI Search Service, Fabric Lakehouses |
| **作成方法** | `setup_onelake_index.ps1` |

---

## 📈 リソースコスト概算

### 月額コスト見積もり (デフォルト構成)

| カテゴリ | 月額コスト (USD) |
|---------|-----------------|
| **AI Services** | |
| - Azure OpenAI (従量課金) | $100-500 (使用量による) |
| - AI Search (Standard S1) | $250 |
| - Bing Search | $35 (5,000クエリ想定) |
| **Compute** | |
| - Fabric Capacity (F8) | $1,050 |
| - Jump VM (D2s_v3) | $70 |
| - Build VM (D4s_v3) | $140 |
| **Networking** | |
| - Application Gateway | $200 |
| - Private Endpoints (8個) | $60 |
| - Bastion Host (Basic) | $140 |
| - Private DNS Zones (14個) | $7 |
| - Data Transfer | $50-200 (使用量による) |
| **Storage** | |
| - Storage Account | $10-50 (使用量による) |
| - Cosmos DB (400 RU/s) | $24 |
| **Monitoring** | |
| - Log Analytics | $20-100 (ログ量による) |
| - Application Insights | $10-50 (テレメトリ量による) |
| **Container** | |
| - Container Registry (Premium) | $25 |
| - Container Apps | $0-100 (使用量による) |
| **Other** | |
| - App Configuration | $36 |
| - Key Vault | $1 |
| - Defender for Cloud | $30 |
| **合計 (概算)** | **$2,200-3,100/月** |

### コスト最適化のヒント

1. **Fabric Capacity**: 使用しない時は一時停止 → **月$1,050削減**
2. **Jump VM**: 業務時間のみ稼働 → **月$50削減**
3. **Build VM**: オンデマンド起動 → **月$100削減**
4. **Azure Firewall**: 不要なら無効化 → **月$912削減**
5. **AI Search SKU**: Basic → Standard必要時のみ → **月$175削減**

---

## 🎯 デフォルト構成のまとめ

### ✅ デフォルトで有効 (73リソース)

- セキュリティ & ガバナンス (3)
- NSG (8)
- ネットワーク (16)
- プライベートエンドポイント (8+)
- 監視 (2)
- コンテナ (3)
- ストレージ & データ (3)
- Key Vault (1)
- AI & 検索 (8)
- ゲートウェイ (2: App Gateway, WAF)
- VM (9: Jump VM, Build VM, Bastion)
- Fabric (1)
- ポストプロビジョン (7)

### ❌ デフォルトで無効 (2リソース)

- API Management
- Azure Firewall

---

## 📚 参考資料

- [Azure AI Foundry Documentation](https://learn.microsoft.com/azure/ai-foundry/)
- [Microsoft Fabric Documentation](https://learn.microsoft.com/fabric/)
- [Azure AI Search Documentation](https://learn.microsoft.com/azure/search/)
- [Azure OpenAI Service Documentation](https://learn.microsoft.com/azure/ai-services/openai/)
- [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)
- [Azure Architecture Center](https://learn.microsoft.com/azure/architecture/)

---

**更新日**: 2026-01-19
**バージョン**: 1.0
**総リソース数**: 77-107リソース
