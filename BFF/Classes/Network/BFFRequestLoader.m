//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "BFFRequestLoader.h"

// Network
#import "BFFGlobalNetwork.h"
#import "BFFURLRequest.h"
#import "BFFURLRequestDelegate.h"
#import "BFFURLRequestQueue.h"
#import "BFFURLResponse.h"

// Network (private)
#import "BFFURLRequestQueueInternal.h"

// Core
#import "BFFNSObjectAdditions.h"
#import "BFFDebug.h"
#import "BFFDebugFlags.h"

static const NSInteger kLoadMaxRetries = 2;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFRequestLoader

@synthesize urlPath             = _urlPath;
@synthesize requests            = _requests;
@synthesize cacheKey            = _cacheKey;
@synthesize cachePolicy         = _cachePolicy;
@synthesize cacheExpirationAge  = _cacheExpirationAge;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initForRequest:(BFFURLRequest*)request queue:(BFFURLRequestQueue*)queue {
  if (self = [super init]) {
    _urlPath            = [request.urlPath copy];
    _queue              = queue;
    _cacheKey           = [request.cacheKey retain];
    _cachePolicy        = request.cachePolicy;
    _cacheExpirationAge = request.cacheExpirationAge;
    _requests           = [[NSMutableArray alloc] init];
    _retriesLeft        = kLoadMaxRetries;

    [self addRequest:request];
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_connection cancel];
  BFF_RELEASE_SAFELY(_connection);
  BFF_RELEASE_SAFELY(_response);
  BFF_RELEASE_SAFELY(_responseData);
  BFF_RELEASE_SAFELY(_urlPath);
  BFF_RELEASE_SAFELY(_cacheKey);
  BFF_RELEASE_SAFELY(_requests);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connectToURL:(NSURL*)URL {
  BFFDCONDITIONLOG(BFFDFLAG_URLREQUEST, @"Connecting to %@", _urlPath);
  BFFNetworkRequestStarted();

  BFFURLRequest* request = _requests.count == 1 ? [_requests objectAtIndex:0] : nil;
  
#ifdef BINARYFINERY_COOKIE_HACK
	NSURLRequest* URLRequest = [request createNSURLRequest];
#else
	NSURLRequest* URLRequest = [_queue createNSURLRequest:request URL:URL];
#endif
  _connection = [[NSURLConnection alloc] initWithRequest:URLRequest delegate:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dispatchLoadedBytes:(NSInteger)bytesLoaded expected:(NSInteger)bytesExpected {
  for (BFFURLRequest* request in [[_requests copy] autorelease]) {
    request.totalBytesLoaded = bytesLoaded;
    request.totalBytesExpected = bytesExpected;

    for (id<BFFURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(requestDidUploadData:)]) {
        [delegate requestDidUploadData:request];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addRequest:(BFFURLRequest*)request {
  // TODO (jverkoey April 27, 2010): Look into the repercussions of adding a request with
  // different properties.
  //BFFDASSERT([_urlPath isEqualToString:request.urlPath]);
  //BFFDASSERT(_cacheKey == request.cacheKey);
  //BFFDASSERT(_cachePolicy == request.cachePolicy);
  //BFFDASSERT(_cacheExpirationAge == request.cacheExpirationAge);

  [_requests addObject:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeRequest:(BFFURLRequest*)request {
  [_requests removeObject:request];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)load:(NSURL*)URL {
  if (!_connection) {
    [self connectToURL:URL];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadSynchronously:(NSURL*)URL {
  // This method simulates an asynchronous network connection. If your delegate isn't being called
  // correctly, this would be the place to start tracing for errors.
  BFFNetworkRequestStarted();

  BFFURLRequest* request = _requests.count == 1 ? [_requests objectAtIndex:0] : nil;
  NSURLRequest* URLRequest = [_queue createNSURLRequest:request URL:URL];

  NSHTTPURLResponse* response = nil;
  NSError* error = nil;
  NSData* data = [NSURLConnection
                  sendSynchronousRequest: URLRequest
                  returningResponse: &response
                  error: &error];

  if (nil != error) {
    BFFNetworkRequestStopped();

    BFF_RELEASE_SAFELY(_responseData);
    BFF_RELEASE_SAFELY(_connection);

    [_queue loader:self didFailLoadWithError:error];
  } else {
    [self connection:nil didReceiveResponse:(NSHTTPURLResponse*)response];
    [self connection:nil didReceiveData:data];

    [self connectionDidFinishLoading:nil];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)cancel:(BFFURLRequest*)request {
  NSUInteger requestIndex = [_requests indexOfObject:request];
  if (requestIndex != NSNotFound) {
    request.isLoading = NO;

    for (id<BFFURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(requestDidCancelLoad:)]) {
        [delegate requestDidCancelLoad:request];
      }
    }

    [_requests removeObjectAtIndex:requestIndex];
  }

  if (![_requests count]) {
    [_queue loaderDidCancel:self wasLoading:!!_connection];
    if (nil != _connection) {
      BFFNetworkRequestStopped();
      [_connection cancel];
      BFF_RELEASE_SAFELY(_connection);
    }
    return NO;

  } else {
    return YES;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSError*)processResponse:(NSHTTPURLResponse*)response data:(id)data {
  for (BFFURLRequest* request in _requests) {
    NSError* error = [request.response request:request processResponse:response data:data];
    if (error) {
      return error;
    }
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dispatchError:(NSError*)error {
  for (BFFURLRequest* request in [[_requests copy] autorelease]) {
    request.isLoading = NO;

    for (id<BFFURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
        [delegate request:request didFailLoadWithError:error];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dispatchLoaded:(NSDate*)timestamp {
  for (BFFURLRequest* request in [[_requests copy] autorelease]) {
    request.timestamp = timestamp;
    request.isLoading = NO;

    for (id<BFFURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(requestDidFinishLoad:)]) {
        [delegate requestDidFinishLoad:request];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dispatchAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge {
  for (BFFURLRequest* request in [[_requests copy] autorelease]) {

    for (id<BFFURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(request:didReceiveAuthenticationChallenge:)]) {
        [delegate request:request didReceiveAuthenticationChallenge:challenge];
      }
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancel {
  NSArray* requestsToCancel = [_requests copy];
  for (id request in requestsToCancel) {
    [self cancel:request];
  }
  [requestsToCancel release];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSURLConnectionDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSHTTPURLResponse*)response {
  _response = [response retain];
  NSDictionary* headers = [response allHeaderFields];
  int contentLength = [[headers objectForKey:@"Content-Length"] intValue];

  // If you hit this assertion it's because a massive file is about to be downloaded.
  // If you're sure you want to do this, add the following line to your app delegate startup
  // method. Setting the max content length to zero allows anything to go through. If you just
  // want to raise the limit, set it to any positive byte size.
  // [[BFFURLRequestQueue mainQueue] setMaxContentLength:0]
  BFFDASSERT(0 == _queue.maxContentLength || contentLength <=_queue.maxContentLength);

  if (contentLength > _queue.maxContentLength && _queue.maxContentLength) {
    BFFDCONDITIONLOG(BFFDFLAG_URLREQUEST, @"MAX CONTENT LENGTH EXCEEDED (%d) %@",
                    contentLength, _urlPath);
    [self cancel];
  }

  _responseData = [[NSMutableData alloc] initWithCapacity:contentLength];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
  [_responseData appendData:data];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSCachedURLResponse *)connection: (NSURLConnection *)connection
                  willCacheResponse: (NSCachedURLResponse *)cachedResponse {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)           connection: (NSURLConnection *)connection
              didSendBodyData: (NSInteger)bytesWritten
            totalBytesWritten: (NSInteger)totalBytesWritten
    totalBytesExpectedToWrite: (NSInteger)totalBytesExpectedToWrite {
  [self dispatchLoadedBytes:totalBytesWritten expected:totalBytesExpectedToWrite];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
  BFFNetworkRequestStopped();

  BFFDCONDITIONLOG(BFFDFLAG_ETAGS, @"Response status code: %d", _response.statusCode);

  // We need to accept valid HTTP status codes, not only 200.
  if (_response.statusCode >= 200 && _response.statusCode < 300) {
    [_queue loader:self didLoadResponse:_response data:_responseData];

  } else if (_response.statusCode == 304) {
    [_queue loader:self didLoadUnmodifiedResponse:_response];

  } else {
    BFFDCONDITIONLOG(BFFDFLAG_URLREQUEST, @"  FAILED LOADING (%d) %@",
                    _response.statusCode, _urlPath);
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:_response.statusCode
                                     userInfo:nil];
    [_queue loader:self didFailLoadWithError:error];
  }

  BFF_RELEASE_SAFELY(_responseData);
  BFF_RELEASE_SAFELY(_connection);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
  BFFDCONDITIONLOG(BFFDFLAG_URLREQUEST, @"  RECEIVED AUTH CHALLENGE LOADING %@ ", _urlPath);
  [_queue loader:self didReceiveAuthenticationChallenge:challenge];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  BFFDCONDITIONLOG(BFFDFLAG_URLREQUEST, @"  FAILED LOADING %@ FOR %@", _urlPath, error);

  BFFNetworkRequestStopped();

  BFF_RELEASE_SAFELY(_responseData);
  BFF_RELEASE_SAFELY(_connection);

  if ([error.domain isEqualToString:NSURLErrorDomain] && error.code == NSURLErrorCannotFindHost
      && _retriesLeft) {
    // If there is a network error then we will wait and retry a few times in case
    // it was just a temporary blip in connectivity.
    --_retriesLeft;
    [self load:[NSURL URLWithString:_urlPath]];

  } else {
    [_queue loader:self didFailLoadWithError:error];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Accessors


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
  return !!_connection;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// Deprecated
- (NSString*)URL {
  return _urlPath;
}


@end
