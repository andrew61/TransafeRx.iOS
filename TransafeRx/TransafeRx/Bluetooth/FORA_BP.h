//
//  FORA_BP.h
//  ForaBT
//
//  Created by Tachl on 7/19/17.
//  Copyright © 2017 Tachl. All rights reserved.
//

#import "CoreForaBpDevice.h"

@interface FORA_BP : CoreForaBpDevice

- (instancetype)initWithDelegate:(id<ForaBpBluetoothDelegate>)delegate;
    
@end
