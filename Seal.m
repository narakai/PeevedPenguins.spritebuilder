//
//  Seal.m
//  PeevedPenguins
//
//  Created by leon on 14-4-12.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Seal.h"

@implementation Seal

-(void)didLoadFromCCB{
    [self.physicsBody setCollisionType:@"seal"];
}

//-(id) init {
//    self = [super init];
//    if(self){
//        CCLOG(@"Seal created!");
//    }
//    return self;
//}

@end