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

// UI
#import "BFFPhotoVersion.h"

// UINavigator
#import "BFFURLObject.h"

@protocol BFFPhotoSource;

@protocol BFFPhoto <NSObject, BFFURLObject>

/**
 * The photo source that the photo belongs to.
 */
@property (nonatomic, assign) id<BFFPhotoSource> photoSource;

/**
 * The index of the photo within its photo source.
 */
@property (nonatomic) CGSize size;

/**
 * The index of the photo within its photo source.
 */
@property (nonatomic) NSInteger index;

/**
 * The caption of the photo.
 */
@property (nonatomic, copy) NSString* caption;

/**
 * Gets the URL of one of the differently sized versions of the photo.
 */
- (NSString*)URLForVersion:(BFFPhotoVersion)version;

@end
