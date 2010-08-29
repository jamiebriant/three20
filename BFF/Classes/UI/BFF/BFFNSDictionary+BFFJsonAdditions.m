//
//  NSDictionary+BFFJsonAdditions.m
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


#import "BFFNSDictionary+BFFJsonAdditions.h"

@implementation NSDictionary (BFFJsonAdditions)

-(id)objectOrNilForKey:(NSString*)key {
  id v = [self objectForKey:key];
  if ( v == [NSNull null] )
    return nil;
  return v;
}

-(NSString*)stringOrEmptyForKey:(NSString*)key {
  id v = [self objectForKey:key];
  if ( v == nil || v == [NSNull null] )
    return @"";
  return (NSString*)v;
}

-(NSNumber*)numberOrNilForKey:(id)key {
  id v = [self objectForKey:key];
  if ( v == nil || v == [NSNull null] )
    return nil;
  return (NSNumber*)v;  
}

-(NSString*)formatKeys:(NSString *)firstObject, ... {
  va_list argumentList;
  
  NSString* eachObject;
  id null = [NSNull null];
  if (firstObject)                      
  {
    //NSLog(@"top: 0x%08x",&firstObject);
    va_start(argumentList, firstObject); 
    //NSLog(@" 0x%08x",argumentList);
    
    NSString** ptr = (NSString**) argumentList;
    while (eachObject = va_arg(argumentList, NSString*)) {
      if (eachObject == nil)
        break;
      
      //NSLog(@"next: 0x%08x , 0x%08x, %@",eachObject, *ptr, eachObject);
      NSString* newObject = [self objectForKey:eachObject];
      if (newObject == nil || newObject == null) {
        newObject = @"";
      }
      // Sanity check:
      if (eachObject != *ptr)
      {
        // This is bad bad bad. It means that not just libc and the compiler,
        // but the ABI has changed. The whole method will need reimplementing.
        // 
        [NSException raise:@"NSException" format:@"bad va_args"];
      }
      *ptr = newObject;
      ++ptr;
    }
    
    va_end(argumentList);
    va_start(argumentList, firstObject);  
    
    NSString* result =  [[NSString alloc] initWithFormat:firstObject arguments:argumentList];
    va_end(argumentList);
    return result;
  }
  return @"";
  
}

@end

