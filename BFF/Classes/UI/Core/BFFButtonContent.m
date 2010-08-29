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

#import "BFFButtonContent.h"

// Network
#import "BFFURLImageResponse.h"
#import "BFFURLCache.h"
#import "BFFURLRequest.h"

// Core
#import "BFFCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFButtonContent

@synthesize title     = _title;
@synthesize imageURL  = _imageURL;
@synthesize image     = _image;
@synthesize style     = _style;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithButton:(BFFButton*)button {
  if (self = [super init]) {
    _button = button;
  }
  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_request cancel];
  BFF_RELEASE_SAFELY(_request);
  BFF_RELEASE_SAFELY(_title);
  BFF_RELEASE_SAFELY(_imageURL);
  BFF_RELEASE_SAFELY(_image);
  BFF_RELEASE_SAFELY(_style);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFURLRequestDelegate


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidStartLoad:(BFFURLRequest*)request {
  [_request release];
  _request = [request retain];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidFinishLoad:(BFFURLRequest*)request {
  BFFURLImageResponse* response = request.response;
  self.image = response.image;
  [_button setNeedsDisplay];

  BFF_RELEASE_SAFELY(_request);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)request:(BFFURLRequest*)request didFailLoadWithError:(NSError*)error {
  BFF_RELEASE_SAFELY(_request);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)requestDidCancelLoad:(BFFURLRequest*)request {
  BFF_RELEASE_SAFELY(_request);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setImageURL:(NSString*)URL {
  if (self.image && _imageURL && [URL isEqualToString:_imageURL])
    return;

  [self stopLoading];
  [_imageURL release];
  _imageURL = [URL retain];

  if (_imageURL.length) {
    [self reload];

  } else {
    self.image = nil;
    [_button setNeedsDisplay];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)reload {
  if (!_request && _imageURL) {
    UIImage* image = [[BFFURLCache sharedCache] imageForURL:_imageURL];
    if (image) {
      self.image = image;
      [_button setNeedsDisplay];
    } else {
      BFFURLRequest* request = [BFFURLRequest requestWithURL:_imageURL delegate:self];
      request.response = [[[BFFURLImageResponse alloc] init] autorelease];
      [request send];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopLoading {
  [_request cancel];
}


@end

