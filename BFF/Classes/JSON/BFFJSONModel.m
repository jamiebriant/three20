//
//  BFFJSONModel.m
//  Locurious
//
//  Created by jamie on 8/30/10.
//  Copyright 2010 binaryfinery.com. All rights reserved.
//

#import "BFFJSONModel.h"


@implementation BFFJSONModel

-(id)initWithURL:(NSString *)URL {
  self = [super init];
  if (self != nil) {
    _url = [[URL copy] retain];
  }
  return self;
}

- (void)load:(BFFURLRequestCachePolicy)cachePolicy more:(BOOL)more {
  if (!self.isLoading) {
    
    BFFURLRequest* request = [BFFURLRequest
                              requestWithURL: _url
                              delegate: self];
    
    request.cachePolicy = cachePolicy | BFFURLRequestCachePolicyEtag;
    request.cacheExpirationAge = BFF_CACHE_EXPIRATION_AGE_NEVER;
    
    BFFURLJSONResponse* response = [[BFFURLJSONResponse alloc] init];
    request.response = response;
    BFF_RELEASE_SAFELY(response);
    
    [request send];
  }
}

@end
