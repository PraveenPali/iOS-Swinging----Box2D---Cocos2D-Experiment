#import "HelloWorldLayer.h"

@implementation HelloWorldLayer

+ (id)scene {
    
    CCScene *scene = [CCScene node];
    HelloWorldLayer *layer = [HelloWorldLayer node];
    [scene addChild:layer];
    return scene;
    
}

- (id)init {
    
    if ((self=[super init])) {
        CGSize winSize = [CCDirector sharedDirector].winSize;

      
        
        
        

        [self setTouchEnabled:YES];
        
        
        _ball = [CCSprite spriteWithFile:@"ball.png" rect:CGRectMake(0, 0, 52, 52)];
        _ball.position = ccp(100,75); //100,300
        [self addChild:_ball];
        
        b2Vec2 gravity = b2Vec2(0.0f, -12.0f); // was -8
        _world = new b2World(gravity);
        
        
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0, 0);
        b2Body *groundBody = _world->CreateBody(&groundBodyDef);
        b2EdgeShape groundEdge;
        b2FixtureDef boxShapeDef;
        boxShapeDef.shape = &groundEdge;
        groundEdge.Set(b2Vec2(0,0),b2Vec2(winSize.width/PTM_RATIO, 0));
        groundBody-> CreateFixture(&boxShapeDef);
        groundEdge.Set(b2Vec2(0,0), b2Vec2(0,winSize.height/PTM_RATIO));
        groundBody->CreateFixture(&boxShapeDef);
        groundEdge.Set(b2Vec2(0, winSize.height/PTM_RATIO),
                       b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO));
        groundBody->CreateFixture(&boxShapeDef);
        
        groundEdge.Set(b2Vec2(winSize.width/PTM_RATIO, winSize.height/PTM_RATIO),
                       b2Vec2(winSize.width/PTM_RATIO, 0));
        groundBody->CreateFixture(&boxShapeDef);
        
        
        
        b2BodyDef ballBodyDef;
        ballBodyDef.type = b2_dynamicBody;
        ballBodyDef.position.Set(100/PTM_RATIO, 300/PTM_RATIO);
        ballBodyDef.userData = _ball;
        _body = _world->CreateBody(&ballBodyDef);
        
        b2CircleShape circle;
        circle.m_radius = 26.0 / PTM_RATIO;
        
        b2FixtureDef ballShapeDef;
        ballShapeDef.shape = &circle;
        ballShapeDef.density = 1.0f;
        ballShapeDef.friction = 0.2f;
        ballShapeDef.restitution = 0.5f; // was 0.7
        _body->CreateFixture(&ballShapeDef);
        
        
        attachmentSiteSprite = NULL;
        
//        MENU EXAMPLE WITH SELECTOR
//        
//        
        CCLabelTTF * my_label = [CCLabelTTF labelWithString:@"Reset" fontName:@"Helvetica" fontSize:30];
        CCMenuItemLabel * menuItemLabel = [CCMenuItemLabel itemWithLabel:my_label target:self selector:@selector(reset)];
        CCMenu * menu = [CCMenu menuWithItems:menuItemLabel, nil];
        [menu setPosition:ccp(winSize.width - my_label.contentSize.width/2, my_label.contentSize.height/2)];
        [self addChild:menu];
        
        isGoingRight = YES;
        
        
        //vRope code:
        
        b2BodyDef anchorBodyDef;
        anchorBodyDef.position.Set(winSize.width/PTM_RATIO/2, winSize.height/PTM_RATIO*0.7f);
        
        anchorBody = _world->CreateBody(&anchorBodyDef);
        
        ropeSpriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"rope.png"];
        [self addChild:ropeSpriteSheet];
        
        vRopes = [[NSMutableArray alloc]init];
        
        [self schedule:@selector(tick:)];

    }
    return self;
}




-(void) vRopeTest {
    
    b2Body * body;
    
    b2BodyDef ballBodyDef;
    ballBodyDef.type = b2_dynamicBody;
    ballBodyDef.position.Set(100/PTM_RATIO, 300/PTM_RATIO);
    ballBodyDef.userData = _ball;
    body = _world->CreateBody(&ballBodyDef);
    
    b2CircleShape circle;
    circle.m_radius = 26.0 / PTM_RATIO;
    
    b2FixtureDef ballShapeDef;
    ballShapeDef.shape = &circle;
    ballShapeDef.density = 1.0f;
    ballShapeDef.friction = 0.2f;
    ballShapeDef.restitution = 0.5f; // was 0.7
    body->CreateFixture(&ballShapeDef);
    
    
    
    
    b2RopeJointDef jd;
    jd.bodyA=anchorBody; //define bodies
    jd.bodyB=body;
    jd.localAnchorA = b2Vec2(0,0); //define anchors
    jd.localAnchorB = b2Vec2(0,0);
    jd.maxLength= (body->GetPosition() - anchorBody->GetPosition()).Length(); //define max length of joint = current distance between bodies
    _world->CreateJoint(&jd); //create joint
    // +++ Create VRope
    


}














- (void) tick: (ccTime) dt {
    _world->Step(dt, 5, 8);
    
    
    for(uint i=0;i<[vRopes count];i++)
        [[vRopes objectAtIndex:i] update:dt];
    
    
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        if (b->GetUserData() != NULL) {
            CCSprite * ballData = (CCSprite *)b -> GetUserData();
            ballData.position = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            ballData.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        
            

        
            if (attachmentSite) {
                
                if (isGoingRight && _body->GetWorldCenter().x > attachmentSite->GetWorldCenter().x) {
                    rope_joint->SetMaxLength(rope_joint->GetMaxLength() - 0.03f);
                    
                    // idea - get number to recoil with as part of angular momentum> Or something like that..
                    NSLog(@"Angular Velocity: %f, %f",  _body->GetLinearVelocity().x, _body->GetLinearVelocity().y);
                    
                    
                    isBeingLifted = YES;
                }
                
                
                if (!isGoingRight && _body->GetWorldCenter().x < attachmentSite->GetWorldCenter().x ) {
                    rope_joint->SetMaxLength(rope_joint->GetMaxLength() - 0.03f);
                    isBeingLifted = YES;
                }
                
            }
        
        }
    }
}


- (void) draw {
    
        for(uint i=0;i<[vRopes count];i++)
            [[vRopes objectAtIndex:i] updateSprites];
    if (isDetached && [vRopes count]) {
//        NSLog(@"                 OMG           %i", [vRopes count]);
        for(uint i=0;i<[vRopes count];i++)
            [[vRopes objectAtIndex:i] removeSprites];
    }
//
    
//        if (attachmentSiteSprite) {
//      
//        [super draw];
//        
//        ccDrawColor4B(255, 255, 255, 255); //Color of the line RGBA
//        glLineWidth(5.0f); //Stroke width of the line
//        ccDrawLine(attachmentSiteSprite.position, _ball.position);
//    }
    
}


//    if (attachmentSite) {
//   
//        if (isGoingRight && _body->GetWorldCenter().x > attachmentSite->GetWorldCenter().x) {
//                rope_joint->SetMaxLength(rope_joint->GetMaxLength() - 0.1f);
//                isBeingLifted = YES;
//            }
//
//    
//        if (!isGoingRight && _body->GetWorldCenter().x < attachmentSite->GetWorldCenter().x ) {
//                rope_joint->SetMaxLength(rope_joint->GetMaxLength() - 0.1f);
//                isBeingLifted = YES;
//        }
//
//    }

//    [self jumpOrSwing];
    
- (void) reset {
//    [[CCDirector sharedDirector]replaceScene:[CCTransitionFade transitionWithDuration:1.0 scene:[HelloWorldLayer scene]]];
    [vRopes dealloc];
}

- (void) jumpOrSwing:(CGPoint) location {
    
    if (_body->GetWorldCenter().y < ( _ball.contentSize.height / PTM_RATIO)){
        isJumping = NO; //YES
    
     if (!isJumping) {
        b2Vec2 force = b2Vec2(0,30);
        _body -> ApplyLinearImpulse( force, _body->GetWorldCenter());
        isJumping = YES;
         return;
    }
}

    if (isJumping){
        [self detach];
        [self attach: location];
    }
    
       //    isBeingLifted = YES;
    
    if (attachmentSite) {
        
        
        
        if (_body->GetWorldCenter().x <attachmentSite->GetWorldCenter().x)
            isGoingRight = YES;
        
        else if (_body->GetWorldCenter().x  > attachmentSite->GetWorldCenter().x)
            isGoingRight = NO;
    
    }

}

- (void) dealloc {
    delete _world;
    _body = NULL;
    _world = NULL;
    
    [super dealloc];
}
- (void) attach: (CGPoint) location {
    CGSize winSize = [CCDirector sharedDirector].winSize;

    b2Vec2 aboveTouch_b2 = b2Vec2(location.x / PTM_RATIO, winSize.height /PTM_RATIO);
    CGPoint aboveTouch = ccp(location.x, winSize.height);
    b2Vec2 bodyPosition = _body->GetWorldCenter() ;

    
    b2Vec2 difference_vector = aboveTouch_b2 - bodyPosition;
    
    float difference_length = sqrtf((difference_vector.x*difference_vector.x)+(difference_vector.y*difference_vector.y));
    ropeLength = difference_length;
    
    // Create Sprite
    attachmentSiteSprite = [CCSprite spriteWithFile:@"attachmentSite.png"];
    attachmentSiteSprite.position = aboveTouch;
    [self addChild:attachmentSiteSprite];
    
    // create small static body
    b2BodyDef attachmentSiteDef;
    attachmentSiteDef.type = b2_staticBody;
    attachmentSiteDef.position = aboveTouch_b2;
    attachmentSiteDef.userData = attachmentSiteSprite;
    attachmentSite = _world->CreateBody(&attachmentSiteDef);
    
    b2PolygonShape attachmentSiteShape;
    attachmentSiteShape.SetAsBox(5, 5);
    
    b2FixtureDef attachmentSiteFixture;
    attachmentSiteFixture.shape = &attachmentSiteShape;
    
    attachmentSite->CreateFixture(&attachmentSiteFixture);
    
    
    
    
    
    
    
//    rope_joint_def.maxLength = difference_length;
    rope_joint_def.maxLength= (_body->GetPosition() - attachmentSite->GetPosition()).Length();
    
    rope_joint_def.bodyB = attachmentSite;
    
    rope_joint_def.localAnchorB = b2Vec2_zero;
    rope_joint_def.localAnchorA = b2Vec2_zero;
    
    rope_joint_def.bodyA = _body;
    rope_joint =(b2RopeJoint* ) _world->CreateJoint(&rope_joint_def);
    
    VRope *newRope = [[VRope alloc] init:_body body2:attachmentSite spriteSheet:ropeSpriteSheet];
    [vRopes addObject:newRope];
    
    isDetached = NO;

}
-(void) detach {
    if (rope_joint) {
        _world->DestroyJoint(rope_joint);
        if ([vRopes count])
        [vRopes removeLastObject];
        rope_joint = NULL;
    }
    
    if (attachmentSite) {
        CCSprite * tempSprite = (CCSprite *)attachmentSite -> GetUserData();
        [self removeChild:tempSprite cleanup:YES];

        
        _world->DestroyBody(attachmentSite);
        attachmentSite = NULL;
    }
    isDetached = YES;
    
//    [self dealloc];
    
}




- (void) ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

    UITouch *touch = [ touches anyObject];
    
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL:location];
    
    [self jumpOrSwing:location];
    

    }


- (void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    isBeingLifted = NO;
    attachmentSiteSprite = NULL;
    [self detach];
    swings = 0;
    
}


@end