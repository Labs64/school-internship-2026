```shell
curl --request POST "https://go.netlicensing.io/core/v2/rest/licensetemplate" \
  --user "YOUR_USERNAME:YOUR_PASSWORD" \
  --header "Accept: application/json" \
  --header "Content-Type: application/x-www-form-urlencoded" \
  --data-urlencode "productModuleNumber=..." \
  --data-urlencode "number=..." \
  --data-urlencode "name=..." \
  --data-urlencode "licenseType=FEATURE" \
  --data-urlencode "active=true" \
  --data-urlencode "automatic=false" \
  --data-urlencode "hidden=false" \
  --data-urlencode "hideLicenses=false" \
  --data-urlencode "price=10.00" \
  --data-urlencode "currency=EUR" \
  --data-urlencode "planWeight=25" \
  --data-urlencode "description=..." \
  --data-urlencode 'skus={...}'
```
