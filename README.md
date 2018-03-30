# Solr as Helm Chart

Package solr as helm chart and release to GKE.

Prepare cluster and helm with the following command:
```
make init setup
```

Release Solr:
```
make release
```

Upgrade Solr:
```
make upgrade
```

Check released charts:
```
make list
```

Delete release
```
make delete
```

