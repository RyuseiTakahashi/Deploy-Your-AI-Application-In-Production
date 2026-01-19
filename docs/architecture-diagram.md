# Azure AI Application Architecture

このドキュメントでは、Deploy Your AI Application In Productionソリューションのアーキテクチャを視覚化します。

## アーキテクチャ概要図 (レイヤー別)

```mermaid
graph TB
    subgraph External["🌐 外部ユーザー"]
        Users[ユーザー]
    end

    subgraph SecurityLayer["🔐 セキュリティ & ガバナンスレイヤー"]
        Entra[Microsoft Entra ID<br/>認証・認可]
        Purview[Microsoft Purview<br/>データガバナンス]
        Defender[Microsoft Defender<br/>セキュリティ]
    end

    subgraph NetworkLayer["🌐 ネットワークレイヤー"]
        Bastion[Azure Bastion<br/>安全なアクセス]
        JumpVM[Jumpbox VM<br/>管理用VM]
        VNet[Virtual Network<br/>プライベートネットワーク]
        PrivateEndpoints[Private Endpoints<br/>プライベート接続]
    end

    subgraph AILayer["🤖 AI & MLレイヤー"]
        AIFoundry[Azure AI Foundry<br/>AIプロジェクト管理]
        AIHub[AI Hub<br/>中央管理]
        OpenAI[Azure OpenAI<br/>GPT-4, GPT-3.5]
        AISearch[Azure AI Search<br/>ベクトル検索]
        CogServices[Cognitive Services<br/>AI APIs]
    end

    subgraph DataLayer["💾 データレイヤー"]
        Fabric[Microsoft Fabric<br/>データプラットフォーム]
        FabricCapacity[Fabric Capacity<br/>コンピュート]
        Workspace[Fabric Workspace]
        Bronze[Bronze Lakehouse<br/>Raw Data]
        Silver[Silver Lakehouse<br/>Cleaned Data]
        Gold[Gold Lakehouse<br/>Analytics Data]
        OneLake[OneLake<br/>統合データレイク]
    end

    subgraph InfraLayer["⚙️ インフラストラクチャレイヤー"]
        Storage[Azure Storage<br/>ストレージ]
        KeyVault[Azure Key Vault<br/>シークレット管理]
        ACR[Container Registry<br/>コンテナイメージ]
        AppInsights[Application Insights<br/>監視]
        LogAnalytics[Log Analytics<br/>ログ集約]
    end

    subgraph AppLayer["📱 アプリケーションレイヤー (オプション)"]
        WebApp[Web App<br/>チャットUI]
        AppGateway[Application Gateway<br/>L7ロードバランサー]
        Firewall[Azure Firewall<br/>ネットワークセキュリティ]
    end

    %% External connections
    Users -->|HTTPS| Bastion
    Users -->|HTTPS| WebApp

    %% Security Layer connections
    Entra -.->|認証| AIFoundry
    Entra -.->|認証| Fabric
    Purview -.->|カタログ化| Fabric
    Purview -.->|スキャン| Bronze
    Defender -.->|保護| VNet

    %% Network Layer connections
    Bastion --> JumpVM
    JumpVM --> VNet
    VNet --> PrivateEndpoints
    PrivateEndpoints -.-> AIFoundry
    PrivateEndpoints -.-> Storage
    PrivateEndpoints -.-> KeyVault
    PrivateEndpoints -.-> ACR

    %% AI Layer connections
    AIFoundry --> AIHub
    AIHub --> OpenAI
    AIHub --> AISearch
    AIHub --> CogServices
    AIFoundry --> AISearch
    AISearch --> OneLake

    %% Data Layer connections
    Fabric --> FabricCapacity
    FabricCapacity --> Workspace
    Workspace --> Bronze
    Workspace --> Silver
    Workspace --> Gold
    Bronze --> OneLake
    Silver --> OneLake
    Gold --> OneLake
    OneLake --> AISearch

    %% Infrastructure connections
    AIFoundry --> Storage
    AIFoundry --> KeyVault
    AIFoundry --> AppInsights
    AIFoundry --> ACR
    AppInsights --> LogAnalytics
    Fabric --> Storage

    %% Application Layer connections
    WebApp --> AppGateway
    AppGateway --> Firewall
    WebApp --> AIFoundry
    WebApp --> AISearch

    %% Styling
    classDef security fill:#ff6b6b,stroke:#c92a2a,color:#fff
    classDef network fill:#4dabf7,stroke:#1971c2,color:#fff
    classDef ai fill:#845ef7,stroke:#5f3dc4,color:#fff
    classDef data fill:#51cf66,stroke:#2f9e44,color:#fff
    classDef infra fill:#ffd43b,stroke:#f59f00,color:#000
    classDef app fill:#ff8787,stroke:#fa5252,color:#fff

    class Entra,Purview,Defender security
    class Bastion,JumpVM,VNet,PrivateEndpoints network
    class AIFoundry,AIHub,OpenAI,AISearch,CogServices ai
    class Fabric,FabricCapacity,Workspace,Bronze,Silver,Gold,OneLake data
    class Storage,KeyVault,ACR,AppInsights,LogAnalytics infra
    class WebApp,AppGateway,Firewall app
```

---

## データフロー図

```mermaid
graph LR
    subgraph Input["📥 データ入力"]
        Documents[ドキュメント<br/>PDF, DOCX, etc.]
    end

    subgraph Ingestion["🔄 データ取り込み"]
        Upload[アップロード]
        BronzeLH[Bronze Lakehouse<br/>Raw Storage]
    end

    subgraph Processing["⚙️ データ処理"]
        Transform[データ変換]
        SilverLH[Silver Lakehouse<br/>Cleaned Data]
        GoldLH[Gold Lakehouse<br/>Curated Data]
    end

    subgraph Indexing["🔍 インデックス化"]
        OneLakeIndexer[OneLake Indexer]
        AISearchIndex[AI Search Index<br/>ベクトルDB]
    end

    subgraph AI["🤖 AI処理"]
        Embedding[埋め込み生成<br/>Azure OpenAI]
        ChatModel[チャットモデル<br/>GPT-4 / GPT-3.5]
    end

    subgraph Output["📤 出力"]
        Playground[AI Foundry Playground]
        ChatApp[チャットアプリ]
        Response[AIレスポンス]
    end

    subgraph Governance["📋 ガバナンス"]
        PurviewScan[Purview スキャン]
        Catalog[データカタログ]
        Lineage[データ系列]
    end

    %% Data flow
    Documents --> Upload
    Upload --> BronzeLH
    BronzeLH --> Transform
    Transform --> SilverLH
    SilverLH --> GoldLH
    BronzeLH --> OneLakeIndexer
    OneLakeIndexer --> Embedding
    Embedding --> AISearchIndex

    %% AI Query flow
    Playground --> |クエリ| AISearchIndex
    ChatApp --> |クエリ| AISearchIndex
    AISearchIndex --> |コンテキスト| ChatModel
    ChatModel --> Response
    Response --> Playground
    Response --> ChatApp

    %% Governance flow
    BronzeLH -.-> PurviewScan
    SilverLH -.-> PurviewScan
    GoldLH -.-> PurviewScan
    PurviewScan --> Catalog
    PurviewScan --> Lineage

    %% Styling
    classDef input fill:#ffd43b,stroke:#f59f00
    classDef processing fill:#51cf66,stroke:#2f9e44,color:#fff
    classDef ai fill:#845ef7,stroke:#5f3dc4,color:#fff
    classDef output fill:#4dabf7,stroke:#1971c2,color:#fff
    classDef governance fill:#ff6b6b,stroke:#c92a2a,color:#fff

    class Documents,Upload input
    class BronzeLH,Transform,SilverLH,GoldLH processing
    class OneLakeIndexer,Embedding,ChatModel,AISearchIndex ai
    class Playground,ChatApp,Response output
    class PurviewScan,Catalog,Lineage governance
```

---

## ネットワークアーキテクチャ図

```mermaid
graph TB
    subgraph Internet["🌐 インターネット"]
        User[エンドユーザー]
    end

    subgraph AzureCloud["☁️ Azure Cloud"]
        subgraph PublicAccess["パブリックアクセス"]
            Bastion[Azure Bastion<br/>:443]
            AppGW[Application Gateway<br/>:443]
        end

        subgraph VirtualNetwork["Virtual Network<br/>10.0.0.0/16"]
            subgraph BastionSubnet["Bastion Subnet<br/>10.0.1.0/24"]
                BastionHost[Bastion Host]
            end

            subgraph JumpboxSubnet["Jumpbox Subnet<br/>10.0.2.0/24"]
                JumpVM[Jumpbox VM<br/>管理用]
            end

            subgraph PrivateEndpointSubnet["Private Endpoint Subnet<br/>10.0.10.0/24"]
                PE_Storage[PE: Storage]
                PE_KeyVault[PE: Key Vault]
                PE_ACR[PE: Container Registry]
                PE_AI[PE: AI Services]
                PE_Search[PE: AI Search]
            end

            subgraph AISubnet["AI Foundry Subnet<br/>10.0.20.0/24"]
                AIFoundryAgent[AI Foundry<br/>Agent Service]
                AIModels[AI Models]
            end

            subgraph AppSubnet["App Subnet<br/>10.0.30.0/24"]
                WebAppInt[Web App<br/>Internal]
            end

            subgraph FirewallSubnet["Firewall Subnet<br/>10.0.100.0/24"]
                AzFW[Azure Firewall]
            end
        end

        subgraph PaaSServices["Azure PaaS サービス<br/>(プライベート接続)"]
            Storage[Storage Account]
            KeyVault[Key Vault]
            ACR[Container Registry]
            OpenAI[Azure OpenAI]
            AISearch[AI Search]
            Fabric[Microsoft Fabric]
        end

        subgraph Monitoring["監視 & ログ"]
            AppInsights[Application Insights]
            LogAnalytics[Log Analytics]
        end
    end

    subgraph External["外部サービス"]
        Purview[Microsoft Purview<br/>テナントレベル]
        EntraID[Microsoft Entra ID]
    end

    %% User connections
    User -->|HTTPS:443| Bastion
    User -->|HTTPS:443| AppGW

    %% Bastion connections
    Bastion --> BastionHost
    BastionHost --> JumpVM

    %% Jumpbox connections
    JumpVM -.->|管理| PE_Storage
    JumpVM -.->|管理| PE_KeyVault
    JumpVM -.->|管理| PE_ACR

    %% Private Endpoint connections
    PE_Storage -.->|Private Link| Storage
    PE_KeyVault -.->|Private Link| KeyVault
    PE_ACR -.->|Private Link| ACR
    PE_AI -.->|Private Link| OpenAI
    PE_Search -.->|Private Link| AISearch

    %% AI Foundry connections
    AIFoundryAgent --> PE_AI
    AIFoundryAgent --> PE_Search
    AIFoundryAgent --> PE_Storage
    AIFoundryAgent --> PE_KeyVault

    %% App connections
    AppGW --> WebAppInt
    WebAppInt --> AIFoundryAgent
    WebAppInt --> PE_Search

    %% Firewall
    AzFW -.->|Egress| Internet

    %% Monitoring
    AIFoundryAgent --> AppInsights
    WebAppInt --> AppInsights
    AppInsights --> LogAnalytics

    %% External connections
    Storage -.->|Purview Scan| Purview
    Fabric -.->|Purview Scan| Purview
    AIFoundryAgent -.->|認証| EntraID

    %% Styling
    classDef public fill:#ff8787,stroke:#fa5252,color:#fff
    classDef private fill:#4dabf7,stroke:#1971c2,color:#fff
    classDef paas fill:#51cf66,stroke:#2f9e44,color:#fff
    classDef monitoring fill:#ffd43b,stroke:#f59f00,color:#000
    classDef external fill:#845ef7,stroke:#5f3dc4,color:#fff

    class Bastion,AppGW,BastionHost public
    class JumpVM,PE_Storage,PE_KeyVault,PE_ACR,PE_AI,PE_Search,AIFoundryAgent,WebAppInt,AzFW private
    class Storage,KeyVault,ACR,OpenAI,AISearch,Fabric paas
    class AppInsights,LogAnalytics monitoring
    class Purview,EntraID external
```

---

## デプロイメントフロー図

```mermaid
graph TB
    Start([azd up 実行])

    subgraph PreProvision["🔧 Pre-Provision"]
        CheckQuota[クォータチェック]
        ValidateParams[パラメータ検証]
    end

    subgraph CoreInfra["🏗️ コアインフラ (5-10分)"]
        DeployRG[リソースグループ作成]
        DeployVNet[Virtual Network]
        DeployStorage[Storage Account]
        DeployKeyVault[Key Vault]
        DeployACR[Container Registry]
        DeployLog[Log Analytics]
    end

    subgraph AIInfra["🤖 AI インフラ (10-15分)"]
        DeployAIHub[AI Hub]
        DeployOpenAI[Azure OpenAI]
        DeployAISearch[AI Search]
        DeployAIFoundry[AI Foundry Project]
        DeployModels[AI Models デプロイ]
    end

    subgraph DataInfra["💾 データインフラ (5-10分)"]
        DeployFabricCap[Fabric Capacity]
        DeployWorkspace[Fabric Workspace]
        DeployLakehouses[Lakehouses 作成]
    end

    subgraph Networking["🌐 ネットワーク (5-10分)"]
        DeployPE[Private Endpoints]
        DeployBastion[Azure Bastion]
        DeployJumpVM[Jumpbox VM]
        ConfigDNS[Private DNS Zones]
    end

    subgraph PostProvision["⚙️ Post-Provision (10-15分)"]
        CreateCollection[Purview Collection 作成]
        RegisterDS[Fabric データソース登録]
        CreateLH[Lakehouse セットアップ]
        TriggerScan[Purview スキャン]
        SetupRBAC[RBAC 設定]
        UploadDocs[サンプルドキュメント]
        CreateIndex[AI Search Index]
    end

    Complete([✅ デプロイ完了<br/>~45分])

    Start --> CheckQuota
    CheckQuota --> ValidateParams
    ValidateParams --> DeployRG

    DeployRG --> DeployVNet
    DeployVNet --> DeployStorage
    DeployStorage --> DeployKeyVault
    DeployKeyVault --> DeployACR
    DeployACR --> DeployLog

    DeployLog --> DeployAIHub
    DeployAIHub --> DeployOpenAI
    DeployOpenAI --> DeployAISearch
    DeployAISearch --> DeployAIFoundry
    DeployAIFoundry --> DeployModels

    DeployModels --> DeployFabricCap
    DeployFabricCap --> DeployWorkspace
    DeployWorkspace --> DeployLakehouses

    DeployLakehouses --> DeployPE
    DeployPE --> DeployBastion
    DeployBastion --> DeployJumpVM
    DeployJumpVM --> ConfigDNS

    ConfigDNS --> CreateCollection
    CreateCollection --> RegisterDS
    RegisterDS --> CreateLH
    CreateLH --> TriggerScan
    TriggerScan --> SetupRBAC
    SetupRBAC --> UploadDocs
    UploadDocs --> CreateIndex

    CreateIndex --> Complete

    %% Styling
    classDef prep fill:#ffd43b,stroke:#f59f00,color:#000
    classDef infra fill:#4dabf7,stroke:#1971c2,color:#fff
    classDef ai fill:#845ef7,stroke:#5f3dc4,color:#fff
    classDef data fill:#51cf66,stroke:#2f9e44,color:#fff
    classDef network fill:#ff8787,stroke:#fa5252,color:#fff
    classDef post fill:#74c0fc,stroke:#339af0,color:#000

    class CheckQuota,ValidateParams prep
    class DeployRG,DeployVNet,DeployStorage,DeployKeyVault,DeployACR,DeployLog infra
    class DeployAIHub,DeployOpenAI,DeployAISearch,DeployAIFoundry,DeployModels ai
    class DeployFabricCap,DeployWorkspace,DeployLakehouses data
    class DeployPE,DeployBastion,DeployJumpVM,ConfigDNS network
    class CreateCollection,RegisterDS,CreateLH,TriggerScan,SetupRBAC,UploadDocs,CreateIndex post
```

---

## RAG (Retrieval-Augmented Generation) フロー図

```mermaid
sequenceDiagram
    actor User as ユーザー
    participant UI as AI Foundry<br/>Playground
    participant Search as AI Search<br/>Vector DB
    participant OneLake as OneLake<br/>Indexer
    participant LH as Lakehouse<br/>Bronze/Silver/Gold
    participant OpenAI as Azure OpenAI<br/>Embeddings
    participant GPT as Azure OpenAI<br/>GPT-4
    participant Purview as Microsoft<br/>Purview

    Note over LH,Purview: データ取り込みフェーズ
    User->>LH: 1. ドキュメントアップロード
    LH->>OneLake: 2. OneLake に保存
    OneLake->>OpenAI: 3. 埋め込み生成リクエスト
    OpenAI->>OneLake: 4. ベクトル埋め込み
    OneLake->>Search: 5. インデックス更新
    LH->>Purview: 6. データスキャン

    Note over User,GPT: クエリフェーズ
    User->>UI: 7. 質問入力<br/>"この資料について教えて"
    UI->>OpenAI: 8. 質問の埋め込み生成
    OpenAI->>UI: 9. クエリベクトル
    UI->>Search: 10. ベクトル類似検索
    Search->>UI: 11. 関連ドキュメント<br/>(Top K)
    UI->>GPT: 12. プロンプト + コンテキスト
    Note over GPT: コンテキスト:<br/>- 質問<br/>- 関連ドキュメント<br/>- システムプロンプト
    GPT->>UI: 13. AI生成回答
    UI->>User: 14. 回答表示

    Note over User,Purview: ガバナンスフェーズ
    Purview->>Purview: 15. データ系列追跡
    Purview->>Purview: 16. コンプライアンスチェック
```

---

## コンポーネント一覧

### セキュリティ & ガバナンス
| コンポーネント | 用途 |
|---------------|------|
| Microsoft Entra ID | 認証・認可・アクセス管理 |
| Microsoft Purview | データカタログ、系列追跡、DSPM |
| Microsoft Defender | セキュリティ監視・保護 |
| Azure Key Vault | シークレット・証明書管理 |

### ネットワーキング
| コンポーネント | 用途 |
|---------------|------|
| Virtual Network | プライベートネットワーク (10.0.0.0/16) |
| Private Endpoints | PaaSサービスへのプライベート接続 |
| Azure Bastion | セキュアなVM管理アクセス |
| Jumpbox VM | 管理用仮想マシン |
| Azure Firewall | アウトバウンドトラフィック制御 |
| Private DNS Zones | プライベートエンドポイント名前解決 |

### AI & 機械学習
| コンポーネント | 用途 |
|---------------|------|
| Azure AI Foundry | AIプロジェクト開発・管理プラットフォーム |
| AI Hub | 中央集約型AI管理 |
| Azure OpenAI | GPT-4, GPT-3.5, Embeddings モデル |
| Azure AI Search | ベクトル検索、セマンティック検索 |
| Cognitive Services | 各種AI APIサービス |

### データプラットフォーム
| コンポーネント | 用途 |
|---------------|------|
| Microsoft Fabric | 統合データ分析プラットフォーム |
| Fabric Capacity | コンピュートリソース (F8 SKU) |
| Fabric Workspace | データ資産の論理コンテナ |
| Bronze Lakehouse | Rawデータ保存 |
| Silver Lakehouse | クレンジング済みデータ |
| Gold Lakehouse | 分析用キュレートデータ |
| OneLake | Fabric統合データレイク |

### インフラストラクチャ
| コンポーネント | 用途 |
|---------------|------|
| Storage Account | Blob, File, Table, Queue ストレージ |
| Container Registry | コンテナイメージ管理 |
| Application Insights | アプリケーション監視・APM |
| Log Analytics | ログ集約・分析 |

### アプリケーション (オプション)
| コンポーネント | 用途 |
|---------------|------|
| Web App | チャットUIホスティング |
| Application Gateway | L7ロードバランサー・WAF |

---

## デプロイ時間の内訳

| フェーズ | 所要時間 | 主要リソース |
|---------|---------|-------------|
| **Pre-Provision** | 1-2分 | クォータチェック、パラメータ検証 |
| **コアインフラ** | 5-10分 | VNet, Storage, Key Vault, Container Registry |
| **AI インフラ** | 10-15分 | AI Hub, OpenAI, AI Search, AI Foundry, Models |
| **データインフラ** | 5-10分 | Fabric Capacity, Workspace, Lakehouses |
| **ネットワーク** | 5-10分 | Private Endpoints, Bastion, Jumpbox VM, DNS |
| **Post-Provision** | 10-15分 | Purview統合, RBAC, インデックス作成 |
| **合計** | **~45分** | 全体 |

---

## セキュリティ設計

### 多層防御アーキテクチャ

```mermaid
graph LR
    subgraph Layer1["Layer 1: ID/認証"]
        EntraID[Entra ID<br/>Multi-Factor Auth]
        RBAC[Azure RBAC]
    end

    subgraph Layer2["Layer 2: ネットワーク"]
        NSG[Network Security Groups]
        Firewall[Azure Firewall]
        PrivateLink[Private Link]
    end

    subgraph Layer3["Layer 3: データ"]
        Encryption[保存時暗号化<br/>Azure Storage Encryption]
        TLS[転送時暗号化<br/>TLS 1.2+]
        KeyVault[Key Vault<br/>キー管理]
    end

    subgraph Layer4["Layer 4: アプリケーション"]
        ManagedID[Managed Identity<br/>パスワードレス認証]
        WAF[Web Application Firewall]
        APIGateway[API Management]
    end

    subgraph Layer5["Layer 5: 監視/ガバナンス"]
        Defender[Microsoft Defender]
        Sentinel[Microsoft Sentinel]
        Purview[Microsoft Purview]
        AuditLogs[監査ログ]
    end

    EntraID --> RBAC
    RBAC --> NSG
    NSG --> Firewall
    Firewall --> PrivateLink
    PrivateLink --> Encryption
    Encryption --> TLS
    TLS --> KeyVault
    KeyVault --> ManagedID
    ManagedID --> WAF
    WAF --> APIGateway
    APIGateway --> Defender
    Defender --> Sentinel
    Sentinel --> Purview
    Purview --> AuditLogs

    classDef layer1 fill:#ff6b6b,stroke:#c92a2a,color:#fff
    classDef layer2 fill:#4dabf7,stroke:#1971c2,color:#fff
    classDef layer3 fill:#51cf66,stroke:#2f9e44,color:#fff
    classDef layer4 fill:#ffd43b,stroke:#f59f00,color:#000
    classDef layer5 fill:#845ef7,stroke:#5f3dc4,color:#fff

    class EntraID,RBAC layer1
    class NSG,Firewall,PrivateLink layer2
    class Encryption,TLS,KeyVault layer3
    class ManagedID,WAF,APIGateway layer4
    class Defender,Sentinel,Purview,AuditLogs layer5
```

---

## 参考資料

- [Azure AI Foundry Documentation](https://learn.microsoft.com/azure/ai-foundry/)
- [Microsoft Fabric Documentation](https://learn.microsoft.com/fabric/)
- [Azure AI Search Documentation](https://learn.microsoft.com/azure/search/)
- [Microsoft Purview Documentation](https://learn.microsoft.com/purview/)
- [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/)
