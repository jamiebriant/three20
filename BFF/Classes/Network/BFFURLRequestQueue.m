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

#import "BFFURLRequestQueue.h"

// Network
#import "BFFGlobalNetwork.h"
#import "BFFURLRequest.h"
#import "BFFURLRequestDelegate.h"
#import "BFFUserInfo.h"
#import "BFFURLResponse.h"
#import "BFFURLCache.h"

// Network (Private)
#import "BFFRequestLoader.h"

// Core
#import "BFFGlobalCore.h"
#import "BFFGlobalCorePaths.h"
#import "BFFDebugFlags.h"
#import "BFFDebug.h"

static const NSTimeInterval kFlushDelay = 0.3;
static const NSTimeInterval kTimeout = 300.0;
static const NSInteger kMaxConcurrentLoads = 5;
static NSUInteger kDefaultMaxContentLength = 150000;

static BFFURLRequestQueue* gMainQueue = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFURLRequestQueue

@synthesize maxContentLength        = _maxContentLength;
@synthesize userAgent               = _userAgent;
@synthesize suspended               = _suspended;
@synthesize imageCompressionQuality = _imageCompressionQuality;


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFURLRequestQueue*)mainQueue {
  if (!gMainQueue) {
    gMainQueue = [[BFFURLRequestQueue alloc] init];
  }
  return gMainQueue;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (void)setMainQueue:(BFFURLRequestQueue*)queue {
  if (gMainQueue != queue) {
    [gMainQueue release];
    gMainQueue = [queue retain];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
  if (self == [super init]) {
    _loaders = [[NSMutableDictionary alloc] init];
    _loaderQueue = [[NSMutableArray alloc] init];
    _maxContentLength = kDefaultMaxContentLength;
    _imageCompressionQuality = 0.75;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_loaderQueueTimer invalidate];
  BFF_RELEASE_SAFELY(_loaders);
  BFF_RELEASE_SAFELY(_loaderQueue);
  BFF_RELEASE_SAFELY(_userAgent);
  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// TODO (jverkoey May 3, 2010): Clean up this redundant code.
- (BOOL)dataExistsInBundle:(NSString*)URL {
  NSString* path = BFFPathForBundleResource([URL substringFromIndex:9]);
  NSFileManager* fm = [NSFileManager defaultManager];
  return [fm fileExistsAtPath:path];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)dataExistsInDocuments:(NSString*)URL {
  NSString* path = BFFPathForDocumentsResource([URL substringFromIndex:12]);
  NSFileManager* fm = [NSFileManager defaultManager];
  return [fm fileExistsAtPath:path];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSData*)loadFromBundle:(NSString*)URL error:(NSError**)error {
  NSString* path = BFFPathForBundleResource([URL substringFromIndex:9]);
  NSFileManager* fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:path]) {
    return [NSData dataWithContentsOfFile:path];
  } else if (error) {
    *error = [NSError errorWithDomain:NSCocoaErrorDomain
                      code:NSFileReadNoSuchFileError userInfo:nil];
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSData*)loadFromDocuments:(NSString*)URL error:(NSError**)error {
  NSString* path = BFFPathForDocumentsResource([URL substringFromIndex:12]);
  NSFileManager* fm = [NSFileManager defaultManager];
  if ([fm fileExistsAtPath:path]) {
    return [NSData dataWithContentsOfFile:path];
  } else if (error) {
    *error = [NSError errorWithDomain:NSCocoaErrorDomain
                      code:NSFileReadNoSuchFileError userInfo:nil];
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadFromCache: (NSString*)URL
             cacheKey: (NSString*)cacheKey
              expires: (NSTimeInterval)expirationAge
             fromDisk: (BOOL)fromDisk
                 data: (id*)data
                error: (NSError**)error
            timestamp: (NSDate**)timestamp {
  BFFDASSERT(nil != data);

  if (nil == data) {
    return NO;
  }

  UIImage* image = [[BFFURLCache sharedCache] imageForURL:URL fromDisk:fromDisk];

  if (nil != image) {
    *data = image;
    return YES;

  } else if (fromDisk) {
    if (BFFIsBundleURL(URL)) {
      *data = [self loadFromBundle:URL error:error];
      return YES;

    } else if (BFFIsDocumentsURL(URL)) {
      *data = [self loadFromDocuments:URL error:error];
      return YES;

    } else {
      *data = [[BFFURLCache sharedCache] dataForKey:cacheKey expires:expirationAge
                                        timestamp:timestamp];
      if (*data) {
        return YES;
      }
    }
  }

  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)cacheDataExists: (NSString*)URL
               cacheKey: (NSString*)cacheKey
                expires: (NSTimeInterval)expirationAge
               fromDisk: (BOOL)fromDisk {
  BOOL hasData = [[BFFURLCache sharedCache] hasImageForURL:URL fromDisk:fromDisk];

  if (!hasData && fromDisk) {
    if (BFFIsBundleURL(URL)) {
      hasData = [self dataExistsInBundle:URL];

    } else if (BFFIsDocumentsURL(URL)) {
      hasData = [self dataExistsInDocuments:URL];

    } else {
      hasData = [[BFFURLCache sharedCache] hasDataForKey:cacheKey expires:expirationAge];
    }
  }

  return hasData;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)loadRequestFromCache:(BFFURLRequest*)request {
  if (!request.cacheKey) {
    request.cacheKey = [[BFFURLCache sharedCache] keyForURL:request.urlPath];
  }

  if (IS_MASK_SET(request.cachePolicy, BFFURLRequestCachePolicyEtag)) {
    // Etags always make the request. The request headers will then include the etag.
    // - If there is new data, server returns 200 with data.
    // - Otherwise, returns a 304, with empty request body.
    return NO;

  } else if (request.cachePolicy & (BFFURLRequestCachePolicyDisk|BFFURLRequestCachePolicyMemory)) {
    id data = nil;
    NSDate* timestamp = nil;
    NSError* error = nil;

    if ([self loadFromCache:request.urlPath cacheKey:request.cacheKey
              expires:request.cacheExpirationAge
              fromDisk:!_suspended && (request.cachePolicy & BFFURLRequestCachePolicyDisk)
              data:&data error:&error timestamp:&timestamp]) {
      request.isLoading = NO;

      if (!error) {
        error = [request.response request:request processResponse:nil data:data];
      }

      if (error) {
        for (id<BFFURLRequestDelegate> delegate in request.delegates) {
          if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
            [delegate request:request didFailLoadWithError:error];
          }
        }
      } else {
        request.timestamp = timestamp ? timestamp : [NSDate date];
        request.respondedFromCache = YES;

        for (id<BFFURLRequestDelegate> delegate in request.delegates) {
          if ([delegate respondsToSelector:@selector(requestDidFinishLoad:)]) {
            [delegate requestDidFinishLoad:request];
          }
        }
      }

      return YES;
    }
  }

  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)executeLoader:(BFFRequestLoader*)loader {
  id data = nil;
  NSDate* timestamp = nil;
  NSError* error = nil;

  if ((loader.cachePolicy & (BFFURLRequestCachePolicyDisk|BFFURLRequestCachePolicyMemory))
      && [self loadFromCache:loader.urlPath cacheKey:loader.cacheKey
               expires:loader.cacheExpirationAge
               fromDisk:loader.cachePolicy & BFFURLRequestCachePolicyDisk
               data:&data error:&error timestamp:&timestamp]) {
    [_loaders removeObjectForKey:loader.cacheKey];

    if (!error) {
      error = [loader processResponse:nil data:data];
    }
    if (error) {
      [loader dispatchError:error];
    } else {
      [loader dispatchLoaded:timestamp];
    }
  } else {
    ++_totalLoading;
    [loader load:[NSURL URLWithString:loader.urlPath]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadNextInQueueDelayed {
  if (!_loaderQueueTimer) {
    _loaderQueueTimer = [NSTimer scheduledTimerWithTimeInterval:kFlushDelay target:self
      selector:@selector(loadNextInQueue) userInfo:nil repeats:NO];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loadNextInQueue {
  _loaderQueueTimer = nil;

  for (int i = 0;
       i < kMaxConcurrentLoads && _totalLoading < kMaxConcurrentLoads
       && _loaderQueue.count;
       ++i) {
    BFFRequestLoader* loader = [[_loaderQueue objectAtIndex:0] retain];
    [_loaderQueue removeObjectAtIndex:0];
    [self executeLoader:loader];
    [loader release];
  }

  if (_loaderQueue.count && !_suspended) {
    [self loadNextInQueueDelayed];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeLoader:(BFFRequestLoader*)loader {
  --_totalLoading;
  [_loaders removeObjectForKey:loader.cacheKey];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setSuspended:(BOOL)isSuspended {
  BFFDCONDITIONLOG(BFFDFLAG_URLREQUEST, @"SUSPEND LOADING %d", isSuspended);
  _suspended = isSuspended;

  if (!_suspended) {
    [self loadNextInQueue];
  } else if (_loaderQueueTimer) {
    [_loaderQueueTimer invalidate];
    _loaderQueueTimer = nil;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)sendRequest:(BFFURLRequest*)request {
  if ([self loadRequestFromCache:request]) {
    return YES;
  }

  for (id<BFFURLRequestDelegate> delegate in request.delegates) {
    if ([delegate respondsToSelector:@selector(requestDidStartLoad:)]) {
      [delegate requestDidStartLoad:request];
    }
  }

  // If the url is empty, fail.
  if (!request.urlPath.length) {
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
    for (id<BFFURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
        [delegate request:request didFailLoadWithError:error];
      }
    }
    return NO;
  }

  request.isLoading = YES;

  BFFRequestLoader* loader = nil;

  // If we're not POSTing or PUTting data, let's see if we can jump on an existing request.
  if (![request.httpMethod isEqualToString:@"POST"]
      && ![request.httpMethod isEqualToString:@"PUT"]) {
    // Next, see if there is an active loader for the URL and if so join that bandwagon.
    loader = [_loaders objectForKey:request.cacheKey];
    if (loader) {
      [loader addRequest:request];
      return NO;
    }
  }

  // Finally, create a new loader and hit the network (unless we are suspended)
  loader = [[BFFRequestLoader alloc] initForRequest:request queue:self];
  [_loaders setObject:loader forKey:request.cacheKey];
  if (_suspended || _totalLoading == kMaxConcurrentLoads) {
    [_loaderQueue addObject:loader];
  } else {
    ++_totalLoading;
    [loader load:[NSURL URLWithString:request.urlPath]];
  }
  [loader release];

  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)sendSynchronousRequest:(BFFURLRequest*)request {
  if ([self loadRequestFromCache:request]) {
    return YES;
  }

  for (id<BFFURLRequestDelegate> delegate in request.delegates) {
    if ([delegate respondsToSelector:@selector(requestDidStartLoad:)]) {
      [delegate requestDidStartLoad:request];
    }
  }

  if (!request.urlPath.length) {
    NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorBadURL userInfo:nil];
    for (id<BFFURLRequestDelegate> delegate in request.delegates) {
      if ([delegate respondsToSelector:@selector(request:didFailLoadWithError:)]) {
        [delegate request:request didFailLoadWithError:error];
      }
    }
    return NO;
  }

  request.isLoading = YES;

  // Finally, create a new loader and hit the network (unless we are suspended)
  BFFRequestLoader* loader = [[BFFRequestLoader alloc] initForRequest:request queue:self];

  // Should be decremented eventually by loadSynchronously
  ++_totalLoading;

  [loader loadSynchronously:[NSURL URLWithString:request.urlPath]];
  BFF_RELEASE_SAFELY(loader);

  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancelRequest:(BFFURLRequest*)request {
  if (request) {
    BFFRequestLoader* loader = [_loaders objectForKey:request.cacheKey];
    if (loader) {
      [loader retain];
      if (![loader cancel:request]) {
        [_loaderQueue removeObject:loader];
      }
      [loader release];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancelRequestsWithDelegate:(id)delegate {
  NSMutableArray* requestsToCancel = nil;

  for (BFFRequestLoader* loader in [_loaders objectEnumerator]) {
    for (BFFURLRequest* request in loader.requests) {
      for (id<BFFURLRequestDelegate> requestDelegate in request.delegates) {
        if (delegate == requestDelegate) {
          if (!requestsToCancel) {
            requestsToCancel = [NSMutableArray array];
          }
          [requestsToCancel addObject:request];
          break;
        }
      }

      if ([request.userInfo isKindOfClass:[BFFUserInfo class]]) {
        BFFUserInfo* userInfo = request.userInfo;
        if (userInfo.weakRef && userInfo.weakRef == delegate) {
          if (!requestsToCancel) {
            requestsToCancel = [NSMutableArray array];
          }
          [requestsToCancel addObject:request];
        }
      }
    }
  }

  for (BFFURLRequest* request in requestsToCancel) {
    [self cancelRequest:request];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)cancelAllRequests {
  for (BFFRequestLoader* loader in [[[_loaders copy] autorelease] objectEnumerator]) {
    [loader cancel];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSURLRequest*)createNSURLRequest:(BFFURLRequest*)request URL:(NSURL*)URL {
  if (!URL) {
    URL = [NSURL URLWithString:request.urlPath];
  }

  NSMutableURLRequest* URLRequest = [NSMutableURLRequest requestWithURL:URL
                                    cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                    timeoutInterval:kTimeout];

  if (self.userAgent) {
      [URLRequest setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
  }

  if (request) {
    [URLRequest setHTTPShouldHandleCookies:request.shouldHandleCookies];

    NSString* method = request.httpMethod;
    if (method) {
      [URLRequest setHTTPMethod:method];
    }

    NSString* contentType = request.contentType;
    if (contentType) {
      [URLRequest setValue:contentType forHTTPHeaderField:@"Content-Type"];
    }

    NSData* body = request.httpBody;
    if (body) {
      [URLRequest setHTTPBody:body];
    }

    NSDictionary* headers = request.headers;
    for (NSString *key in [headers keyEnumerator]) {
      [URLRequest setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }

    if (![[BFFURLCache sharedCache] disableDiskCache]
        && IS_MASK_SET(request.cachePolicy, BFFURLRequestCachePolicyEtag)) {
      NSString* etag = [[BFFURLCache sharedCache] etagForKey:request.cacheKey];
      BFFDCONDITIONLOG(BFFDFLAG_ETAGS, @"Etag: %@", etag);

      if (BFFIsStringWithAnyText(etag)
          && [self cacheDataExists: request.urlPath
                          cacheKey: request.cacheKey
                           expires: request.cacheExpirationAge
                          fromDisk: !_suspended
                                    && (request.cachePolicy & BFFURLRequestCachePolicyDisk)]) {
        // By setting the etag here, we let the server know what the last "version" of the file
        // was that we saw. If the file has changed since this etag, we'll get data back in our
        // response. Otherwise we'll get a 304.
        [URLRequest setValue:etag forHTTPHeaderField:@"If-None-Match"];
      }
    }
  }

  return URLRequest;
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFURLRequestQueue (BFFRequestLoader)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)     loader: (BFFRequestLoader*)loader
    didLoadResponse: (NSHTTPURLResponse*)response
               data: (id)data {
  [loader retain];
  [self removeLoader:loader];

  NSError* error = [loader processResponse:response data:data];
  if (error) {
    [loader dispatchError:error];

  } else {
    if (!(loader.cachePolicy & BFFURLRequestCachePolicyNoCache)) {

      // Store the etag key if the etag cache policy has been requested.
      if (![[BFFURLCache sharedCache] disableDiskCache]
          && IS_MASK_SET(loader.cachePolicy, BFFURLRequestCachePolicyEtag)) {
        NSDictionary* headers = [response allHeaderFields];

        // First, try to use the casing as defined by the standard for ETag headers.
        // http://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html
        NSString* etag = [headers objectForKey:@"ETag"];
        if (nil == etag) {
          // Some servers don't use the standard casing (e.g. twitter).
          etag = [headers objectForKey:@"Etag"];
        }

        // Still no etag?
        if (nil == etag) {
          BFFDWARNING(@"Etag expected, but none found.");
          BFFDWARNING(@"Here are the headers: %@", headers);

        } else {
          // At last, we have our etag. Let's cache it.

          // First, let's pull out the etag key. This is necessary due to some servers who append
          // information to the etag, such as -gzip for a gzipped request. However, the etag
          // standard states that etags are defined as a quoted string, and that is all.
          NSRange firstQuote = [etag rangeOfString:@"\""];
          NSRange secondQuote = [etag rangeOfString: @"\""
                                            options: 0
                                              range: NSMakeRange(firstQuote.location + 1,
                                                                 etag.length
                                                                 - (firstQuote.location + 1))];
          if (0 == firstQuote.length || 0 == secondQuote.length ||
              firstQuote.location == secondQuote.location) {
            BFFDWARNING(@"Invalid etag format. Unable to find a quoted key.");

          } else {
            NSRange keyRange;
            keyRange.location = firstQuote.location;
            keyRange.length = (secondQuote.location - firstQuote.location) + 1;
            NSString* etagKey = [etag substringWithRange:keyRange];
            BFFDCONDITIONLOG(BFFDFLAG_ETAGS, @"Response etag: %@", etagKey);
            [[BFFURLCache sharedCache] storeEtag:etagKey forKey:loader.cacheKey];
          }
        }
      }

      [[BFFURLCache sharedCache] storeData:data forKey:loader.cacheKey];
    }
    [loader dispatchLoaded:[NSDate date]];
  }
  [loader release];

  [self loadNextInQueue];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)               loader:(BFFRequestLoader*)loader
    didLoadUnmodifiedResponse:(NSHTTPURLResponse*)response {
  [loader retain];
  [self removeLoader:loader];

  NSData* data = nil;
  NSError* error = nil;
  NSDate* timestamp = nil;
  if ([self loadFromCache:loader.urlPath cacheKey:loader.cacheKey
                  expires:BFF_CACHE_EXPIRATION_AGE_NEVER
                 fromDisk:!_suspended && (loader.cachePolicy & BFFURLRequestCachePolicyDisk)
                     data:&data error:&error timestamp:&timestamp]) {

    if (nil == error) {
      error = [loader processResponse:response data:data];
    }

    if (nil == error) {
      for (BFFURLRequest* request in loader.requests) {
        request.respondedFromCache = YES;
      }
      [loader dispatchLoaded:[NSDate date]];
    }
  }

  if (nil != error) {
    [loader dispatchError:error];
  }

  [loader release];

  [self loadNextInQueue];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)                       loader: (BFFRequestLoader*)loader
    didReceiveAuthenticationChallenge: (NSURLAuthenticationChallenge*) challenge {
  BFFDCONDITIONLOG(BFFDFLAG_URLREQUEST, @"CHALLENGE: %@", challenge);
  [loader dispatchAuthenticationChallenge:challenge];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loader:(BFFRequestLoader*)loader didFailLoadWithError:(NSError*)error {
  BFFDCONDITIONLOG(BFFDFLAG_URLREQUEST, @"ERROR: %@", error);
  [self removeLoader:loader];
  [loader dispatchError:error];
  [self loadNextInQueue];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)loaderDidCancel:(BFFRequestLoader*)loader wasLoading:(BOOL)wasLoading {
  if (wasLoading) {
    [self removeLoader:loader];
    [self loadNextInQueue];
  } else {
    [_loaders removeObjectForKey:loader.cacheKey];
  }
}


@end
