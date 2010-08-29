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

#import <Foundation/Foundation.h>

// Network
#import "BFFURLRequestCachePolicy.h"

// Core
#import "BFFCorePreprocessorMacros.h" // For __TTDEPRECATED_METHOD

@class BFFURLRequestQueue;
@class BFFURLRequest;

/**
 * The loader manages a set of BFFURLRequests and makes the necessary callbacks for each.
 * It implements the NSURLConnectionDelegate protocol and calls the required operations on the
 * queue as the protocol methods are invoked.
 *
 * NSURLErrorCannotFindHost errors are retried at least twice before completely giving up.
 *
 * The loader collects identical GET BFFURLRequests into a single object. This logic is handled in
 * BFFURLRequestQueue's sendRequest.
 * For all other BFFURLRequest types, they will each have their own loader.
 */
@interface BFFRequestLoader : NSObject {
  NSString*               _urlPath;

  BFFURLRequestQueue*      _queue;

  NSString*               _cacheKey;
  BFFURLRequestCachePolicy _cachePolicy;
  NSTimeInterval          _cacheExpirationAge;

  NSMutableArray*         _requests;
  NSURLConnection*        _connection;

  NSHTTPURLResponse*      _response;
  NSMutableData*          _responseData;

  /**
   * When load requests fail we'll attempt the request again, as many as 2 times by default.
   */
  int                     _retriesLeft;
}

/**
 * The list of BFFURLRequests currently attached to this loader.
 */
@property (nonatomic, readonly) NSArray* requests;

/**
 * The common urlPath shared by every request.
 */
@property (nonatomic, readonly) NSString* urlPath;

/**
 * The common cacheKey shared by every request.
 */
@property (nonatomic, readonly) NSString* cacheKey;

/**
 * The common cache policy shared by every request.
 */
@property (nonatomic, readonly) BFFURLRequestCachePolicy cachePolicy;

/**
 * The common cache expiration age shared by ever request.
 */
@property (nonatomic, readonly) NSTimeInterval cacheExpirationAge;

/**
 * Whether or not any of the requests in this loader are loading.
 */
@property (nonatomic, readonly) BOOL isLoading;

/**
 * Deprecated due to name ambiguity. Use urlPath instead.
 * Remove after May 6, 2010.
 */
@property (nonatomic, readonly) NSString* URL __TTDEPRECATED_METHOD;


- (id)initForRequest:(BFFURLRequest*)request queue:(BFFURLRequestQueue*)queue;

/**
 * Duplication is possible due to the use of an NSArray for the request list.
 */
- (void)addRequest:(BFFURLRequest*)request;
- (void)removeRequest:(BFFURLRequest*)request;

/**
 * If the loader isn't already active, create the NSURLRequest from the first BFFURLRequest added
 * to this loader and fire it off.
 */
- (void)load:(NSURL*)URL;

/**
 * As with load:, will create the NSURLRequest from the first BFFURLRequest added to the loader.
 * Unlike load:, this method will not return until the request has been fully completed.
 *
 * This is useful for threads that need to block while waiting for resources from the net.
 */
- (void)loadSynchronously:(NSURL*)URL;

/**
 * Cancel only the given request.
 *
 * @return NO   If there are no requests left.
 *         YES  If there are any requests left.
 */
- (BOOL)cancel:(BFFURLRequest*)request;

- (NSError*)processResponse:(NSHTTPURLResponse*)response data:(id)data;
- (void)dispatchError:(NSError*)error;
- (void)dispatchLoaded:(NSDate*)timestamp;
- (void)dispatchAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge;
- (void)cancel;

@end
