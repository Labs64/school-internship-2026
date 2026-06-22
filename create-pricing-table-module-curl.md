```shell
curl --request POST "https://go.netlicensing.io/core/v2/rest/productmodule" \
  --user "apiKey:..." \
  --header "Accept: application/json" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "productNumber=..." \
  --data-urlencode "name=..." \
  --data-urlencode "licensingModel=PricingTable" \
  --data-urlencode "active=true" \
  --data-urlencode 'skudef={"skudef":[...]}'
```
