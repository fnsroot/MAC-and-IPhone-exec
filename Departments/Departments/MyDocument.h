//
//  MyDocument.h
//  Departments
//
//  Created by  on 12-6-17.
//  Copyright (c) 2012年 derrik.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MyDocument : NSPersistentDocument

{
    IBOutlet NSBox *box;
    IBOutlet NSPopUpButton *popUp;
    NSMutableArray *viewControllers;
}-
(IBAction)changeViewController:(id)sender;
@end
