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

#import "BFFNSDateAdditions.h"

// Core
#import "BFFCorePreprocessorMacros.h"
#import "BFFGlobalCoreLocale.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
@implementation NSDate (BFFCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Class public


///////////////////////////////////////////////////////////////////////////////////////////////////
+ (NSDate*)dateWithToday {
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"yyyy-d-M";

  NSString* formattedTime = [formatter stringFromDate:[NSDate date]];
  NSDate* date = [formatter dateFromString:formattedTime];
  BFF_RELEASE_SAFELY(formatter);

  return date;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDate*)dateAtMidnight {
  NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
  formatter.dateFormat = @"yyyy-d-M";

  NSString* formattedTime = [formatter stringFromDate:self];
  NSDate* date = [formatter dateFromString:formattedTime];
  BFF_RELEASE_SAFELY(formatter);

  return date;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatTime {
  static NSDateFormatter* formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = BFFLocalizedString(@"h:mm a", @"Date format: 1:05 pm");
    formatter.locale = BFFCurrentLocale();
  }
  return [formatter stringFromDate:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatDate {
  static NSDateFormatter* formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat =
      BFFLocalizedString(@"EEEE, LLLL d, YYYY", @"Date format: Monday, July 27, 2009");
    formatter.locale = BFFCurrentLocale();
  }
  return [formatter stringFromDate:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatShortTime {
  NSTimeInterval diff = abs([self timeIntervalSinceNow]);

  if (diff < BFF_DAY) {
    return [self formatTime];

  } else if (diff < BFF_WEEK) {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
      formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = BFFLocalizedString(@"EEEE", @"Date format: Monday");
      formatter.locale = BFFCurrentLocale();
    }
    return [formatter stringFromDate:self];

  } else {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
      formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = BFFLocalizedString(@"M/d/yy", @"Date format: 7/27/09");
      formatter.locale = BFFCurrentLocale();
    }
    return [formatter stringFromDate:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatDateTime {
  NSTimeInterval diff = abs([self timeIntervalSinceNow]);
  if (diff < BFF_DAY) {
    return [self formatTime];

  } else if (diff < BFF_WEEK) {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
      formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = BFFLocalizedString(@"EEE h:mm a", @"Date format: Mon 1:05 pm");
      formatter.locale = BFFCurrentLocale();
    }
    return [formatter stringFromDate:self];

  } else {
    static NSDateFormatter* formatter = nil;
    if (!formatter) {
      formatter = [[NSDateFormatter alloc] init];
      formatter.dateFormat = BFFLocalizedString(@"MMM d h:mm a", @"Date format: Jul 27 1:05 pm");
      formatter.locale = BFFCurrentLocale();
    }
    return [formatter stringFromDate:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatRelativeTime {
  NSTimeInterval elapsed = abs([self timeIntervalSinceNow]);
  if (elapsed <= 1) {
    return BFFLocalizedString(@"just a moment ago", @"");

  } else if (elapsed < BFF_MINUTE) {
    int seconds = (int)(elapsed);
    return [NSString stringWithFormat:BFFLocalizedString(@"%d seconds ago", @""), seconds];

  } else if (elapsed < 2*BFF_MINUTE) {
    return BFFLocalizedString(@"about a minute ago", @"");

  } else if (elapsed < BFF_HOUR) {
    int mins = (int)(elapsed/BFF_MINUTE);
    return [NSString stringWithFormat:BFFLocalizedString(@"%d minutes ago", @""), mins];

  } else if (elapsed < BFF_HOUR*1.5) {
    return BFFLocalizedString(@"about an hour ago", @"");

  } else if (elapsed < BFF_DAY) {
    int hours = (int)((elapsed+BFF_HOUR/2)/BFF_HOUR);
    return [NSString stringWithFormat:BFFLocalizedString(@"%d hours ago", @""), hours];

  } else {
    return [self formatDateTime];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatShortRelativeTime {
  NSTimeInterval elapsed = abs([self timeIntervalSinceNow]);

  if (elapsed < BFF_MINUTE) {
    return BFFLocalizedString(@"<1m", @"Date format: less than one minute ago");

  } else if (elapsed < BFF_HOUR) {
    int mins = (int)(elapsed / BFF_MINUTE);
    return [NSString stringWithFormat:BFFLocalizedString(@"%dm", @"Date format: 50m"), mins];

  } else if (elapsed < BFF_DAY) {
    int hours = (int)((elapsed + BFF_HOUR / 2) / BFF_HOUR);
    return [NSString stringWithFormat:BFFLocalizedString(@"%dh", @"Date format: 3h"), hours];

  } else if (elapsed < BFF_WEEK) {
    int day = (int)((elapsed + BFF_DAY / 2) / BFF_DAY);
    return [NSString stringWithFormat:BFFLocalizedString(@"%dd", @"Date format: 3d"), day];

  } else {
    return [self formatShortTime];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatDay:(NSDateComponents*)today yesterday:(NSDateComponents*)yesterday {
  static NSDateFormatter* formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = BFFLocalizedString(@"MMMM d", @"Date format: July 27");
    formatter.locale = BFFCurrentLocale();
  }

  NSCalendar* cal = [NSCalendar currentCalendar];
  NSDateComponents* day = [cal components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                               fromDate:self];

  if (day.day == today.day && day.month == today.month && day.year == today.year) {
    return BFFLocalizedString(@"Today", @"");
  } else if (day.day == yesterday.day && day.month == yesterday.month
             && day.year == yesterday.year) {
    return BFFLocalizedString(@"Yesterday", @"");
  } else {
    return [formatter stringFromDate:self];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatMonth {
  static NSDateFormatter* formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = BFFLocalizedString(@"MMMM", @"Date format: July");
    formatter.locale = BFFCurrentLocale();
  }
  return [formatter stringFromDate:self];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)formatYear {
  static NSDateFormatter* formatter = nil;
  if (!formatter) {
    formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = BFFLocalizedString(@"yyyy", @"Date format: 2009");
    formatter.locale = BFFCurrentLocale();
  }
  return [formatter stringFromDate:self];
}


@end

#import "BFFCategoryFix.h"
FIX_CATEGORY_BUG(NSDateAdditions)
