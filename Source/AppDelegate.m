//
//  AppDelegate.m
//  Sigmote
//
//  Created by Alexandre Aybes on 3/20/16.
//  Copyright © 2016 Pomm'Soft. All rights reserved.
//

#import "AppDelegate.h"

#import "PSClasseSigmaController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (strong) NSStatusItem *statusItem;

@property (strong) PSClasseSigmaController *sigmaController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.sigmaController = [[PSClasseSigmaController alloc] init];
    [self.sigmaController connectWithCallback:^(PSClasseSigmaController *controller) {
        // enable the menu!
    }];


    NSStatusBar *bar = [NSStatusBar systemStatusBar];
    self.statusItem = [bar statusItemWithLength:NSVariableStatusItemLength];

    self.statusItem.title = @"Sigmote";

    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Sigmote"];
    NSMenuItem *item = [menu addItemWithTitle:@"wake" action:@selector(wake:) keyEquivalent:@""];
    item.target = self;

    self.statusItem.menu = menu;

}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

#pragma mark - menu actions

- (void)wake:(id)sender
{

}

@end
