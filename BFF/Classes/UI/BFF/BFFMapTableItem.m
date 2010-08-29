//
//  BFFMapTableItem.m
//  Locurious
//
//  Created by jamie on 8/28/10.
//  Copyright 2010 binaryfinery.com. All rights reserved.
//

#import "BFFMapTableItem.h"


@implementation BFFMapTableItem

@synthesize address = _address;
@synthesize annotation = _annotation;

-(NSString*)description {
  
  return [NSString stringWithFormat:@"BFFMapTableItem %@ %@",_address,_annotation];
}

@end
