# Microsoft Purview アカウント作成ガイド

このガイドでは、Microsoft Purviewアカウントを作成する複数の方法を説明します。

## 重要な注意事項

このソリューションアクセラレータは、**既存のMicrosoft Purviewアカウント**を使用することを前提としています。Purviewアカウントは自動的には作成されません。デプロイ前に、以下のいずれかの方法でPurviewアカウントを作成する必要があります。

---

## Marketplaceエラーについて

Azure ポータルのMarketplaceから直接Purviewアカウントを作成しようとすると、以下のエラーが発生する場合があります:

```
Marketplace の項目を作成できませんでした
ギャラリー項目が必要です。ギャラリー項目が指定されていません。
```

これは既知の問題で、以下の回避策を使用してください。

---

## 作成方法

### 方法1: リソースグループから作成 (推奨)

Azureポータルで最も確実な方法:

1. [Azure Portal](https://portal.azure.com) にサインイン
2. 対象のサブスクリプションに移動
3. 既存のリソースグループを選択、または新規作成
4. リソースグループ内で **「作成」** ボタンをクリック
5. 検索バーで **「Microsoft Purview」** を検索
6. 検索結果から **「Microsoft Purview」** を選択
7. **「作成」** をクリック
8. 以下の情報を入力:
   - **サブスクリプション**: 対象のサブスクリプション
   - **リソースグループ**: 既存または新規作成
   - **Purview アカウント名**: 一意の名前（グローバルで一意である必要があります）
   - **場所**: リージョン（例: East US 2）
   - **マネージドリソースグループ名**: 自動生成または手動指定
9. **「確認および作成」** → **「作成」** をクリック

**所要時間**: 約5-10分

---

### 方法2: Azure CLI

コマンドラインから作成する方法:

#### ステップ1: リソースプロバイダーの登録

```bash
# Purviewリソースプロバイダーを登録
az provider register --namespace Microsoft.Purview

# 登録状態を確認（"Registered"になるまで待つ）
az provider show --namespace Microsoft.Purview --query "registrationState" -o tsv
```

#### ステップ2: Purviewアカウントの作成

```bash
# 変数を設定
PURVIEW_ACCOUNT_NAME="<your-purview-account-name>"  # グローバルで一意の名前
RESOURCE_GROUP="<your-resource-group>"
LOCATION="eastus2"  # または他のリージョン
MANAGED_RG_NAME="managed-rg-${PURVIEW_ACCOUNT_NAME}"

# Purviewアカウントを作成
az purview account create \
  --name $PURVIEW_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --managed-resource-group-name $MANAGED_RG_NAME
```

#### ステップ3: リソースIDの取得

作成後、このアクセラレータで使用するリソースIDを取得:

```bash
# リソースIDを取得
PURVIEW_RESOURCE_ID=$(az purview account show \
  --name $PURVIEW_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP \
  --query id -o tsv)

# リソースIDを表示（コピーして保存）
echo $PURVIEW_RESOURCE_ID

# azd環境変数として設定
azd env set purviewAccountResourceId "$PURVIEW_RESOURCE_ID"
```

**参考**: [Azure CLI - az purview](https://learn.microsoft.com/en-us/cli/azure/purview/account)

---

### 方法3: Bicep/ARMテンプレート

インフラストラクチャ as Code (IaC) で作成する方法:

#### Bicepテンプレートの例

`purview-account.bicep`:

```bicep
@description('Purview アカウント名（グローバルで一意）')
param purviewAccountName string

@description('デプロイ先のリージョン')
param location string = resourceGroup().location

@description('マネージドリソースグループ名')
param managedResourceGroupName string = 'managed-rg-${purviewAccountName}'

@description('タグ')
param tags object = {}

resource purviewAccount 'Microsoft.Purview/accounts@2021-07-01' = {
  name: purviewAccountName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedResourceGroupName: managedResourceGroupName
    publicNetworkAccess: 'Enabled'  // または 'Disabled' でプライベートエンドポイントを使用
  }
}

output purviewAccountId string = purviewAccount.id
output purviewAccountName string = purviewAccount.name
output purviewEndpoint string = purviewAccount.properties.endpoints.catalog
```

#### デプロイコマンド

```bash
# リソースグループを作成（まだ存在しない場合）
az group create --name <resource-group> --location eastus2

# Bicepテンプレートをデプロイ
az deployment group create \
  --resource-group <resource-group> \
  --template-file purview-account.bicep \
  --parameters purviewAccountName=<unique-name>
```

#### リソースIDの取得

```bash
# デプロイ出力からリソースIDを取得
PURVIEW_RESOURCE_ID=$(az deployment group show \
  --resource-group <resource-group> \
  --name purview-account \
  --query properties.outputs.purviewAccountId.value -o tsv)

# azd環境変数として設定
azd env set purviewAccountResourceId "$PURVIEW_RESOURCE_ID"
```

**参考**: [Microsoft.Purview/accounts - Bicep リソース定義](https://learn.microsoft.com/en-us/azure/templates/microsoft.purview/accounts)

---

### 方法4: Terraform

Terraform を使用する場合:

```hcl
resource "azurerm_purview_account" "example" {
  name                = "example-purview"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "purview_id" {
  value = azurerm_purview_account.example.id
}
```

**参考**: [Terraform - azurerm_purview_account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/purview_account)

---

## 作成後の確認

Purviewアカウントが正常に作成されたことを確認:

```bash
# Azure CLIで確認
az purview account show \
  --name <purview-account-name> \
  --resource-group <resource-group> \
  --query "{Name:name, Location:location, ProvisioningState:provisioningState}" -o table
```

または、[Purview ガバナンスポータル](https://web.purview.azure.com/) にアクセスして、アカウントが表示されることを確認してください。

---

## このアクセラレータでの使用方法

Purviewアカウント作成後、リソースIDを取得して以下のいずれかの方法で設定:

### 方法A: azd環境変数として設定

```bash
azd env set purviewAccountResourceId "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Purview/accounts/<account-name>"
```

### 方法B: infra/main.bicepparam を編集

```bicep
param purviewAccountResourceId = '/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.Purview/accounts/<account-name>'
```

その後、通常通り `azd up` を実行してください。

---

## トラブルシューティング

### エラー: "The subscription is not registered to use namespace 'Microsoft.Purview'"

**解決策**:
```bash
az provider register --namespace Microsoft.Purview
az provider show --namespace Microsoft.Purview --query "registrationState"
```

### エラー: "Purview account name is not available"

Purviewアカウント名はグローバルで一意である必要があります。別の名前を試してください。

### エラー: "Location not supported"

Purviewは一部のリージョンでのみ利用可能です。推奨リージョン: East US, East US 2, West Europe

利用可能なリージョンを確認:
```bash
az provider show --namespace Microsoft.Purview --query "resourceTypes[?resourceType=='accounts'].locations" -o table
```

---

## 参考リンク

- [Microsoft Purview ドキュメント](https://learn.microsoft.com/en-us/purview/)
- [Purview アカウントの作成](https://learn.microsoft.com/en-us/purview/create-catalog-portal)
- [Azure CLI - Purview コマンド](https://learn.microsoft.com/en-us/cli/azure/purview/account)
- [Purview REST API](https://learn.microsoft.com/en-us/rest/api/purview/)

---

## Sources

この情報は以下のソースを参考にしています:

- [Could not create the marketplace item | Purview - Microsoft Q&A](https://learn.microsoft.com/en-us/answers/questions/5696690/could-not-create-the-marketplace-item-purview)
- [Azure Marketplace offering - "Could not create the marketplace offering. Gallery item is required" - Microsoft Q&A](https://learn.microsoft.com/en-us/answers/questions/2287440/azure-marketplace-offering-could-not-create-the-ma)
- [Error: "Could not create the Marketplace item" when I try to create a MS Purview Instance - Microsoft Q&A](https://learn.microsoft.com/en-us/answers/questions/5696986/error-could-not-create-the-marketplace-item-when-i)
