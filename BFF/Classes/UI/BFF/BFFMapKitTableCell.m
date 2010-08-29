//
//  BFFMapKitTableCell.m
//  Locurious
//
//  Created by jamie on 8/26/10.
//  Copyright 2010 binaryfinery.com. All rights reserved.
//

#import "BFFMapKitTableCell.h"
#import <MapKit/MapKit.h>

@implementation BFFMapKitTableCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  return 320;
}


- (void)layoutSubviews {
  [super layoutSubviews];
  _control.frame = CGRectInset(self.contentView.bounds, 2, kTableCellSpacing / 2);
}


- (void)setObject:(id)object {
  BFF_RELEASE_SAFELY(_control);
  _control = [[MKMapView alloc] init];
  [self.contentView addSubview:_control];
}
@end
