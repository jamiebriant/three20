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

#import "BFFDefaultStyleSheet.h"

// Style
#import "BFFGlobalStyle.h"
#import "BFFStyle.h"
#import "BFFUIColorAdditions.h"
#import "BFFDefaultStyleSheet+DragRefreshHeader.h"

// - Styles
#import "BFFInsetStyle.h"
#import "BFFShapeStyle.h"
#import "BFFSolidFillStyle.h"
#import "BFFTextStyle.h"
#import "BFFImageStyle.h"
#import "BFFSolidBorderStyle.h"
#import "BFFShadowStyle.h"
#import "BFFInnerShadowStyle.h"
#import "BFFBevelBorderStyle.h"
#import "BFFLinearGradientFillStyle.h"
#import "BFFFourBorderStyle.h"
#import "BFFLinearGradientBorderStyle.h"
#import "BFFReflectiveFillStyle.h"
#import "BFFBoxStyle.h"
#import "BFFPartStyle.h"
#import "BFFContentStyle.h"
#import "BFFBlendStyle.h"

// - Shapes
#import "BFFRectangleShape.h"
#import "BFFRoundedRectangleShape.h"
#import "BFFRoundedLeftArrowShape.h"
#import "BFFRoundedRightArrowShape.h"

// Network
#import "BFFGlobalNetwork.h"
#import "BFFURLCache.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFDefaultStyleSheet


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)linkText:(UIControlState)state {
  if (state == UIControlStateHighlighted) {
    return
      [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(-3, -4, -3, -4) next:
      [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:4.5] next:
      [BFFSolidFillStyle styleWithColor:[UIColor colorWithWhite:0.75 alpha:1] next:
      [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(3, 4, 3, 4) next:
      [BFFTextStyle styleWithColor:self.linkTextColor next:nil]]]]];
  } else {
    return
      [BFFTextStyle styleWithColor:self.linkTextColor next:nil];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)linkHighlighted {
  return
    [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:4.5] next:
    [BFFSolidFillStyle styleWithColor:[UIColor colorWithWhite:0 alpha:0.25] next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)thumbView:(UIControlState)state {
  if (state & UIControlStateHighlighted) {
    return
      [BFFImageStyle styleWithImageURL:nil defaultImage:nil
                    contentMode:UIViewContentModeScaleAspectFill size:CGSizeZero next:
      [BFFSolidBorderStyle styleWithColor:RGBACOLOR(0,0,0,0.2) width:1 next:
      [BFFSolidFillStyle styleWithColor:RGBACOLOR(0,0,0,0.5) next:nil]]];
  } else {
    return
      [BFFImageStyle styleWithImageURL:nil defaultImage:nil
                    contentMode:UIViewContentModeScaleAspectFill size:CGSizeZero next:
      [BFFSolidBorderStyle styleWithColor:RGBACOLOR(0,0,0,0.2) width:1 next:nil]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)toolbarButton:(UIControlState)state {
  return [self toolbarButtonForState:state
               shape:[BFFRoundedRectangleShape shapeWithRadius:4.5]
               tintColor:BFFSTYLEVAR(toolbarTintColor)
               font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)toolbarBackButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[BFFRoundedLeftArrowShape shapeWithRadius:4.5]
          tintColor:BFFSTYLEVAR(toolbarTintColor)
          font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)toolbarForwardButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[BFFRoundedRightArrowShape shapeWithRadius:4.5]
          tintColor:BFFSTYLEVAR(toolbarTintColor)
          font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)toolbarRoundButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[BFFRoundedRectangleShape shapeWithRadius:BFF_ROUNDED]
          tintColor:BFFSTYLEVAR(toolbarTintColor)
          font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)blackToolbarButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[BFFRoundedRectangleShape shapeWithRadius:4.5]
          tintColor:RGBCOLOR(10, 10, 10)
          font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)grayToolbarButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[BFFRoundedRectangleShape shapeWithRadius:4.5]
          tintColor:RGBCOLOR(40, 40, 40)
          font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)blackToolbarForwardButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[BFFRoundedRightArrowShape shapeWithRadius:4.5]
          tintColor:RGBCOLOR(10, 10, 10)
          font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)blackToolbarRoundButton:(UIControlState)state {
  return
    [self toolbarButtonForState:state
          shape:[BFFRoundedRectangleShape shapeWithRadius:BFF_ROUNDED]
          tintColor:RGBCOLOR(10, 10, 10)
          font:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)searchTextField {
  return
    [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:BFF_ROUNDED] next:
    [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(1, 0, 1, 0) next:
    [BFFShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.4) blur:0 offset:CGSizeMake(0, 1) next:
    [BFFSolidFillStyle styleWithColor:BFFSTYLEVAR(backgroundColor) next:
    [BFFInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.4) blur:3 offset:CGSizeMake(0, 2) next:
    [BFFBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.25) shadow:RGBACOLOR(0,0,0,0.4)
                        width:1 lightSource:270 next:nil]]]]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)searchBar {
  UIColor* color = BFFSTYLEVAR(searchBarTintColor);
  UIColor* highlight = [color multiplyHue:0 saturation:0 value:1.2];
  UIColor* shadowColor = [color multiplyHue:0 saturation:0 value:0.82];
  return
    [BFFLinearGradientFillStyle styleWithColor1:highlight color2:color next:
    [BFFFourBorderStyle styleWithTop:nil right:nil bottom:shadowColor left:nil width:1 next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)searchBarBottom {
  UIColor* color = BFFSTYLEVAR(searchBarTintColor);
  UIColor* highlight = [color multiplyHue:0 saturation:0 value:1.2];
  UIColor* shadowColor = [color multiplyHue:0 saturation:0 value:0.82];
  return
    [BFFLinearGradientFillStyle styleWithColor1:highlight color2:color next:
    [BFFFourBorderStyle styleWithTop:shadowColor right:nil bottom:nil left:nil width:1 next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)blackSearchBar {
  UIColor* highlight = [UIColor colorWithWhite:1 alpha:0.05];
  UIColor* mid = [UIColor colorWithWhite:0.4 alpha:0.6];
  UIColor* shadowColor = [UIColor colorWithWhite:0 alpha:0.8];
  return
    [BFFLinearGradientFillStyle styleWithColor1:mid color2:shadowColor next:
    [BFFFourBorderStyle styleWithTop:nil right:nil bottom:shadowColor left:nil width:1 next:
    [BFFFourBorderStyle styleWithTop:nil right:nil bottom:highlight left:nil width:1 next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tableHeader {
  UIColor* color = BFFSTYLEVAR(tableHeaderTintColor);
  UIColor* highlight = [color multiplyHue:0 saturation:0 value:1.1];
  return
    [BFFLinearGradientFillStyle styleWithColor1:highlight color2:color next:
    [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(-1, 0, 0, 0) next:
    [BFFFourBorderStyle styleWithTop:nil right:nil bottom:RGBACOLOR(0,0,0,0.15)
                       left:nil width:1 next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)pickerCell:(UIControlState)state {
  if (state & UIControlStateSelected) {
    return
      [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:BFF_ROUNDED] next:
      [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(1, 1, 1, 1) next:
      [BFFLinearGradientFillStyle styleWithColor1:RGBCOLOR(79, 144, 255)
                                 color2:RGBCOLOR(49, 90, 255) next:
      [BFFFourBorderStyle styleWithTop:RGBCOLOR(53, 94, 255)
                         right:RGBCOLOR(53, 94, 255) bottom:RGBCOLOR(53, 94, 255)
                         left:RGBCOLOR(53, 94, 255) width:1 next:nil]]]];

   } else {
    return
     [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:BFF_ROUNDED] next:
     [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(1, 1, 1, 1) next:
     [BFFLinearGradientFillStyle styleWithColor1:RGBCOLOR(221, 231, 248)
                                color2:RGBACOLOR(188, 206, 241, 1) next:
     [BFFLinearGradientBorderStyle styleWithColor1:RGBCOLOR(161, 187, 283)
                        color2:RGBCOLOR(118, 130, 214) width:1 next:nil]]]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)searchTableShadow {
  return
    [BFFLinearGradientFillStyle styleWithColor1:RGBACOLOR(0, 0, 0, 0.18)
                               color2:[UIColor clearColor] next:
    [BFFFourBorderStyle styleWithTop:RGBCOLOR(130, 130, 130) right:nil bottom:nil left:nil
                       width: 1 next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)blackBezel {
  return
    [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:10] next:
    [BFFSolidFillStyle styleWithColor:RGBACOLOR(0, 0, 0, 0.7) next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)whiteBezel {
  return
    [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:10] next:
    [BFFSolidFillStyle styleWithColor:RGBCOLOR(255, 255, 255) next:
    [BFFSolidBorderStyle styleWithColor:RGBCOLOR(178, 178, 178) width:1 next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)blackBanner {
  return
    [BFFSolidFillStyle styleWithColor:RGBACOLOR(0, 0, 0, 0.5) next:
    [BFFFourBorderStyle styleWithTop:RGBCOLOR(0, 0, 0) right:nil bottom:nil left: nil width:1 next:
    [BFFFourBorderStyle styleWithTop:[UIColor colorWithWhite:1 alpha:0.2] right:nil bottom:nil
                       left: nil width:1 next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)badgeWithFontSize:(CGFloat)fontSize {
  return
    [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:BFF_ROUNDED] next:
    [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(1, 1, 1, 1) next:
    [BFFShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.8) blur:3 offset:CGSizeMake(0, 4) next:
    [BFFReflectiveFillStyle styleWithColor:RGBCOLOR(221, 17, 27) next:
    [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(-1, -1, -1, -1) next:
    [BFFSolidBorderStyle styleWithColor:[UIColor whiteColor] width:2 next:
    [BFFBoxStyle styleWithPadding:UIEdgeInsetsMake(1, 7, 2, 7) next:
    [BFFTextStyle styleWithFont:[UIFont boldSystemFontOfSize:fontSize]
                 color:[UIColor whiteColor] next:nil]]]]]]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)miniBadge {
  return [self badgeWithFontSize:12];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)badge {
  return [self badgeWithFontSize:15];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)largeBadge {
  return [self badgeWithFontSize:17];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tabBar {
  UIColor* border = [BFFSTYLEVAR(tabBarTintColor) multiplyHue:0 saturation:0 value:0.7];
  return
    [BFFSolidFillStyle styleWithColor:BFFSTYLEVAR(tabBarTintColor) next:
    [BFFFourBorderStyle styleWithTop:nil right:nil bottom:border left:nil width:1 next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tabStrip {
  UIColor* border = [BFFSTYLEVAR(tabTintColor) multiplyHue:0 saturation:0 value:0.4];
  return
    [BFFReflectiveFillStyle styleWithColor:BFFSTYLEVAR(tabTintColor) next:
    [BFFFourBorderStyle styleWithTop:nil right:nil bottom:border left:nil width:1 next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tabGrid {
  UIColor* color = BFFSTYLEVAR(tabTintColor);
  UIColor* lighter = [color multiplyHue:1 saturation:0.9 value:1.1];

  UIColor* highlight = RGBACOLOR(255, 255, 255, 0.7);
  UIColor* shadowColor = [color multiplyHue:1 saturation:1.1 value:0.86];
  return
    [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:8] next:
    [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(0,-1,-1,-2) next:
    [BFFShadowStyle styleWithColor:highlight blur:1 offset:CGSizeMake(0, 1) next:
    [BFFLinearGradientFillStyle styleWithColor1:lighter color2:color next:
    [BFFSolidBorderStyle styleWithColor:shadowColor width:1 next:nil]]]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tabGridTabImage:(UIControlState)state {
  return
    [BFFImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeLeft
                  size:CGSizeZero next:nil];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tabGridTab:(UIControlState)state corner:(short)corner {
  BFFShape* shape = nil;
  if (corner == 1) {
    shape = [BFFRoundedRectangleShape shapeWithTopLeft:8 topRight:0 bottomRight:0 bottomLeft:0];
  } else if (corner == 2) {
    shape = [BFFRoundedRectangleShape shapeWithTopLeft:0 topRight:8 bottomRight:0 bottomLeft:0];
  } else if (corner == 3) {
    shape = [BFFRoundedRectangleShape shapeWithTopLeft:0 topRight:0 bottomRight:8 bottomLeft:0];
  } else if (corner == 4) {
    shape = [BFFRoundedRectangleShape shapeWithTopLeft:0 topRight:0 bottomRight:0 bottomLeft:8];
  } else if (corner == 5) {
    shape = [BFFRoundedRectangleShape shapeWithTopLeft:8 topRight:0 bottomRight:0 bottomLeft:8];
  } else if (corner == 6) {
    shape = [BFFRoundedRectangleShape shapeWithTopLeft:0 topRight:8 bottomRight:8 bottomLeft:0];
  } else {
    shape = [BFFRectangleShape shape];
  }

  UIColor* highlight = RGBACOLOR(255, 255, 255, 0.7);
  UIColor* shadowColor = [BFFSTYLEVAR(tabTintColor) multiplyHue:1 saturation:1.1 value:0.88];

  if (state == UIControlStateSelected) {
    return
      [BFFShapeStyle styleWithShape:shape next:
      [BFFSolidFillStyle styleWithColor:RGBCOLOR(150, 168, 191) next:
      [BFFInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.6) blur:3 offset:CGSizeMake(0, 0) next:
      [BFFBoxStyle styleWithPadding:UIEdgeInsetsMake(11, 10, 9, 10) next:
      [BFFPartStyle styleWithName:@"image" style:[self tabGridTabImage:state] next:
      [BFFTextStyle styleWithFont:[UIFont boldSystemFontOfSize:11]  color:RGBCOLOR(255, 255, 255)
                   minimumFontSize:8 shadowColor:RGBACOLOR(0,0,0,0.1) shadowOffset:CGSizeMake(-1,-1)
                   next:nil]]]]]];
  } else {
    return
      [BFFShapeStyle styleWithShape:shape next:
      [BFFBevelBorderStyle styleWithHighlight:highlight shadow:shadowColor width:1 lightSource:125 next:
      [BFFBoxStyle styleWithPadding:UIEdgeInsetsMake(11, 10, 9, 10) next:
      [BFFPartStyle styleWithName:@"image" style:[self tabGridTabImage:state] next:
      [BFFTextStyle styleWithFont:[UIFont boldSystemFontOfSize:11]  color:self.linkTextColor
                   minimumFontSize:8 shadowColor:[UIColor colorWithWhite:255 alpha:0.9]
                   shadowOffset:CGSizeMake(0, -1) next:nil]]]]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tabGridTabTopLeft:(UIControlState)state {
  return [self tabGridTab:state corner:1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tabGridTabTopRight:(UIControlState)state {
  return [self tabGridTab:state corner:2];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tabGridTabBottomRight:(UIControlState)state {
  return [self tabGridTab:state corner:3];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tabGridTabBottomLeft:(UIControlState)state {
  return [self tabGridTab:state corner:4];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tabGridTabLeft:(UIControlState)state {
  return [self tabGridTab:state corner:5];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tabGridTabRight:(UIControlState)state {
  return [self tabGridTab:state corner:6];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tabGridTabCenter:(UIControlState)state {
  return [self tabGridTab:state corner:0];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tab:(UIControlState)state {
  if (state == UIControlStateSelected) {
    UIColor* border = [BFFSTYLEVAR(tabBarTintColor) multiplyHue:0 saturation:0 value:0.7];

    return
      [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithTopLeft:4.5 topRight:4.5
                                                            bottomRight:0 bottomLeft:0] next:
      [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(5, 1, 0, 1) next:
      [BFFReflectiveFillStyle styleWithColor:BFFSTYLEVAR(tabTintColor) next:
      [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(-1, -1, 0, -1) next:
      [BFFFourBorderStyle styleWithTop:border right:border bottom:nil left:border width:1 next:
      [BFFBoxStyle styleWithPadding:UIEdgeInsetsMake(6, 12, 2, 12) next:
      [BFFTextStyle styleWithFont:[UIFont boldSystemFontOfSize:14]  color:BFFSTYLEVAR(textColor)
                   minimumFontSize:8 shadowColor:[UIColor colorWithWhite:1 alpha:0.8]
                   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]];
  } else {
    return
      [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(5, 1, 1, 1) next:
      [BFFBoxStyle styleWithPadding:UIEdgeInsetsMake(6, 12, 2, 12) next:
      [BFFTextStyle styleWithFont:[UIFont boldSystemFontOfSize:14]  color:[UIColor whiteColor]
                   minimumFontSize:8 shadowColor:[UIColor colorWithWhite:0 alpha:0.6]
                   shadowOffset:CGSizeMake(0, -1) next:nil]]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tabRound:(UIControlState)state {
  if (state == UIControlStateSelected) {
    return
      [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:BFF_ROUNDED] next:
      [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(9, 1, 8, 1) next:
      [BFFShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.8) blur:0 offset:CGSizeMake(0, 1) next:
      [BFFReflectiveFillStyle styleWithColor:BFFSTYLEVAR(tabBarTintColor) next:
      [BFFInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.3) blur:1 offset:CGSizeMake(1, 1) next:
      [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(-1, -1, -1, -1) next:
      [BFFBoxStyle styleWithPadding:UIEdgeInsetsMake(0, 10, 0, 10) next:
      [BFFTextStyle styleWithFont:[UIFont boldSystemFontOfSize:13]  color:[UIColor whiteColor]
                   minimumFontSize:8 shadowColor:[UIColor colorWithWhite:0 alpha:0.5]
                   shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]]];
  } else {
    return
      [BFFBoxStyle styleWithPadding:UIEdgeInsetsMake(0, 10, 0, 10) next:
      [BFFTextStyle styleWithFont:[UIFont boldSystemFontOfSize:13]  color:self.linkTextColor
                   minimumFontSize:8 shadowColor:[UIColor colorWithWhite:1 alpha:0.9]
                   shadowOffset:CGSizeMake(0, -1) next:nil]];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tabOverflowLeft {
  UIImage* image = BFFIMAGE(@"bundle://Three20.bundle/images/overflowLeft.png");
  BFFImageStyle *style = [BFFImageStyle styleWithImage:image next:nil];
  style.contentMode = UIViewContentModeCenter;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)tabOverflowRight {
  UIImage* image = BFFIMAGE(@"bundle://Three20.bundle/images/overflowRight.png");
  BFFImageStyle *style = [BFFImageStyle styleWithImage:image next:nil];
  style.contentMode = UIViewContentModeCenter;
  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)rounded {
  return
    [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:8] next:
    [BFFContentStyle styleWithNext:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)postTextEditor {
  return
    [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(6, 5, 6, 5) next:
    [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:15] next:
    [BFFSolidFillStyle styleWithColor:[UIColor whiteColor] next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)photoCaption {
  return
    [BFFSolidFillStyle styleWithColor:[UIColor colorWithWhite:0 alpha:0.5] next:
    [BFFFourBorderStyle styleWithTop:RGBACOLOR(0, 0, 0, 0.5) width:1 next:
    [BFFBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 8, 8, 8) next:
    [BFFTextStyle styleWithFont: BFFSTYLEVAR(photoCaptionFont)
                         color: BFFSTYLEVAR(photoCaptionTextColor)
               minimumFontSize: 0
                   shadowColor: BFFSTYLEVAR(photoCaptionTextShadowColor)
                  shadowOffset: BFFSTYLEVAR(photoCaptionTextShadowOffset)
                 textAlignment: UITextAlignmentCenter
             verticalAlignment: UIControlContentVerticalAlignmentCenter
                 lineBreakMode: UILineBreakModeTailTruncation
                 numberOfLines: 6
                          next: nil]]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)photoStatusLabel {
  return
    [BFFSolidFillStyle styleWithColor:[UIColor colorWithWhite:0 alpha:0.5] next:
    [BFFBoxStyle styleWithPadding:UIEdgeInsetsMake(20, 8, 20, 8) next:
    [BFFTextStyle styleWithFont:BFFSTYLEVAR(tableFont) color:RGBCOLOR(200, 200, 200)
                 minimumFontSize:0 shadowColor:[UIColor colorWithWhite:0 alpha:0.9]
                 shadowOffset:CGSizeMake(0, -1) next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)pageDot:(UIControlState)state {
  if (state == UIControlStateSelected) {
    return [self pageDotWithColor:[UIColor whiteColor]];
  } else {
    return [self pageDotWithColor:RGBCOLOR(77, 77, 77)];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)launcherButton:(UIControlState)state {
  return
    [BFFPartStyle styleWithName:@"image" style:BFFSTYLESTATE(launcherButtonImage:, state) next:
    [BFFTextStyle styleWithFont:[UIFont boldSystemFontOfSize:11] color:RGBCOLOR(180, 180, 180)
                 minimumFontSize:11 shadowColor:nil
                 shadowOffset:CGSizeZero next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)launcherButtonImage:(UIControlState)state {
  BFFStyle* style =
    [BFFBoxStyle styleWithMargin:UIEdgeInsetsMake(-7, 0, 11, 0) next:
    [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:8] next:
    [BFFImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeCenter
                  size:CGSizeZero next:nil]]];

  if (state == UIControlStateHighlighted || state == UIControlStateSelected) {
      [style addStyle:
        [BFFBlendStyle styleWithBlend:kCGBlendModeSourceAtop next:
        [BFFSolidFillStyle styleWithColor:RGBACOLOR(0,0,0,0.5) next:nil]]];
  }

  return style;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)launcherCloseButtonImage:(UIControlState)state {
  return
    [BFFBoxStyle styleWithMargin:UIEdgeInsetsMake(-2, 0, 0, 0) next:
    [BFFImageStyle styleWithImageURL:nil defaultImage:nil contentMode:UIViewContentModeCenter
                  size:CGSizeMake(10,10) next:nil]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)launcherCloseButton:(UIControlState)state {
  return
    [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:BFF_ROUNDED] next:
    [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(1, 1, 1, 1) next:
    [BFFShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.5) blur:2 offset:CGSizeMake(0, 3) next:
    [BFFSolidFillStyle styleWithColor:[UIColor blackColor] next:
    [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(-1, -1, -1, -1) next:
    [BFFSolidBorderStyle styleWithColor:[UIColor whiteColor] width:2 next:
    [BFFPartStyle styleWithName:@"image" style:BFFSTYLE(launcherCloseButtonImage:) next:
    nil]]]]]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)launcherPageDot:(UIControlState)state {
  return [self pageDot:state];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)textBar {
  return
    [BFFLinearGradientFillStyle styleWithColor1:RGBCOLOR(237, 239, 241)
                               color2:RGBCOLOR(206, 208, 212) next:
    [BFFFourBorderStyle styleWithTop:RGBCOLOR(187, 189, 190) right:nil bottom:nil left:nil width:1 next:
    [BFFFourBorderStyle styleWithTop:RGBCOLOR(255, 255, 255) right:nil bottom:nil left:nil width:1
                       next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)textBarFooter {
  return
    [BFFLinearGradientFillStyle styleWithColor1:RGBCOLOR(206, 208, 212)
                               color2:RGBCOLOR(184, 186, 190) next:
    [BFFFourBorderStyle styleWithTop:RGBCOLOR(161, 161, 161) right:nil bottom:nil left:nil width:1 next:
    [BFFFourBorderStyle styleWithTop:RGBCOLOR(230, 232, 235) right:nil bottom:nil left:nil width:1
                       next:nil]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)textBarTextField {
  return
    [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(6, 0, 3, 6) next:
    [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:12.5] next:
    [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(1, 0, 1, 0) next:
    [BFFShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.4) blur:0 offset:CGSizeMake(0, 1) next:
    [BFFSolidFillStyle styleWithColor:BFFSTYLEVAR(backgroundColor) next:
    [BFFInnerShadowStyle styleWithColor:RGBACOLOR(0,0,0,0.4) blur:3 offset:CGSizeMake(0, 2) next:
    [BFFBevelBorderStyle styleWithHighlight:RGBACOLOR(0,0,0,0.25) shadow:RGBACOLOR(0,0,0,0.4)
                        width:1 lightSource:270 next:nil]]]]]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)textBarPostButton:(UIControlState)state {
  UIColor* fillColor = state == UIControlStateHighlighted
                       ? RGBCOLOR(19, 61, 126)
                       : RGBCOLOR(31, 100, 206);
  UIColor* textColor = state == UIControlStateDisabled
                       ? RGBACOLOR(255, 255, 255, 0.5)
                       : RGBCOLOR(255, 255, 255);
  return
    [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:13] next:
    [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(2, 0, 1, 0) next:
    [BFFShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.5) blur:0 offset:CGSizeMake(0, 1) next:
    [BFFReflectiveFillStyle styleWithColor:fillColor next:
    [BFFLinearGradientBorderStyle styleWithColor1:fillColor
                                 color2:RGBCOLOR(14, 83, 187) width:1 next:
    [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1) next:
    [BFFBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 9, 8, 9) next:
    [BFFTextStyle styleWithFont:[UIFont boldSystemFontOfSize:15]
                 color:textColor shadowColor:[UIColor colorWithWhite:0 alpha:0.3]
                 shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public colors


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Common styles


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)textColor {
  return [UIColor blackColor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)highlightedTextColor {
  return [UIColor whiteColor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)font {
  return [UIFont systemFontOfSize:14];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)backgroundColor {
  return [UIColor whiteColor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)navigationBarTintColor {
  return RGBCOLOR(119, 140, 168);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)toolbarTintColor {
  return RGBCOLOR(109, 132, 162);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)searchBarTintColor {
  return RGBCOLOR(200, 200, 200);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Tables


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tablePlainBackgroundColor {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableGroupedBackgroundColor {
  return [UIColor groupTableViewBackgroundColor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)searchTableBackgroundColor {
  return RGBCOLOR(235, 235, 235);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)searchTableSeparatorColor {
  return [UIColor colorWithWhite:0.85 alpha:1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Table Items


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)linkTextColor {
  return RGBCOLOR(87, 107, 149);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)timestampTextColor {
  return RGBCOLOR(36, 112, 216);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)moreLinkTextColor {
  return RGBCOLOR(36, 112, 216);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Table Headers


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableHeaderTextColor {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableHeaderShadowColor {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)tableHeaderShadowOffset {
  return CGSizeMake(0, 1);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableHeaderTintColor {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Photo Captions


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)photoCaptionTextColor {
  return [UIColor whiteColor];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)photoCaptionTextShadowColor {
  return [UIColor colorWithWhite:0 alpha:0.9];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)photoCaptionTextShadowOffset {
  return CGSizeMake(0, 1);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Unsorted


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)screenBackgroundColor {
  return [UIColor colorWithWhite:0 alpha:0.8];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableActivityTextColor {
  return RGBCOLOR(99, 109, 125);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableErrorTextColor {
  return RGBCOLOR(96, 103, 111);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableSubTextColor {
  return RGBCOLOR(79, 89, 105);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableTitleTextColor {
  return RGBCOLOR(99, 109, 125);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tabBarTintColor {
  return RGBCOLOR(119, 140, 168);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tabTintColor {
  return RGBCOLOR(228, 230, 235);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)messageFieldTextColor {
  return [UIColor colorWithWhite:0.5 alpha:1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)messageFieldSeparatorColor {
  return [UIColor colorWithWhite:0.7 alpha:1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)thumbnailBackgroundColor {
  return [UIColor colorWithWhite:0.95 alpha:1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)postButtonColor {
  return RGBCOLOR(117, 144, 181);
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// public fonts


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)buttonFont {
  return [UIFont boldSystemFontOfSize:12];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableFont {
  return [UIFont boldSystemFontOfSize:17];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableSmallFont {
  return [UIFont boldSystemFontOfSize:15];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableTitleFont {
  return [UIFont boldSystemFontOfSize:13];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableTimestampFont {
  return [UIFont systemFontOfSize:13];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableButtonFont {
  return [UIFont boldSystemFontOfSize:13];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableSummaryFont {
  return [UIFont systemFontOfSize:17];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableHeaderPlainFont {
  return [UIFont boldSystemFontOfSize:16];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableHeaderGroupedFont {
  return [UIFont boldSystemFontOfSize:18];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)photoCaptionFont {
  return [UIFont boldSystemFontOfSize:12];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)messageFont {
  return [UIFont systemFontOfSize:15];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)errorTitleFont {
  return [UIFont boldSystemFontOfSize:18];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)errorSubtitleFont {
  return [UIFont boldSystemFontOfSize:12];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)activityLabelFont {
  return [UIFont systemFontOfSize:17];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)activityBannerFont {
  return [UIFont boldSystemFontOfSize:11];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableViewCellSelectionStyle)tableSelectionStyle {
  return UITableViewCellSelectionStyleBlue;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)toolbarButtonColorWithTintColor:(UIColor*)color forState:(UIControlState)state {
  if (state & UIControlStateHighlighted || state & UIControlStateSelected) {
    if (color.value < 0.2) {
      return [color addHue:0 saturation:0 value:0.2];
    } else if (color.saturation > 0.3) {
      return [color multiplyHue:1 saturation:1 value:0.4];
    } else {
      return [color multiplyHue:1 saturation:2.3 value:0.64];
    }
  } else {
    if (color.saturation < 0.5) {
      return [color multiplyHue:1 saturation:1.6 value:0.97];
    } else {
      return [color multiplyHue:1 saturation:1.25 value:0.75];
    }
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)toolbarButtonTextColorForState:(UIControlState)state {
  if (state & UIControlStateDisabled) {
    return [UIColor colorWithWhite:1 alpha:0.4];
  } else {
    return [UIColor whiteColor];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)selectionFillStyle:(BFFStyle*)next {
  return [BFFLinearGradientFillStyle styleWithColor1:RGBCOLOR(5,140,245)
                                    color2:RGBCOLOR(1,93,230) next:next];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)toolbarButtonForState:(UIControlState)state shape:(BFFShape*)shape
            tintColor:(UIColor*)tintColor font:(UIFont*)font {
  UIColor* stateTintColor = [self toolbarButtonColorWithTintColor:tintColor forState:state];
  UIColor* stateTextColor = [self toolbarButtonTextColorForState:state];

  return
    [BFFShapeStyle styleWithShape:shape next:
    [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(2, 0, 1, 0) next:
    [BFFShadowStyle styleWithColor:RGBACOLOR(255,255,255,0.18) blur:0 offset:CGSizeMake(0, 1) next:
    [BFFReflectiveFillStyle styleWithColor:stateTintColor next:
    [BFFBevelBorderStyle styleWithHighlight:[stateTintColor multiplyHue:1 saturation:0.9 value:0.7]
                        shadow:[stateTintColor multiplyHue:1 saturation:0.5 value:0.6]
                        width:1 lightSource:270 next:
    [BFFInsetStyle styleWithInset:UIEdgeInsetsMake(0, -1, 0, -1) next:
    [BFFBevelBorderStyle styleWithHighlight:nil shadow:RGBACOLOR(0,0,0,0.15)
                        width:1 lightSource:270 next:
    [BFFBoxStyle styleWithPadding:UIEdgeInsetsMake(8, 8, 8, 8) next:
    [BFFImageStyle styleWithImageURL:nil defaultImage:nil
                  contentMode:UIViewContentModeScaleToFill size:CGSizeZero next:
    [BFFTextStyle styleWithFont:font
                 color:stateTextColor shadowColor:[UIColor colorWithWhite:0 alpha:0.4]
                 shadowOffset:CGSizeMake(0, -1) next:nil]]]]]]]]]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BFFStyle*)pageDotWithColor:(UIColor*)color {
  return
    [BFFBoxStyle styleWithMargin:UIEdgeInsetsMake(0,0,0,10) padding:UIEdgeInsetsMake(6,6,0,0) next:
    [BFFShapeStyle styleWithShape:[BFFRoundedRectangleShape shapeWithRadius:2.5] next:
    [BFFSolidFillStyle styleWithColor:color next:nil]]];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BFFDefaultStyleSheet (BFFDragRefreshHeader)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableRefreshHeaderLastUpdatedFont {
  return [UIFont systemFontOfSize:12.0f];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIFont*)tableRefreshHeaderStatusFont {
  return [UIFont boldSystemFontOfSize:13.0f];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableRefreshHeaderBackgroundColor {
  return RGBCOLOR(226, 231, 237);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableRefreshHeaderTextColor {
  return RGBCOLOR(87, 108, 137);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIColor*)tableRefreshHeaderTextShadowColor {
  return [UIColor colorWithWhite:0.9 alpha:1];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGSize)tableRefreshHeaderTextShadowOffset {
  return CGSizeMake(0.0f, 1.0f);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIImage*)tableRefreshHeaderArrowImage {
  return BFFIMAGE(@"bundle://Three20.bundle/images/blueArrow.png");
}


@end
