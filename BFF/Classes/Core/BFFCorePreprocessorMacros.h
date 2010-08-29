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

/**
 * Borrowed from Apple's AvailabiltyInternal.h header. There's no reason why we shouldn't be
 * able to use this macro, as it's a gcc-supported flag.
 * Here's what we based it off of.
 * __AVAILABILITY_INTERNAL_DEPRECATED         __attribute__((deprecated))
 */
#define __TTDEPRECATED_METHOD __attribute__((deprecated))

///////////////////////////////////////////////////////////////////////////////////////////////////
// Errors

#define BFF_ERROR_DOMAIN @"three20.net"

#define BFF_EC_INVALID_IMAGE 101


///////////////////////////////////////////////////////////////////////////////////////////////////
// Flags

/**
 * For when the flag might be a set of bits, this will ensure that the exact set of bits in
 * the flag have been set in the value.
 */
#define IS_MASK_SET(value, flag)  (((value) & (flag)) == (flag))


///////////////////////////////////////////////////////////////////////////////////////////////////
// Time

#define BFF_MINUTE 60
#define BFF_HOUR   (60 * BFF_MINUTE)
#define BFF_DAY    (24 * BFF_HOUR)
#define BFF_WEEK   (7 * BFF_DAY)
#define BFF_MONTH  (30.5 * BFF_DAY)
#define BFF_YEAR   (365 * BFF_DAY)

///////////////////////////////////////////////////////////////////////////////////////////////////
// Safe releases

#define BFF_RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define BFF_INVALIDATE_TIMER(__TIMER) { [__TIMER invalidate]; __TIMER = nil; }

// Release a CoreFoundation object safely.
#define BFF_RELEASE_CF_SAFELY(__REF) { if (nil != (__REF)) { CFRelease(__REF); __REF = nil; } }
