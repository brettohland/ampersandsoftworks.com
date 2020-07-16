---
title: "Sending Bearer Authentication Headers in iOS"
date: 2020-07-15T17:05:10-06:00
draft: false
tags: ["swift"]
---

TL;DR: Apple's documentation is lies. Set `httpAdditionalHeaders` on `URLSessionConfiguration`.

I have no idea why Authentication headers are such a pain to use in Cocoa.

A great use case for one is to get some details about a movie from [TMDB](http://themoviedatabase.org)'s new v4 API:

``` bash
curl --request GET \
  --url 'https://api.themoviedb.org/3/movie/76341' \
  --header 'Authorization: Bearer <<access_token>>' \
  --header 'Content-Type: application/json;charset=utf-8'
```

With CURL, you can just arbitrary build whatever kind of response you'd like and go on with your day.

Naively, I thought that it'd be as easy as that using a `NSURLSessionDataTask`, you can set any header values that you want after all:

``` Swift
let movieDetail = URL( //1
    string: "https://api.themoviedb.org/3/movie/76341"
)!
var movieRequest = URLRequest( //2
    url: movieDetail
)
movieRequest.setValue( //3
    "Bearer \(v4apiKey)",
    forHTTPHeaderField: "Authentication"
)
movieRequest.setValue( //4
    "application/json;charset=utf-8",
    forHTTPHeaderField: "Content-Type"
)

let cancellable = URLSession.shared
    .dataTaskPublisher(for: movieRequest) //5
    .sink(receiveCompletion: { completion in
        switch completion {
        case let .failure(reason):
            print(reason)
        case .finished:
            print("Done without errors")
        }
    }) { receivedValue in
        print( //6
            String(data: receivedValue.data, encoding: .utf8) ?? "Unknown"
        )
    }
```

1. Create the URL to the request
2. Create a `URLRequest` object to handle the request
3. Add the "Bearer `<<access_token>>` as an `Authentication` header
4. Set the content type
5. Create the data task `Publisher`
6. Subscribe to the completion closure returned
7. Print out the received data (cast to a String for easy printing) 

```JSON
{
  "status_code" : 7,
  "status_message" : "Invalid API key: You must be granted a valid key.",
  "success" : false
}
```

Even after [several laps around the internet](https://stackoverflow.com/questions/46852680/urlsession-doesnt-pass-authorization-key-in-header-swift-4), the answer is almost always in the official Documentation.

>#### [Reserved HTTP Headers](https://developer.apple.com/documentation/foundation/urlrequest)
>The URL Loading System handles various aspects of the HTTP protocol for you (HTTP 1.1 persistent connections, proxies, authentication, and so on). As part of this support, the URL Loading System takes responsibility for certain HTTP headers:
>
>- `Content-Length`
>- `Authorization`
>- `Connection`
>- `Host`
>- `Proxy-Authenticate`
>- `Proxy-Authorization`
>- `WWW-Authenticate`
>
>If you set a value for one of these reserved headers, the system may ignore the value you set, or overwrite it with its own value, or simply not send it. Moreover, the exact behavior may change over time. To avoid confusing problems like this, do not set these headers directly.

This is for both the headers in the URLRequest [as well as the `httpAdditionalHeaders` in the `URLSessionConfiguration` passed in during creation](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/1411532-httpadditionalheaders). Both places officially recommend against it.

But hey, let's live on the wild side.

``` Swift
let movieDetail = URL( // 1
    string: "https://api.themoviedb.org/3/movie/76341"
)!
var movieRequest = URLRequest( // 2
    url: movieDetail
)
movieRequest.setValue( // 3
    "Bearer <<access-token>>",
    forHTTPHeaderField: "Authentication"
)
movieRequest.setValue( // 4
    "application/json;charset=utf-8",
    forHTTPHeaderField: "Content-Type"
)

var sessionConfiguration = URLSessionConfiguration.default // 5

sessionConfiguration.httpAdditionalHeaders = [
    "Authorization": "Bearer \(v4apiKey)" // 6
]

let session = URLSession(configuration: sessionConfiguration) // 7

let cancellable = session
    .dataTaskPublisher(for: movieRequest) // 8
    .sink(receiveCompletion: { completion in //9
        switch completion {
        case let .failure(reason):
            print(reason)
        case .finished:
            print("Done without errors")
        }
    }) { receivedValue in //10
        print(
            String(data: receivedValue.data, encoding: .utf8) ?? "Unknown"
        )
    }
```

1. Create the URL to the request
2. Create a `URLRequest` object to handle the request
3. Add the "Bearer `<<access_token>>` as an `Authentication` header
4. Set the content type
5. Create a copy of the default `URLSessionConfiguration`
6. Set the Bearer token in the `httpAdditionalHeaders` array
7. Create the `URLSession` with the config with the headers
5. Create the data task `Publisher`
6. Subscribe to the completion closure returned
7. Print out the received data (cast to a String for easy printing) 

And we get:

```
A GIANT BLOG OF JSON RELATED TO MAX MAD FURY ROAD
```

The most concise explanation came [from Quinn at Apple on the developer forums](https://developer.apple.com/forums/thread/89811):

>So, what’s a developer to do?
>
>If you have control over the server then there’s a good way out of this: change the server to pick up the authentication token from a custom header.
>
>If you don’t have control over the server, there’s no good solution.  If I were in your shoes I’d manually set the `Authorization` header. That’s the best of a bad set of alternatives. Critically, lots of folks do this, so whatever mechanism that we eventually introduce to get around this issue will have to be compatible with this approach.",

So there we have it. Straight from the horses Developer Relation mouth. Set the header.