//===----------------------------------------------------------*- Swift -*-===//
//
// Created by Yikai Wu on 2024/11/3.
// Copyright © 2024 Yikai Wu. All rights reserved.
//
//===----------------------------------------------------------------------===//

#import "CALayer+Secure.h"
#import <objc/message.h>

@implementation CALayer (Secure)
- (void)disableCapture {
    SEL sel = NSSelectorFromString(@"setDisableUpdateMask:");
    ((void (*)(id, SEL, unsigned int))(void *)objc_msgSend)(self, sel, 0x12);
}
@end
