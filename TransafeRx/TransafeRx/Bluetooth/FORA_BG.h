//
//  FORA_BG.h
//  ForaBT
//
//  Created by Tachl on 7/20/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

#import "CoreForaBgDevice.h"

@interface FORA_BG : CoreForaBgDevice
    
- (instancetype)initWithDelegate:(id<ForaBgBluetoothDelegate>)delegate;
@end
