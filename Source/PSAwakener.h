//
//  PSAwakener.h
//  Sigmote
//
//  Created by Alexandre Aybes on 3/27/16.
//  Copyright © 2016 Pomm'Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PSWakeable <NSObject>

@property (nonatomic, copy, readonly) NSString *name;
- (void)copyMacAddressTo:(unsigned char *)buffer;

@end

@interface PSAwakener : NSObject

- (void)wakeAll;
- (void)wake:(id <PSWakeable>)wakeable;

@end
