//
//  BFFSectionedTableViewDelegate.m
//  Locurious
//
//  Created by jamie on 8/26/10.
//  Copyright 2010 binaryfinery.com. All rights reserved.
//

#import "BFFSectionedTableViewDelegate.h"
#import "BFFTableViewSectionedDataSource.h"
#import "BFFSection.h"

@implementation BFFSectionedTableViewDelegate

- (CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath {

  BFFTableViewSectionedDataSource* dataSource = (BFFTableViewSectionedDataSource*)tableView.dataSource;
  BFFSectionedTableData* data = dataSource.data;

  BFFSectionRow* row = [data tableView:tableView objectForRowAtIndexPath:indexPath];
  Class cls = nil;    
  float height = row.height;
  if (height >= 0.0f)
    return height;
  cls = row.cellClass;
  if (cls != nil) {
    return [cls tableView:tableView rowHeightForObject:row.item];  
  }
  id object = row.item;
  
  cls = [dataSource tableView:tableView cellClassForObject:object];
  return [cls tableView:tableView rowHeightForObject:object];  
}


@end
