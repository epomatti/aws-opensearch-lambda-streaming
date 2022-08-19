# aws-opensearch

Create the variables file:

```sh
touch .auto.tfvars
```

Prepare the variables:

```hcl
region      = "sa-east-1"
master_user = "Evandro"
```

Create the infrastructure:

```sh
terraform init
terraform apply -auto-approve
```

Upload data to OpenSearch:

```sh
curl -XPOST -u 'master-user:master-user-password' 'domain-endpoint/_bulk' --data-binary @bulk_movies.json -H 'Content-Type: application/json'
```