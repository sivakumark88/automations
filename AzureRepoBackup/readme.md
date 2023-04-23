_Pre-requisites:_

1. Azure DevOps organisation with access to Azure repos and Azure Pipelines. 
2. PAT(Personal Access Token) to access ADO.
3. Service connection to Azure Subscription.
4. Azure Storage account with Container created.
5. Storage account access key.

_Step to approach to script:_

1. Make Azure DevOps rest API call to access the ADO.

  ```https://dev.azure.com/<organisation_name>/_apis/git/repositories?api-version=6.1-preview.1```
  
2. Get all the Project information.

3. Make another rest API call to access each project individually.
   ```https://dev.azure.com/<organisation_name>/<project>/_apis/git/repositories?api-version=6.1-preview.1```

4. Get the repository information for each project Separately.

5. Clone each repo and similarly for all the repo's for each project.
   ```git clone --mirror https://<PAT>@dev.azure.com/<organisation_name>/<project>/_git/<repo name>```

6. Upload backed repos to storage account using below command.
   ```az storage blob upload --account-name <storage_account> --account-key <AZURE_STORAGE_ACCOUNT_KEY> --container-name <container_name> --name <Name of the Blob> --file <Source file name> --overwrite true```
