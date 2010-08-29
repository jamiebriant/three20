//
//  BFFMapTableItem.h
//  Locurious
//
//  Created by jamie on 8/28/10.
//  Copyright 2010 binaryfinery.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BFFMapTableItem : NSObject {
  NSString* _address;
  id<MKAnnotation> _annotation;
}

@property (nonatomic, copy) NSString* address;
@property (nonatomic, retain) id<MKAnnotation> annotation;

@end
