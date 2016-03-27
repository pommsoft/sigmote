//
//  PSClasseSigmaController.m
//  Remote
//
//  Created by Alexandre Aybes on 10/25/15.
//  Copyright © 2015 Pomm'Soft. All rights reserved.
//

#import "PSClasseSigmaController.h"

typedef NS_OPTIONS(NSUInteger, PSClasseSigmaControllerIRCode) {
    PSClasseSigmaControllerIRCodeSource1 = 2,
    PSClasseSigmaControllerIRCodeSource2 = 3,
    PSClasseSigmaControllerIRCodeSource3 = 4,
    PSClasseSigmaControllerIRCodeSource4 = 5,
    PSClasseSigmaControllerIRCodeSource5 = 6,
    PSClasseSigmaControllerIRCodeSource6 = 7,
    PSClasseSigmaControllerIRCodeSource7 = 8,
    PSClasseSigmaControllerIRCodeSource8 = 9,
    PSClasseSigmaControllerIRCodeSource9 = 120,
    PSClasseSigmaControllerIRCodeSource10 = 121,
    PSClasseSigmaControllerIRCodeSource11 = 122,
    PSClasseSigmaControllerIRCodeSource12 = 123,
    PSClasseSigmaControllerIRCodeSource13 = 124,
    PSClasseSigmaControllerIRCodeSource14 = 125,
    PSClasseSigmaControllerIRCodeSource15 = 126,
    PSClasseSigmaControllerIRCodeSource16 = 127,
    PSClasseSigmaControllerIRCodeSource17 = 128,
    PSClasseSigmaControllerIRCodeSource18 = 129,

    PSClasseSigmaControllerIRCodeSourceUp = 10,
    PSClasseSigmaControllerIRCodeSourceDown = 11,

    PSClasseSigmaControllerIRCodeStandbyToggle = 12,

    PSClasseSigmaControllerIRCodeMuteToggle = 13,
    PSClasseSigmaControllerIRCodeMuteOn = 152,
    PSClasseSigmaControllerIRCodeMuteOff = 153,

    PSClasseSigmaControllerIRCodeVolumeUp = 16,
    PSClasseSigmaControllerIRCodeVolumeDown = 17,

    PSClasseSigmaControllerLateNightToggle = 19,
    PSClasseSigmaControllerIRCodeLateNightOn = 160,
    PSClasseSigmaControllerIRCodeLateNightOff = 161,

    PSClasseSigmaControllerMenu = 84,
    PSClasseSigmaControllerHome = 85,

    PSClasseSigmaControllerStepUp = 88,
    PSClasseSigmaControllerStepDown = 89,
    PSClasseSigmaControllerStepLeft = 90,
    PSClasseSigmaControllerStepRight = 91,
};

// D81EDE is B&W Group mac address prefix

@interface PSClasseSigmaController () <NSStreamDelegate, NSNetServiceBrowserDelegate, NSNetServiceDelegate>

@property (strong, nonatomic) NSNetServiceBrowser *browser;

@property (strong, nonatomic) NSInputStream *inputStream;
@property (strong, nonatomic) NSOutputStream *outputStream;

@property (strong, nonatomic) PSClasseSigmaControllerConnectionCallback connectionCallback;

@property (strong, nonatomic) NSMutableSet *services;

@end

@implementation PSClasseSigmaController

- (id)init
{
    if (self = [super init]) {
        self.browser = [NSNetServiceBrowser new];
    }

    return self;
}

- (void)connectWithCallback:(PSClasseSigmaControllerConnectionCallback)callback
{
    self.connectionCallback = callback;

//    [self connectWithHostName:@"Sigma-SSP-219568.local."];

    [self.browser searchForServicesOfType:@"_raop._tcp" inDomain:@""];
}

- (void)connectWithHostName:(NSString*)hostName
{
    NSInputStream *input = nil;
    NSOutputStream *output = nil;

    [NSStream getStreamsToHostWithName:hostName port:50001 inputStream:&input outputStream:&output];

    self.inputStream = input;
    self.outputStream = output;

    [self performSelector:@selector(sendCommand:) withObject:@"VERS\n" afterDelay:1.0];
}

- (void)disconnect
{
    self.inputStream = nil;
    self.outputStream = nil;
}

#pragma mark - commands

- (void)sendCommand:(NSString*)command
{
    uint8_t *buffer = (uint8_t *)calloc(1024, 1);
    NSUInteger actualLength = 0;
    [command getBytes:buffer maxLength:1024 usedLength:&actualLength encoding:NSASCIIStringEncoding options:NSStringEncodingConversionAllowLossy range:NSMakeRange(0, command.length) remainingRange:NULL];

    NSLog(@"Space: %@", [self.outputStream hasSpaceAvailable] ? @"YES" : @"NO");

    NSInteger written = [self.outputStream write:buffer maxLength:actualLength];

    NSLog(@"Written: %li of (%lu)", (long)written, (unsigned long)actualLength);
    actualLength = [self.inputStream read:buffer maxLength:1024];

    NSLog(@"Read: %lu, %@", (unsigned long)actualLength, [[NSString alloc] initWithBytes:buffer length:actualLength encoding:NSASCIIStringEncoding]);
    free(buffer);
}

#pragma mark - setters

- (void)setBrowser:(NSNetServiceBrowser *)browser
{
    if (_browser != browser) {
        _browser.delegate = nil;
        _browser = browser;
        _browser.delegate = self;
    }
}

- (void)setInputStream:(NSInputStream *)inputStream
{
    if (inputStream != _inputStream) {
        _inputStream.delegate = nil;
        [_inputStream close];
        _inputStream = inputStream;
        _inputStream.delegate = self;
        [_inputStream open];
    }
}

- (void)setOutputStream:(NSOutputStream *)outputStream
{
    if (outputStream != _outputStream) {
        _outputStream.delegate = nil;
        [_outputStream close];
        _outputStream = outputStream;
        _outputStream.delegate = self;
        [_outputStream open];
    }
}

#pragma mark - NSStreamDelegate

- (void)handleOutputStreamEvent:(NSStreamEvent)eventCode
{
    NSLog(@"Output: %lu", (unsigned long)eventCode);
    if (eventCode == NSStreamEventHasBytesAvailable) {
        NSLog(@"Bytes available!");
    }
}

- (void)handleInputStreamEvent:(NSStreamEvent)eventCode
{
    NSLog(@"Input: %lu", (unsigned long)eventCode);
    if (eventCode == NSStreamEventHasBytesAvailable) {
        NSLog(@"Bytes available!");
    }
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    if (aStream == self.outputStream) {
        [self handleOutputStreamEvent:eventCode];
    } else if (aStream == self.inputStream) {
        [self handleInputStreamEvent:eventCode];
    }
}

#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    NSLog(@"Service Found: %@", service);

    if (self.services == nil) {
        self.services = [NSMutableSet new];
    }

    service.delegate = self;
    [service resolveWithTimeout:20.0];

    [self.services addObject:service];
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    NSLog(@"Resolved: %@", sender);
    if ([sender.name hasPrefix:@"D81EDE"]) {
        // B&W Group max address prefix
        [self performSelectorOnMainThread:@selector(connectWithHostName:) withObject:sender.hostName waitUntilDone:NO];
        [self.services makeObjectsPerformSelector:@selector(stop)];
    } else {
        sender.delegate = nil;
    }
    [self.services removeObject:sender];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *, NSNumber *> *)errorDict
{
    NSLog(@"NOT RESOLVED: %@ -> %@", sender, errorDict);
}

@end
