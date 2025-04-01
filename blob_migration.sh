#!/bin/bash

# Variables for storage accounts and container names
sourceAccountName="yarinstorageaccounta"
destinationAccountName="yarinstorageaccountb"
sourceContainerName="yarinstorageaccounta"
destinationContainerName="yarinstorageaccountb"
resourceGroup="arm"
location="eastus"

# Export the keys for source and destination storage accounts
sourceKey=$(az storage account keys list --resource-group $resourceGroup --account-name $sourceAccountName --query '[0].value' -o tsv)
destinationKey=$(az storage account keys list --resource-group $resourceGroup --account-name $destinationAccountName --query '[0].value' -o tsv)

# Create the Source container if not exist
az storage container create --name $sourceContainerName --account-name $sourceAccountName --account-key $sourceKey

# Create 100 blobs in the source container
for i in $(seq 1 100)
do
    echo "Blob content $i" > "blob_$i.txt"
    # There is an option to overwrite if the file already exists (--overwrite)
    az storage blob upload --container-name $sourceContainerName --file "blob_$i.txt" --name "blob_$i.txt" --account-name $sourceAccountName --account-key $sourceKey
    rm "blob_$i.txt"
done

echo "Blobs created and uploaded"

# Create the Destination container if not exist
az storage container create --name $destinationContainerName --account-name $destinationAccountName --account-key $destinationKey

# Copy multiple blobs from source container to destination container in batch
az storage blob copy start-batch \
    --account-name $destinationAccountName \
    --account-key $destinationKey \
    --destination-container $destinationContainerName \
    --source-account-name $sourceAccountName \
    --source-account-key $sourceKey \
    --source-container $sourceContainerName

echo "Blobs copied successfully!"