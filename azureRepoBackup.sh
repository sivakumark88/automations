#Declaring Variables
PAT=$1
storage_account=$2
container_name=$3
AZURE_STORAGE_ACCOUNT_KEY=$4
organisation_name=$5
d=$(date +%Y-%m-%d)

##API call to Azure DevOps to access the organisation
projects=$(curl -u $(az account show | jq -r .user.name):$PAT --request GET "https://dev.azure.com/$organisation_name/_apis/projects?api-version=2.0")
echo "projects:$projects"

##Collect all the project names from the organisation
projectlist=$(echo "$projects" | jq '.value[].name' | sed -e 's/^"//' -e 's/"$//')
echo "Project available in the org:$organisation_name are below.."
echo $projectlist

##Loop each project and access repos in that
for project in "${projectlist[@]}"
do
  repositories=$(curl -u $(az account show | jq -r .user.name):$PAT --request GET "https://dev.azure.com/$organisation_name/$project/_apis/git/repositories?api-version=6.1-preview.1")
  repo=$(echo "$repositories" | jq '.value[].name' | sed -e 's/^"//' -e 's/"$//')
  echo "Backup for Projectname: $project starting.."
  echo "Repositories available for the project:$project are:"
  echo "$repo"
  mkdir $project-backup-$d
  for variable in $repo  ##Loop each repo and clone it
  do
    echo "Projectname: $project"
    echo "Repository: $variable"
    git clone --mirror https://$PAT@dev.azure.com/$organisation_name/$project/_git/$variable  ##Clone repos
    zip -r $variable-backup-$d.zip $variable.git
    zipping=$variable-backup-$d.zip
    cp $zipping $project-backup-$d  ##Move cloned repos to a common directory
    echo "Repository:$variable is cloned and converted to zip format $zipping"
  done
  pwd
  ls -lrth
  zip -r $project-backup-$d.zip $project-backup-$d
  echo "Backing up all the project:$project repos to Storage account"

  ##Copy Directory containing repositories backups to a Storage Account Container
  az storage blob upload --account-name $storage_account --account-key $AZURE_STORAGE_ACCOUNT_KEY --container-name $container_name --name $project/$project-backup-$d.zip --file ./$project-backup-$d.zip --overwrite true
done
