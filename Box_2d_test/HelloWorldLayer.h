#import "cocos2d.h"
#import "Box2D.h"
#import "VRope.h"


#define PTM_RATIO 32.0

@interface HelloWorldLayer : CCLayer {
    
    b2World * _world;
    b2Body * _body;
    CCSprite * _ball;
    
    // for the joint
    b2RopeJoint * rope_joint;
//    b2Joint * rope_joint;
    b2RopeJointDef rope_joint_def;
    b2Body * attachmentSite;
    CCSprite * attachmentSiteSprite;
    
    float ropeLength;
    
    int swings; // the number of swings to stop multiple lifts per swing;
    float swingHeight;
    int isGoingUp;
    
    bool isBeingLifted;
    bool isGoingRight;
    bool isJumping;
    bool isDetached;
    
    b2Body *anchorBody;
    CCSpriteBatchNode *ropeSpriteSheet;
    NSMutableArray * vRopes;
    
}

+ (id) scene;
- (void) kick;

@end