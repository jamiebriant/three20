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

#import "BFFURLJSONResponse.h"

#import "BFFJSON.h"

// Core
#import "BFFCorePreprocessorMacros.h"
#import "BFFDebug.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFURLJSONResponse

@synthesize rootObject  = _rootObject;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_rootObject);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFURLResponse


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSError*)request:(BFFURLRequest*)request processResponse:(NSHTTPURLResponse*)response
               data:(id)data {
  // This response is designed for NSData objects, so if we get anything else it's probably a
  // mistake.
  BFFDASSERT([data isKindOfClass:[NSData class]]);
  BFFDASSERT(nil == _rootObject);

  if ([data isKindOfClass:[NSData class]]) {
    NSString* json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    _rootObject = [[json JSONValue] retain];
    BFF_RELEASE_SAFELY(json);
  }

  return nil;
}


@end

