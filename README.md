# checkplease
hackfmi 7 project for fun and profit, but mostly fun.

## API 

JSON RPC in request, plain JSON in response. All arguments are treated as strings.

### Error handling
The standard JSON RPC error codes are used.

### Examples

GetPlaceAndTable
```
curl -v --data '{"method":"GetPlaceAndTable", "params":{"tableID":"1"}}' http://10.0.193.79:9933/api/
* Hostname was NOT found in DNS cache
*   Trying 10.0.193.79...
* Connected to 10.0.193.79 (10.0.193.79) port 9933 (#0)
> POST /api/ HTTP/1.1
> User-Agent: curl/7.35.0
> Host: 10.0.193.79:9933
> Accept: */*
> Content-Length: 55
> Content-Type: application/x-www-form-urlencoded
> 
* upload completely sent off: 55 out of 55 bytes
< HTTP/1.1 200 OK
< Access-Control-Allow-Origin: *
< Content-Type: text/plain; charset=utf-8
< X-Content-Type-Options: nosniff
< Date: Sat, 28 May 2016 10:49:47 GMT
< Content-Length: 183
< 
{"ID":1,"IDHash":"1","PlaceID":1,"PreferencesJSON":"{\"name\":\"Sahara Lounge\"}","MenuItems":[{"ID":1,"Name":"Call for waiter","Ordering":1},{"ID":10,"Name":"Pizza","Ordering":30}]}
* Connection #0 to host 10.0.193.79 left intact

GetPendingRequests
```
curl -v --data '{"method":"GetPendingRequests", "params":{"placeID":"1"}}' http://10.0.193.79:9933/api/
* Hostname was NOT found in DNS cache
*   Trying 10.0.193.79...
* Connected to 10.0.193.79 (10.0.193.79) port 9933 (#0)
> POST /api/ HTTP/1.1
> User-Agent: curl/7.35.0
> Host: 10.0.193.79:9933
> Accept: */*
> Content-Length: 57
> Content-Type: application/x-www-form-urlencoded
> 
* upload completely sent off: 57 out of 57 bytes
< HTTP/1.1 200 OK
< Access-Control-Allow-Origin: *
< Content-Type: text/plain; charset=utf-8
< X-Content-Type-Options: nosniff
< Date: Sat, 28 May 2016 10:53:33 GMT
< Content-Length: 589
< 
[{"ID":51,"TableID":1,"TableNumber":"1","MenuItemID":1,"MenuItemName":"Call for waiter","PlaceID":1,"InsertedAt":"2016-05-28T04:54:23.20947Z","InsertedBy":0,"UpdatedAt":"","UpdatedBy":0,"StateID":0},{"ID":87,"TableID":2,"TableNumber":"2","MenuItemID":10,"MenuItemName":"Pizza","PlaceID":1,"InsertedAt":"2016-05-28T06:14:45.781865Z","InsertedBy":0,"UpdatedAt":"","UpdatedBy":0,"StateID":0},{"ID":88,"TableID":2,"TableNumber":"2","MenuItemID":1,"MenuItemName":"Call for waiter","PlaceID":1,"InsertedAt":"2016-05-28T06:24:51.939957Z","InsertedBy":0,"UpdatedAt":"","UpdatedBy":0,"StateID":0}]
* Connection #0 to host 10.0.193.79 left intact

```
curl -v --data '{"method":"GetPlaceAndTable", "params":{"tableID":"1"}}' http://10.0.193.79:9933/api/
* Hostname was NOT found in DNS cache
*   Trying 10.0.193.79...
* Connected to 10.0.193.79 (10.0.193.79) port 9933 (#0)
> POST /api/ HTTP/1.1
> User-Agent: curl/7.35.0
> Host: 10.0.193.79:9933
> Accept: */*
> Content-Length: 55
> Content-Type: application/x-www-form-urlencoded
>
* upload completely sent off: 55 out of 55 bytes
< HTTP/1.1 200 OK
< Access-Control-Allow-Origin: *
< Content-Type: text/plain; charset=utf-8
< X-Content-Type-Options: nosniff
< Date: Sat, 28 May 2016 10:52:17 GMT
< Content-Length: 183
<
{"ID":1,"IDHash":"1","PlaceID":1,"PreferencesJSON":"{\"name\":\"Sahara Lounge\"}","MenuItems":[{"ID":1,"Name":"Call for waiter","Ordering":1},{"ID":10,"Name":"Pizza","Ordering":30}]}
* Connection #0 to host 10.0.193.79 left intact
```

GetRequest
```
curl -v --data '{"method":"GetRequest", "params":{"requestID":"10"}}' http://10.0.193.79:9933/api/
* Hostname was NOT found in DNS cache
*   Trying 10.0.193.79...
* Connected to 10.0.193.79 (10.0.193.79) port 9933 (#0)
> POST /api/ HTTP/1.1
> User-Agent: curl/7.35.0
> Host: 10.0.193.79:9933
> Accept: */*
> Content-Length: 52
> Content-Type: application/x-www-form-urlencoded
> 
* upload completely sent off: 52 out of 52 bytes
< HTTP/1.1 200 OK
< Access-Control-Allow-Origin: *
< Content-Type: text/plain; charset=utf-8
< X-Content-Type-Options: nosniff
< Date: Sat, 28 May 2016 10:55:00 GMT
< Content-Length: 156
< 
{"ID":10,"TableID":1,"TableNumber":"","MenuItemID":1,"MenuItemName":"","PlaceID":1,"InsertedAt":"","InsertedBy":0,"UpdatedAt":"","UpdatedBy":0,"StateID":0}
* Connection #0 to host 10.0.193.79 left intact

```

curl --data '{"method":"AckRequest", "params":{"requestID":"10"}}' 192.168.1.5:9933/api/
curl -v --data '{"method":"AckRequest", "params":{"requestID":"10"}}' http://10.0.193.79:9933/api/
* Hostname was NOT found in DNS cache
*   Trying 10.0.193.79...
* Connected to 10.0.193.79 (10.0.193.79) port 9933 (#0)
> POST /api/ HTTP/1.1
> User-Agent: curl/7.35.0
> Host: 10.0.193.79:9933
> Accept: */*
> Content-Length: 52
> Content-Type: application/x-www-form-urlencoded
> 
* upload completely sent off: 52 out of 52 bytes
< HTTP/1.1 200 OK
< Access-Control-Allow-Origin: *
< Content-Type: text/plain; charset=utf-8
< X-Content-Type-Options: nosniff
< Date: Sat, 28 May 2016 10:56:41 GMT
< Content-Length: 15
< 
{"status":"ok"}
* Connection #0 to host 10.0.193.79 left intact


AddRequest
```
```

## API Benchmarks

Simply put, with 1 or 2 5$ servers, you can take all the traffic you will ever need.
Tool for benchmark is ab. No OS, DB optimizations have been made. This was tested on a 5$ digital ocean instance.

Get Pending requests (20 requests):
Requests per second:    16098.67 [#/sec] (mean)

AckRequest:
Requests per second:    16345.93 [#/sec] (mean)

AddRequest:
Requests per second:    16211.71 [#/sec] (mean)

GetRequest
Requests per second:    16035.03 [#/sec] (mean)


