//
//  Foo.m
//  RandomAPP
//
//  Created by liudongbao on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "Foo.h"

@implementation Foo
- (IBAction)seed:(id)sender
{
    // Seed the random number generator with the time srandom(time(NULL));
    [textField setStringValue:@"Generator seeded"];
}

- (IBAction)generate:(id)sender
{
    // Generate a number between 1 and 100 inclusive
    int generated;

    generated = (random() % 100) + 1;
    NSLog(@"generated = %d", generated);
    // Ask the text field to change what it is displaying
    [textField setIntValue:generated];
    int i=43;
    printf("%d\n",printf("%d",printf("%d",i)));

}

-(void)awakeFromNib{
    NSCalendarDate * now;
    now = [NSCalendarDate calendarDate];
    [textField setObjectValue:now];
}
@end