//
//  BFFMapKitTableCell.m
//  Locurious
//
//  Created by jamie on 8/26/10.
//  Copyright 2010 binaryfinery.com. All rights reserved.
//

#import "BFFMapKitTableCell.h"
#import <MapKit/MapKit.h>
#import "BFFMapTableItem.h"

@implementation BFFMapKitTableCell

+ (CGFloat)tableView:(UITableView*)tableView rowHeightForObject:(id)object {
  return 200;
}


- (void)layoutSubviews {
  [super layoutSubviews];
  if (_control == nil ) {
    _control = [[MKMapView alloc] init];
    [self.contentView addSubview:_control];
    _control.zoomEnabled = NO;
    _control.scrollEnabled = NO;
  }
  if (_needsUpdate) {
    MKCoordinateRegion region;
    MKPointAnnotation* point;
    
    if ([_object isKindOfClass:[MKPointAnnotation class]]) {
      point = (MKPointAnnotation*) _object;
      region.center = point.coordinate;
    }
    else if ([_object isKindOfClass:[BFFMapTableItem class]]) {
      BFFMapTableItem* mapItem = (BFFMapTableItem*) _object;
      point = mapItem.annotation;
    }
    else {
      return;
    }
    region.center = point.coordinate;
    region = MKCoordinateRegionMakeWithDistance(point.coordinate, 500, 500);
    [_control addAnnotation:point];
    //  [_control setRegion:region animated:NO];
    _control.region = region;
    //  [_control setRegion:[_control regionThatFits:region] animated:FALSE];
    CGRect rect = CGRectInset(self.contentView.bounds, 2, kTableCellSpacing / 2);
    _control.frame = rect;
  }
}

- (void)didMoveToSuperview {
  [super didMoveToSuperview];
}

- (void)setObject:(id)object {
  _object = object;
  _needsUpdate = TRUE;

}
@end
