//
//  NSDictionary+BFFJsonAdditions.h
//  Locurious
//
//  Created by jamie on 8/26/10.
//BEGINLICENSE
//  Copyright 2010 binaryfinery.com. All rights reserved.
//  This source file may be used only with the permission of James Briant.
//  If you do not have a license agreement you may not use this file
//  nor use the information herein to create a derivative work.
//ENDLICENSE
//

#import <Foundation/Foundation.h>

@interface NSDictionary (BFFJsonAdditions) 

-(NSString*)formatKeys:(NSString *)format, ... NS_REQUIRES_NIL_TERMINATION;
-(NSString*)objectOrNilForKey:(id)key;
-(NSString*)stringOrEmptyForKey:(id)key;
-(NSNumber*)numberOrNilForKey:(id)key;
@end
