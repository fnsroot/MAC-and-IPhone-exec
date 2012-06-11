//
//  BigLetterView.m
//  TypingTutor
//
//  Created by  on 12-6-9.
//  Copyright (c) 2012年 derrik.org. All rights reserved.
//

#import "BigLetterView.h"
#import "NSString+FirstLetter.h"

@implementation BigLetterView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        NSLog(@"initializing view");
        bgColor = [NSColor yellowColor];
        string = @" ";
    }

    [self prepareAttributes];
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = [self bounds];

    [bgColor set];
    [NSBezierPath fillRect:bounds];
    [self drawStringCenteredIn:bounds];

    // Am I the window's first responder?
    if (([[self window] firstResponder] == self) &&
        [NSGraphicsContext currentContextDrawingToScreen]) {
        [NSGraphicsContext saveGraphicsState];
        NSSetFocusRingStyle(NSFocusRingOnly);
        [NSBezierPath fillRect:bounds];
        [NSGraphicsContext restoreGraphicsState];
    }
}

- (BOOL)isOpaque
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    NSLog(@"Accepting");
    return YES;
}

- (BOOL)resignFirstResponder
{
    NSLog(@"Resigning");
    [self setKeyboardFocusRingNeedsDisplayInRect:[self bounds]];
    return YES;
}

- (BOOL)becomeFirstResponder
{
    NSLog(@"Becoming");
    [self setNeedsDisplay:YES];
    return YES;
}

- (void)keyDown:(NSEvent *)event
{
    [self interpretKeyEvents:[NSArray arrayWithObject:event]];
}

- (void)insertText:(NSString *)input
{
    // Set string to be what the user typed
    [self setString:input];
}

- (void)insertTab:(id)sender
{
    [[self window] selectKeyViewFollowingView:self];
}

// Be careful with capitalization here, "backtab" is considered
// one word.
- (void)insertBacktab:(id)sender
{
    [[self window] selectKeyViewPrecedingView:self];
}

- (void)deleteBackward:(id)sender
{
    [self setString:@" "];
}

- (void)prepareAttributes
{
    attributes = [NSMutableDictionary dictionary];
    [attributes setObject   :[NSFont userFontOfSize:75]
                forKey      :NSFontAttributeName];
    [attributes setObject   :[NSColor redColor]
                forKey      :NSForegroundColorAttributeName];
}

- (void)drawStringCenteredIn:(NSRect)r
{
    NSSize  strSize = [string sizeWithAttributes:attributes];
    NSPoint strOrigin;

    strOrigin.x = r.origin.x + (r.size.width - strSize.width) / 2;
    strOrigin.y = r.origin.y + (r.size.height - strSize.height) / 2;
    [string drawAtPoint:strOrigin withAttributes:attributes];
}

- (IBAction)savePDF:(id)sender
{
    __block NSSavePanel *panel = [NSSavePanel savePanel];

    [panel setAllowedFileTypes:[NSArray arrayWithObject:@"pdf"]];
    [panel  beginSheetModalForWindow:[self window]
            completionHandler       :^(NSInteger result) {
            if (result == NSOKButton) {
                NSRect r = [self bounds];
                NSData *data = [self dataWithPDFInsideRect:r];
                NSError *error;
                BOOL successful = [data writeToURL  :[panel URL]
                                        options     :0
                                        error       :&error];

                if (!successful) {
                    NSAlert *a = [NSAlert alertWithError:error];
                    [a runModal];
                }
            }

            panel = nil;           // avoid strong ref cycle
        }];
}

- (void)writeToPasteboard:(NSPasteboard *)pb
{
    // Copy data to the pasteboard
    [pb clearContents];
    [pb writeObjects:[NSArray arrayWithObject:string]];
}

- (BOOL)readFromPasteboard:(NSPasteboard *)pb
{
    NSArray *classes = [NSArray arrayWithObject:[NSString class]];
    NSArray *objects = [pb  readObjectsForClasses   :classes
                            options                 :nil];

    if ([objects count] > 0) {
        // Read the string from the pasteboard
        NSString *value = [objects objectAtIndex:0];
        [self setString:[value bnr_firstLetter]];
        return YES;
    }

    return NO;
}

- (IBAction)cut:(id)sender
{
    [self copy:sender];
    [self setString:@""];
}

- (IBAction)copy:(id)sender
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];

    [self writeToPasteboard:pb];
}

- (IBAction)paste:(id)sender
{
    NSPasteboard *pb = [NSPasteboard generalPasteboard];

    if (![self readFromPasteboard:pb]) {
        NSBeep();
    }
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
    return NSDragOperationCopy| NSDragOperationDelete;
}

- (void)mouseDown:(NSEvent *)event
{
    mouseDownEvent = event;
}

- (void)mouseDragged:(NSEvent *)event
{
    NSPoint down = [mouseDownEvent locationInWindow];
    NSPoint drag = [event locationInWindow];
    float distance = hypot(down.x - drag.x, down.y - drag.y);
    if (distance < 3) {
        return;
    }
    // Is the string of zero length?
    if ([string length] == 0) {
        return;
    }
    // Get the size of the string
    NSSize s = [string sizeWithAttributes:attributes];
    // Create the image that will be dragged
    NSImage *anImage = [[NSImage alloc] initWithSize:s];
    // Create a rect in which you will draw the letter
    // in the image
    NSRect imageBounds;
    imageBounds.origin = NSZeroPoint;
    imageBounds.size = s;
    // Draw the letter on the image
    [anImage lockFocus];
    [self drawStringCenteredIn:imageBounds];
    [anImage unlockFocus];
    // Get the location of the mouseDown event
    NSPoint p = [self convertPoint:down fromView:nil];
    // Drag from the center of the image
    p.x = p.x - s.width/2;
    p.y = p.y - s.height/2;
    // Get the pasteboard
    NSPasteboard *pb = [NSPasteboard pasteboardWithName:NSDragPboard];
    // Put the string on the pasteboard
    [self writeToPasteboard:pb];
    // Start the drag
    [self dragImage:anImage
                 at:p
             offset:NSZeroSize
              event:mouseDownEvent
         pasteboard:pb
             source:self
          slideBack:YES];
}


- (void)draggedImage:(NSImage *)image
             endedAt:(NSPoint)screenPoint
           operation:(NSDragOperation)operation
{
    if (operation == NSDragOperationDelete) {
        [self setString:@""];
    }
}

#pragma mark Accessors
- (void)setBgColor:(NSColor *)c
{
    bgColor = c;
    [self setNeedsDisplay:YES];
}

- (NSColor *)bgColor
{
    return bgColor;
}

- (void)setString:(NSString *)c
{
    string = c;
    NSLog(@"The string: %@", string);
    [self setNeedsDisplay:YES];
}

- (NSString *)string
{
    return string;
}

@end