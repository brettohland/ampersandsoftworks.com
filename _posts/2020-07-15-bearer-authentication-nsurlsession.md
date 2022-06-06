---
layout: post
title: Sending Bearer Auth Tokens in iOS
description: It turns out that you have to break some rules to set bearer authentication tokens…
date: 2020-07-15T17:05:10-06:00
tags: [swift, development]
---

#### TL;DR: Apple's documentation is lies. Set `httpAdditionalHeaders` on `URLSessionConfiguration`.

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

{% splash %}
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
{% endsplash %}

1. Create the URL to the request
2. Create a `URLRequest` object to handle the request
3. Add the "Bearer `<<access_token>>` as an `Authentication` header
4. Set the content type
5. Create the data task `Publisher`
6. Subscribe to the completion closure returned
7. Print out the received data (cast to a String for easy printing) 

``` json
{
  "status_code" : 7,
  "status_message" : "Invalid API key: You must be granted a valid key.",
  "success" : false
}
```

Even after [several laps around the internet](https://stackoverflow.com/questions/46852680/urlsession-doesnt-pass-authorization-key-in-header-swift-4), the answer is almost always in the official Documentation.

[From the URLRequest documentation](https://developer.apple.com/documentation/foundation/urlrequest)

<figure>
  <blockquote cite="https://developer.apple.com/documentation/foundation/urlrequest">
    <p>Reserved HTTP Headers</p>
    <p>The URL Loading System handles various aspects of the HTTP protocol for you (HTTP 1.1 persistent connections, proxies, authentication, and so on). As part of this support, the URL Loading System takes responsibility for certain HTTP headers:</p>
    <ul>
      <li><code>Content-Length</code></li>
      <li><code>Authorization</code></li>
      <li><code>Connection</code></li>
      <li><code>Host</code></li>
      <li><code>Proxy-Authenticate</code></li>
      <li><code>Proxy-Authorization</code></li>
      <li><code>WWW-Authenticate</code></li>
    </ul>
  </blockquote>
</figure>

This is for both the headers in the URLRequest [as well as the `httpAdditionalHeaders` in the `URLSessionConfiguration` passed in during creation](https://developer.apple.com/documentation/foundation/urlsessionconfiguration/1411532-httpadditionalheaders). Both places officially recommend against it.

But hey, let's live on the wild side.

{% splash %}

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

{% endsplash %}

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

<figure class="quote">
  <blockquote cite="https://developer.apple.com/forums/thread/89811">
    <p>So, what’s a developer to do?</p>
    <p>If you have control over the server then there’s a good way out of this: change the server to pick up the authentication token from a custom header.</p>
    <p>If you don’t have control over the server, there’s no good solution.  If I were in your shoes I’d manually set the <code>Authorization</code> header. That’s the best of a bad set of alternatives. Critically, lots of folks do this, so whatever mechanism that we eventually introduce to get around this issue will have to be compatible with this approach.",</p>
  </blockquote>
  <figcaption>&mdash;Quinn, <cite>Apple Developer Forums</cite></figcaption>
</figure>

So there we have it. Straight from the horses Developer Relation mouth: 

#### TL;DR: Apple's documentation is lies. Set `httpAdditionalHeaders` on `URLSessionConfiguration`.