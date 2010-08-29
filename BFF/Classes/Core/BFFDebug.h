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
 * Three20 Debugging tools.
 *
 * Provided in this header are a set of debugging tools. This is meant quite literally, in that
 * all of the macros below will only function when the DEBUG preprocessor macro is specified.
 *
 * BFFDASSERT(<statement>);
 * If <statement> is false, the statement will be written to the log and if you are running in
 * the simulator with a debugger attached, the app will break on the assertion line.
 *
 * BFFDPRINT(@"formatted log text %d", param1);
 * Print the given formatted text to the log.
 *
 * BFFDPRINTMETHODNAME();
 * Print the current method name to the log.
 *
 * BFFDCONDITIONLOG(<statement>, @"formatted log text %d", param1);
 * If <statement> is true, then the formatted text will be written to the log.
 *
 * BFFDINFO/BFFDWARNING/BFFDERROR(@"formatted log text %d", param1);
 * Will only write the formatted text to the log if BFFMAXLOGLEVEL is greater than the respective
 * BFFD* method's log level. See below for log levels.
 *
 * The default maximum log level is BFFLOGLEVEL_WARNING.
 */

#define BFFLOGLEVEL_INFO     5
#define BFFLOGLEVEL_WARNING  3
#define BFFLOGLEVEL_ERROR    1

#ifndef BFFMAXLOGLEVEL
  #define BFFMAXLOGLEVEL BFFLOGLEVEL_WARNING
#endif

// The general purpose logger. This ignores logging levels.
#ifdef DEBUG
  #define BFFDPRINT(xx, ...)  NSLog(@"%s(%d): " xx, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
  #define BFFDPRINT(xx, ...)  ((void)0)
#endif // #ifdef DEBUG

// Prints the current method's name.
#define BFFDPRINTMETHODNAME() BFFDPRINT(@"%s", __PRETTY_FUNCTION__)

// Debug-only assertions.
#ifdef DEBUG

#import <TargetConditionals.h>

#if TARGET_IPHONE_SIMULATOR

  int BFFIsInDebugger();
  // We leave the __asm__ in this macro so that when a break occurs, we don't have to step out of
  // a "breakInDebugger" function.
  #define BFFDASSERT(xx) { if(!(xx)) { BFFDPRINT(@"BFFDASSERT failed: %s", #xx); \
                                      if(BFFIsInDebugger()) { __asm__("int $3\n" : : ); }; } \
                        } ((void)0)
#else
  #define BFFDASSERT(xx) { if(!(xx)) { BFFDPRINT(@"BFFDASSERT failed: %s", #xx); } } ((void)0)
#endif // #if TARGET_IPHONE_SIMULATOR

#else
  #define BFFDASSERT(xx) ((void)0)
#endif // #ifdef DEBUG

// Log-level based logging macros.
#if BFFLOGLEVEL_ERROR <= BFFMAXLOGLEVEL
  #define BFFDERROR(xx, ...)  BFFDPRINT(xx, ##__VA_ARGS__)
#else
  #define BFFDERROR(xx, ...)  ((void)0)
#endif // #if BFFLOGLEVEL_ERROR <= BFFMAXLOGLEVEL

#if BFFLOGLEVEL_WARNING <= BFFMAXLOGLEVEL
  #define BFFDWARNING(xx, ...)  BFFDPRINT(xx, ##__VA_ARGS__)
#else
  #define BFFDWARNING(xx, ...)  ((void)0)
#endif // #if BFFLOGLEVEL_WARNING <= BFFMAXLOGLEVEL

#if BFFLOGLEVEL_INFO <= BFFMAXLOGLEVEL
  #define BFFDINFO(xx, ...)  BFFDPRINT(xx, ##__VA_ARGS__)
#else
  #define BFFDINFO(xx, ...)  ((void)0)
#endif // #if BFFLOGLEVEL_INFO <= BFFMAXLOGLEVEL

#ifdef DEBUG
  #define BFFDCONDITIONLOG(condition, xx, ...) { if ((condition)) { \
                                                  BFFDPRINT(xx, ##__VA_ARGS__); \
                                                } \
                                              } ((void)0)
#else
  #define BFFDCONDITIONLOG(condition, xx, ...) ((void)0)
#endif // #ifdef DEBUG
