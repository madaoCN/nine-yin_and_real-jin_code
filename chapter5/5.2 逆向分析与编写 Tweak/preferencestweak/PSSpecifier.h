@interface PSSpecifier : NSObject {
@public
	SEL action;
}

@property (nonatomic, retain) id target;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *identifier;

@property (nonatomic) SEL buttonAction;
@property (nonatomic) SEL confirmationAction;
@property (nonatomic) SEL confirmationCancelAction;
@property (nonatomic) SEL controllerLoadAction;

@property (nonatomic, retain) NSMutableDictionary *properties;

@property (nonatomic, retain) NSDictionary *shortTitleDictionary;
@property (nonatomic, retain) NSDictionary *titleDictionary;

@end

@implementation PSSpecifier


@end
