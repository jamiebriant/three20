//
//  BFFMapKitTableCell.h
//  Locurious
//
//  Created by jamie on 8/26/10.
//  Copyright 2010 binaryfinery.com. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MKMapView;

@interface BFFMapKitTableCell : BFFTableViewCell {
  MKMapView*      _control;
  id              _object;
  bool            _needsUpdate;
}

@end
