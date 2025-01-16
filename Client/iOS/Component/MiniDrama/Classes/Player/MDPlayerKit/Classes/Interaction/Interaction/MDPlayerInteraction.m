//
//  MDPlayerInteraction.m
//  MDPlayerKit
//

#import "MDPlayerInteraction.h"
#import "MDPlayerContext.h"
#import "MDPlayerModuleManager.h"
#import "MDPlayerGestureService.h"
#import "MDPlayerViewService.h"

@interface MDPlayerInteraction ()

@property (nonatomic, weak) MDPlayerContext *context;

@property (nonatomic, strong) MDPlayerModuleManager *playerModuleManager;

@property (nonatomic, strong) MDPlayerViewService *playerViewService;

@property (nonatomic, strong) MDPlayerGestureService *gestureService;

@end

@implementation MDPlayerInteraction

#pragma mark - Class Method
#pragma mark - Life cycle

- (instancetype)initWithContext:(MDPlayerContext *)context {
    self = [super init];
    if (self) {
        _context = context;
        _playerModuleManager = [[MDPlayerModuleManager alloc] initWithPlayerContext:context];
        MDPlayerContextDIBind(_playerModuleManager, MDPlayerModuleManagerInterface, self.context);
        
        _gestureService = [[MDPlayerGestureService alloc] init];
        MDPlayerContextDIBind(_gestureService, MDPlayerGestureServiceInterface, self.context);
        
        _playerViewService = [[MDPlayerViewService alloc] init];
        _playerViewService.moduleManager = _playerModuleManager;
        MDPlayerContextDIBind(_playerViewService, MDPlayerActionViewInterface, self.context);
    }
    return self;
}

#pragma mark - Public Mehtod

#pragma mark - MDPlayerInteractionPlayerProtocol Mehtod
#pragma mark --MDPlayerViewLifeCycleProtocol Mehtod

- (void)viewDidLoad {
    NSAssert(self.playerVCView != nil, @"playerVCView is nil.");
    self.playerViewService.actionView.frame = self.playerVCView.bounds;
    self.playerViewService.actionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.playerVCView addSubview:self.playerViewService.actionView];
    self.gestureService.gestureView = self.playerViewService.actionView;
    self.playerViewService.playerContainerView = self.playerContainerView;
    
    [self.playerModuleManager viewDidLoad];
}

- (void)controlViewTemplateDidUpdate {
    [self.playerModuleManager controlViewTemplateDidUpdate];
}

#pragma mark --MDPlayerModuleManagerInterface Mehtod
- (void)addModule:(id<MDPlayerBaseModuleProtocol>)module {
    [self.playerModuleManager addModule:module];
}

- (void)addModuleByClzz:(nonnull Class)clzz {
    [self.playerModuleManager addModuleByClzz:clzz];
}

- (void)addModules:(NSArray<id<MDPlayerBaseModuleProtocol>> *)modules {
    [self.playerModuleManager addModules:modules];
}

- (void)removeModules:(NSArray<id<MDPlayerBaseModuleProtocol>> *)modules {
    [self.playerModuleManager removeModules:modules];
}

- (void)addModulesByClzzArray:(nonnull NSArray<Class> *)clzzArray {
    [self.playerModuleManager addModulesByClzzArray:clzzArray];
}

- (void)removeAllModules {
    [self.playerModuleManager removeAllModules];
}

- (void)removeModule:(id<MDPlayerBaseModuleProtocol>)module {
    [self.playerModuleManager removeModule:module];
}

- (void)removeModuleByClzz:(nonnull Class)clzz {
    [self.playerModuleManager removeModuleByClzz:clzz];
}

- (void)setupData:(nonnull id)data {
    [self.playerModuleManager setupData:data];
}

@end
