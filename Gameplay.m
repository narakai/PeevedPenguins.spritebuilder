//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by leon on 14-4-13.
//  Copyright (c) 2014年 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "Penguin.h"

@implementation Gameplay {

CCPhysicsNode *_physicsNode;
CCNode *_catapult;
CCNode *_catapultArm;
CCNode *_levelNode; 
CCNode *_contentNode;
    
CCPhysicsJoint *_catapultJoint;
    
CCNode *_pullbackNode;
CCPhysicsJoint *_pullbackJoint;
    
CCNode *_mouseJointNode;
CCPhysicsJoint *_mouseJoint;
    
Penguin *_currentPenguin;
CCPhysicsJoint *_penguinCatapultJoint;
    
CCAction *_followPenguin;
    
CCNode *_waitingPenguin1;
CCNode *_waitingPenguin2;
CCNode *_waitingPenguin3;
    
}

static const float MIN_SPEED = 5.f;
int leftPenguin = 3;

-(void)didLoadFromCCB{
    
    self.userInteractionEnabled = TRUE;
    CCScene *level = [CCBReader loadAsScene:@"Levels/Level1"];
    [_levelNode addChild:level];
    
//    _physicsNode.debugDraw = TRUE;
    _physicsNode.collisionDelegate = self;
    
    [_catapultArm.physicsBody setCollisionGroup:_catapult];
    [_catapult.physicsBody setCollisionGroup:_catapult];
    
    _catapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_catapultArm.physicsBody bodyB:_catapult.physicsBody anchorA:_catapultArm.anchorPointInPoints];
    
    _pullbackNode.physicsBody.collisionMask=@[];
    
    _pullbackJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_pullbackNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0,0) anchorB:ccp(34,144) restLength:60.f stiffness:500.f damping:40.f];
    
    _mouseJointNode.physicsBody.collisionMask=@[];
    
}



-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    if (ccpLength(_currentPenguin.physicsBody.velocity) == 0.f) {
    
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation)) {
        _mouseJointNode.position = touchLocation;
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0,0) anchorB:ccp(34,144) restLength:0.f stiffness:3000.f damping:150.f];
        
        _currentPenguin = (Penguin*)[CCBReader load:@"Penguin"];
        CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34,144)];
        _currentPenguin.position = [_physicsNode convertToNodeSpace:penguinPosition];
        [_physicsNode addChild:_currentPenguin];
        _currentPenguin.physicsBody.allowsRotation = FALSE;
        _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
    }
    }
}
    
-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    _mouseJointNode.position = touchLocation;
}

-(void)releaseCatapult{
    _currentPenguin.launched = TRUE;
    if (_mouseJoint != nil) {
        [_mouseJoint invalidate];
        _mouseJoint = nil;
        [_penguinCatapultJoint invalidate];
        _penguinCatapultJoint = nil;
        _currentPenguin.physicsBody.allowsRotation = TRUE;
        _followPenguin = [CCActionFollow actionWithTarget:_currentPenguin worldBoundary:self.boundingBox];
        [_contentNode runAction:_followPenguin];
    }
}


//-(void)launchPenguin{
//    CCNode* penguin = [CCBReader load:@"Penguin"];
//    penguin.position = ccpAdd(_catapultArm.position, ccp(255, 205));
//    
//    [_physicsNode addChild:penguin];
//    
//    CGPoint launchDirection = ccp(1, 0);
//    CGPoint force = ccpMult(launchDirection, 8000);
//    [penguin.physicsBody applyForce:force];
//    
//    self.position = ccp(0,0);
//    CCActionFollow *follow = [CCActionFollow actionWithTarget:penguin worldBoundary:self.boundingBox];
//    [_contentNode runAction:follow];
//    }

-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    [self releaseCatapult];
}

-(void)touchCancelled:(UITouch *)touch withEvent:(UIEvent *)event{
    [self releaseCatapult];
}

-(void)retry{
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
    leftPenguin = 3;
    
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
    CCLOG(@"something collided with a seal!");
//    float energy = [pair totalKineticEnergy];
//    if (energy > 5000.f) {
//        [self sealRemoved:nodeA];
//    }
}

//-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB {
//    CCLOG(@"something collided with a seal!");
//}


//-(void)sealRemoved:(CCNode *)seal{
//    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"SealExplosion"];
////    explosion.autoRemoveOnFinish = TRUE;
//    explosion.position = seal.position;
//    [seal.parent addChild:explosion];
//    [seal removeFromParent];
//}

-(void)update:(CCTime)delta{
    if (_currentPenguin.launched) {
        
    if (ccpLength(_currentPenguin.physicsBody.velocity)<MIN_SPEED) {
        [self nextAttempt];
        return;
    }
    //left side of penguin
    int xMin = _currentPenguin.boundingBox.origin.x;
    if (xMin > (self.boundingBox.origin.x+self.boundingBox.size.width) ){
        [self nextAttempt];
        return;
    }
    //right side of penguin
    int xMax = xMin + _currentPenguin.boundingBox.size.width;
    if (xMax < self.boundingBox.origin.x) {
        [self nextAttempt];
        return;
    }

    }
}
-(void)nextAttempt{
    _currentPenguin = nil;
    [_contentNode stopAction:_followPenguin];
//    _followPenguin = nil;
    CCActionMoveTo *actionMoveTo = [CCActionMoveTo actionWithDuration:1.f position:ccp(0,0)];
    [_contentNode runAction:actionMoveTo];
    switch (leftPenguin) {
        case 3:
            _waitingPenguin1.removeFromParent;
            break;
        case 2:
            _waitingPenguin2.removeFromParent;
            break;
        case 1:
            _waitingPenguin3.removeFromParent;
            break;
        default:
            break;
    }
    leftPenguin = leftPenguin - 1;
    if (leftPenguin < 1) {
        CCLOG(@"GAMEOVER");
    }
    
}
@end
