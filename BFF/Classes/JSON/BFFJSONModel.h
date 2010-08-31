//
//  BFFJSONModel.h
//  Locurious
//
//  Created by jamie on 8/30/10.
//  Copyright 2010 binaryfinery.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BFFJSONModel : BFFURLRequestModel {
  NSString* _url;
}
-(id)initWithURL:(NSString*)URL;
@end
