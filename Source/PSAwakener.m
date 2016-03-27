//
//  PSAwakener.m
//  Sigmote
//
//  Created by Alexandre Aybes on 3/27/16.
//  Copyright © 2016 Pomm'Soft. All rights reserved.
//

#import "PSAwakener.h"

#import <netinet/in.h>

@interface PSWakeable : NSObject <PSWakeable>

- (instancetype)initWithDictionaryRepresentation:(NSDictionary*)dictionary;
@property (nonatomic, readonly) NSDictionary *dictionaryRepresentation;
@property (nonatomic, copy) NSString *name;

@end

@implementation PSWakeable
{
    @private
    unsigned char _macAddress[6];
}

@synthesize name;

- (instancetype)initWithDictionaryRepresentation:(NSDictionary*)dictionary
{
    self = [super init];

    if (nil != self) {
        self.name = dictionary[@"name"];
        NSArray *array = dictionary[@"mac"];
        if ([array isKindOfClass:[NSArray class]] && [array count] == 6) {
            for (int i = 0; i < 6; i++) {
                _macAddress[i] = [array[i] unsignedCharValue];
            }
        } else {
            self = nil;
        }
    }

    return self;
}

- (NSDictionary*)dictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary new];

    if (nil != self.name) {
        dict[@"name"] = self.name;
    }
    dict[@"mac"] = @[@(_macAddress[0]),
                     @(_macAddress[1]),
                     @(_macAddress[2]),
                     @(_macAddress[3]),
                     @(_macAddress[4]),
                     @(_macAddress[5])];


    return dict;
}

- (void)copyMacAddressTo:(unsigned char *)buffer
{
    for (int i = 0; i < 6; i++) {
        buffer[i] = _macAddress[i];
    }
}

@end

@implementation PSAwakener

- (void)wakeAll
{

}

- (void)wake:(id <PSWakeable>)wakeable
{
    unsigned char wolPacket[102]; // (6 times 0xFF + 16 times the 6 bytes of the mac address -> 6 x 17 = 102)

    // code from: https://shadesfgray.wordpress.com/2010/12/17/wake-on-lan-how-to-tutorial/

    // first 6 bytes must be 0xFF
    for (int i = 0; i < 6; i++) {
        wolPacket[i] = 0xFF;
    }

    // next, append the mac address 16 times
    for (int i = 1; i < 17; i++) {
        [wakeable copyMacAddressTo:&(wolPacket[i])];
    }

    // now the wol packet is ready
    int udpSocket;
    struct sockaddr_in udpClient, udpServer;
    int broadcast = 1;

    udpSocket = socket(AF_INET, SOCK_DGRAM, 0);

    /** you need to set this so you can broadcast **/
    if (setsockopt(udpSocket, SOL_SOCKET, SO_BROADCAST, &broadcast, sizeof broadcast) == -1) {
        perror("setsockopt (SO_BROADCAST)");
        exit(1);
    }
    udpClient.sin_family = AF_INET;
    udpClient.sin_addr.s_addr = INADDR_ANY;
    udpClient.sin_port = 0;

    bind(udpSocket, (struct sockaddr*)&udpClient, sizeof(udpClient));

    /** …make the packet as shown above **/

    /** set server end point (the broadcast addres)**/
    udpServer.sin_family = AF_INET;
    // TODO-AA: find own IP address and compute broadcast address
    udpServer.sin_addr.s_addr = 0x0A0001FF; // 10.0.1.255
    udpServer.sin_port = htons(9);

    /** send the packet **/
    sendto(udpSocket, wolPacket, sizeof(unsigned char) * 102, 0, (struct sockaddr*)&udpServer, sizeof(udpServer));
    

}

@end
