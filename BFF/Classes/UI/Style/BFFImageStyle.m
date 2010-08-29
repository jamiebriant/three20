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

#import "BFFImageStyle.h"

// Style
#import "BFFStyleContext.h"
#import "BFFStyleDelegate.h"
#import "BFFShape.h"
#import "BFFUIImageAdditions.h"

// Network
#import "BFFURLCache.h"

// Core
#import "BFFCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFImageStyle

@synthesize imageURL      = _imageURL;
@synthesize image         = _image;
@synthesize defaultImage  = _defaultImage;
@synthesize contentMode   = _contentMode;
@synthesize size          = _size;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNext:(BFFStyle*)next {
  if (self = [super initWithNext:next]) {
    _contentMode = UIViewContentModeScaleToFill;
    _size = CGSizeZero;
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  BFF_RELEASE_SAFELY(_imageURL);
  BFF_RELEASE_SAFELY(_image);
  BFF_RELEASE_SAFELY(_defaultImage);

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFImageStyle*)styleWithImageURL:(NSString*)imageURL next:(BFFStyle*)next {
  BFFImageStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.imageURL = imageURL;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFImageStyle*)styleWithImageURL:(NSString*)imageURL defaultImage:(UIImage*)defaultImage
                              next:(BFFStyle*)next {
  BFFImageStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.imageURL = imageURL;
  style.defaultImage = defaultImage;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFImageStyle*)styleWithImageURL:(NSString*)imageURL defaultImage:(UIImage*)defaultImage
                       contentMode:(UIViewContentMode)contentMode size:(CGSize)size next:(BFFStyle*)next {
  BFFImageStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.imageURL = imageURL;
  style.defaultImage = defaultImage;
  style.contentMode = contentMode;
  style.size = size;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFImageStyle*)styleWithImage:(UIImage*)image next:(BFFStyle*)next {
  BFFImageStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.image = image;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFImageStyle*)styleWithImage:(UIImage*)image defaultImage:(UIImage*)defaultImage
                           next:(BFFStyle*)next {
  BFFImageStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.image = image;
  style.defaultImage = defaultImage;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (BFFImageStyle*)styleWithImage:(UIImage*)image defaultImage:(UIImage*)defaultImage
                    contentMode:(UIViewContentMode)contentMode size:(CGSize)size next:(BFFStyle*)next {
  BFFImageStyle* style = [[[self alloc] initWithNext:next] autorelease];
  style.image = image;
  style.defaultImage = defaultImage;
  style.contentMode = contentMode;
  style.size = size;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)imageForContext:(BFFStyleContext*)context {
  UIImage* image = self.image;
  if (!image && [context.delegate respondsToSelector:@selector(imageForLayerWithStyle:)]) {
    image = [context.delegate imageForLayerWithStyle:self];
  }
  return image;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BFFStyle


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)draw:(BFFStyleContext*)context {
  UIImage* image = [self imageForContext:context];
  if (image) {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGRect rect = [image convertRect:context.contentFrame withContentMode:_contentMode];
    [context.shape addToPath:rect];
    CGContextClip(ctx);

    [image drawInRect:context.contentFrame contentMode:_contentMode];

    CGContextRestoreGState(ctx);
  }
  return [self.next draw:context];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)addToSize:(CGSize)size context:(BFFStyleContext*)context {
  if (_size.width || _size.height) {
    size.width += _size.width;
    size.height += _size.height;
  } else if (_contentMode != UIViewContentModeScaleToFill
             && _contentMode != UIViewContentModeScaleAspectFill
             && _contentMode != UIViewContentModeScaleAspectFit) {
    UIImage* image = [self imageForContext:context];
    if (image) {
      size.width += image.size.width;
      size.height += image.size.height;
    }
  }

  if (_next) {
    return [self.next addToSize:size context:context];

  } else {
    return size;
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)image {
  if (!_image && _imageURL) {
    _image = [[[BFFURLCache sharedCache] imageForURL:_imageURL] retain];
  }

  return _image;
}


@end
