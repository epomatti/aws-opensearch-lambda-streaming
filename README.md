# aws-opensearch

Create the infrastructure:

```sh
terraform init
terraform apply -auto-approve
```

Upload data to OpenSearch:

```sh
curl -XPOST -u 'master-user:master-user-password' 'domain-endpoint/_bulk' --data-binary @bulk_movies.json -H 'Content-Type: application/json'
```