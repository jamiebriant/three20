//
//  BFFTableViewSectionedDataSource.h
//  Locurious
//
//  Created by jamie on 8/26/10.
//  Copyright 2010 binaryfinery.com. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "BFFSection.h"

@interface BFFTableViewSectionedDataSource : BFFTableViewDataSource {
  BFFSectionedTableData* _data;
}

@property (readonly) BFFSectionedTableData* data;

@end
