//
//  PSClasseSigmaController.h
//  Remote
//
//  Created by Alexandre Aybes on 10/25/15.
//  Copyright © 2015 Pomm'Soft. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PSRemoteController <NSObject>
@end

@protocol PSRemoteJoystickController <PSRemoteController>

- (void)sendUp;
- (void)sendDown;
- (void)sendLeft;
- (void)sendRight;

- (void)sendMenu;
- (void)sendHome;
- (void)sendEnter;

@end


@class PSClasseSigmaController;

typedef void(^PSClasseSigmaControllerConnectionCallback)(PSClasseSigmaController *controller);

@interface PSClasseSigmaController : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *version;

- (void)connectWithCallback:(PSClasseSigmaControllerConnectionCallback)callback;
- (void)disconnect;

@end
