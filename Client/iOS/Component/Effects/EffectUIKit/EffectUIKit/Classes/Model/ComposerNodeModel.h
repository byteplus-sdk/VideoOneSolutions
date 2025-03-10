// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

static const NSInteger OFFSET = 24;
static const NSInteger MASK = 0xFFFFFF;
static const NSInteger SUB_OFFSET = 16;
static const NSInteger SUB_MASK = 0xFFFF;

typedef NS_ENUM(NSInteger, EffectUIKitTpye) {
    EffectUIKitTpyeNormal = 0,
    EffectUIKitNodeTypeHairColor =  1,
};

typedef NS_ENUM(NSInteger, EffectUIKitNode) {
    
    EffectUIKitNodeTypeClose                    = -1,
    EffectUIKitNodeTypeBeautyFace               = 1 << OFFSET,
    EffectUIKitNodeTypeBeautyReshape            = 2 << OFFSET,
    EffectUIKitNodeTypeBeautyBody               = 3 << OFFSET,
    EffectUIKitNodeTypeMakeup                   = 4 << OFFSET,
    EffectUIKitNodeTypeStyleMakeup              = 5 << OFFSET,
    EffectUIKitNodeTypeFilter                   = 6 << OFFSET,
    EffectUIKitNodeTypeSticker                  = 7 << OFFSET,
    EffectUIKitNodeTypeAmazingSticker           = 8 << OFFSET,
    EffectUIKitNodeTypeAnimoji                  = 9 << OFFSET,
    EffectUIKitNodeTypeArscan                   = 10 << OFFSET,
    EffectUIKitNodeTypeArTryShoe                = 11 << OFFSET,
    EffectUIKitNodeTypeArTryHat                 = 12 << OFFSET,
    EffectUIKitNodeTypeArTryWatch               = 13 << OFFSET,
    EffectUIKitNodeTypeArTryBracelet            = 14 << OFFSET,
    EffectUIKitNodeTypeAvatarBoy                = 15 << OFFSET,
    EffectUIKitNodeTypeAvatarGirl               = 16 << OFFSET,
    EffectUIKitNodeTypeArSLAM                   = 17 << OFFSET,
    EffectUIKitNodeTypeArObject                 = 18 << OFFSET,
    EffectUIKitNodeTypeArLandmark               = 19 << OFFSET,
    EffectUIKitNodeTypeArSkyLand                = 20 << OFFSET,
    EffectUIKitNodeTypeArTryRing                = 21 << OFFSET,
    EffectUIKitNodeTypeArTryGlasses             = 22 << OFFSET,
    EffectUIKitNodeTypeArNail                   = 23 << OFFSET,
    EffectUIKitNodeTypeMakeupLipstickShine      = 24 << OFFSET,
    EffectUIKitNodeTypeMakeupLipstickMatte      = 25 << OFFSET,
    EffectUIKitNodeTypeStyleHighlights           = 26 << OFFSET,
    EffectUIKitNodeTypeStyleHairColor            = 27 << OFFSET,
    EffectUIKitNodeTypeStyleHairColorClose       = 28 << OFFSET,
    EffectUIKitNodeTypeStyleHairColorA           = 29 << OFFSET,
    EffectUIKitNodeTypeStyleHairColorB           = 30 << OFFSET,
    EffectUIKitNodeTypeStyleHairColorC           = 31 << OFFSET,
    EffectUIKitNodeTypeStyleHairColorD           = 32 << OFFSET,
    EffectUIKitNodeTypeStyleHairDyeFull           = 33 << OFFSET,
    EffectUIKitNodeTypeQuality                    = 34 << OFFSET,
    EffectUIKitNodeTypeWatermark                  = 35 << OFFSET,
    EffectUIKitNodeTypeStyleMakeup3D              = 36 << OFFSET,
    EffectUIKitNodeTypeBlackTechnology            = 37 << OFFSET,

       EffectUIKitNodeTypeBeautyFaceSmooth         = EffectUIKitNodeTypeBeautyFace      + (1 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyFaceWhiten         = EffectUIKitNodeTypeBeautyFace      + (2 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyFaceSharp          = EffectUIKitNodeTypeBeautyFace      + (3 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyFaceClarity        = EffectUIKitNodeTypeBeautyFace      + (4 << SUB_OFFSET),
       
       EffectUIKitNodeTypeBeautyReshapeFace             = EffectUIKitNodeTypeBeautyReshape    + (1 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeFaceOverall      = EffectUIKitNodeTypeBeautyReshape    + (2 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeFaceSmall        = EffectUIKitNodeTypeBeautyReshape    + (3 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeFaceCut          = EffectUIKitNodeTypeBeautyReshape    + (4 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeFaceV            = EffectUIKitNodeTypeBeautyReshape    + (5 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeForehead         = EffectUIKitNodeTypeBeautyReshape    + (6 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeCheek            = EffectUIKitNodeTypeBeautyReshape    + (7 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeJaw              = EffectUIKitNodeTypeBeautyReshape    + (8 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeChin             = EffectUIKitNodeTypeBeautyReshape    + (9 << SUB_OFFSET),
       
       EffectUIKitNodeTypeBeautyReshapeEye              = EffectUIKitNodeTypeBeautyReshape    + (20 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeEyeSize          = EffectUIKitNodeTypeBeautyReshape    + (21 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeEyeHeight        = EffectUIKitNodeTypeBeautyReshape    + (22 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeEyeWidth         = EffectUIKitNodeTypeBeautyReshape    + (23 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeEyeMove          = EffectUIKitNodeTypeBeautyReshape    + (24 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeEyeSpacing       = EffectUIKitNodeTypeBeautyReshape    + (25 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeEyeLowerEyelid   = EffectUIKitNodeTypeBeautyReshape    + (26 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeEyePupil         = EffectUIKitNodeTypeBeautyReshape    + (27 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeEyeInnerCorner   = EffectUIKitNodeTypeBeautyReshape    + (16 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeEyeOuterCorner   = EffectUIKitNodeTypeBeautyReshape    + (28 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeEyeRotate        = EffectUIKitNodeTypeBeautyReshape    + (29 << SUB_OFFSET),
       
       EffectUIKitNodeTypeBeautyReshapeNose             = EffectUIKitNodeTypeBeautyReshape    + (40 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeNoseSize         = EffectUIKitNodeTypeBeautyReshape    + (41 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeNoseWing         = EffectUIKitNodeTypeBeautyReshape    + (42 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeNoseBridge       = EffectUIKitNodeTypeBeautyReshape    + (43 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeMovNose          = EffectUIKitNodeTypeBeautyReshape    + (44 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeNoseTip          = EffectUIKitNodeTypeBeautyReshape    + (45 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeNoseRoot         = EffectUIKitNodeTypeBeautyReshape    + (46 << SUB_OFFSET),
       
       EffectUIKitNodeTypeBeautyReshapeBrow             = EffectUIKitNodeTypeBeautyReshape    + (60 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeBrowSize         = EffectUIKitNodeTypeBeautyReshape    + (61 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeBrowPosition     = EffectUIKitNodeTypeBeautyReshape    + (62 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeBrowTilt         = EffectUIKitNodeTypeBeautyReshape    + (63 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeBrowRidge        = EffectUIKitNodeTypeBeautyReshape    + (64 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeBrowDistance     = EffectUIKitNodeTypeBeautyReshape    + (65 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeBrowWidth        = EffectUIKitNodeTypeBeautyReshape    + (66 << SUB_OFFSET),
       
       EffectUIKitNodeTypeBeautyReshapeMouth            = EffectUIKitNodeTypeBeautyReshape    + (80 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeMouthZoom        = EffectUIKitNodeTypeBeautyReshape    + (81 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeMouthWidth       = EffectUIKitNodeTypeBeautyReshape    + (82 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeMouthMove        = EffectUIKitNodeTypeBeautyReshape    + (83 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeMouthSmile       = EffectUIKitNodeTypeBeautyReshape    + (84 << SUB_OFFSET),
       
       EffectUIKitNodeTypeBeautyReshapeBrightenEye      = EffectUIKitNodeTypeBeautyReshape    + (35 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeRemovePouch      = EffectUIKitNodeTypeBeautyReshape    + (36 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeRemoveSmileFolds = EffectUIKitNodeTypeBeautyReshape    + (37 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeWhitenTeeth      = EffectUIKitNodeTypeBeautyReshape    + (38 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeSingleToDoubleEyelid = EffectUIKitNodeTypeBeautyReshape+ (39 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyReshapeEyePlump         = EffectUIKitNodeTypeBeautyReshape    + (40 << SUB_OFFSET),
       
       
       EffectUIKitNodeTypeBeautyBodyThin           = EffectUIKitNodeTypeBeautyBody      + (1 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyBodyLegLong        = EffectUIKitNodeTypeBeautyBody      + (2 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyBodySlimLeg        = EffectUIKitNodeTypeBeautyBody      + (3 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyBodySlimWaist      = EffectUIKitNodeTypeBeautyBody      + (4 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyBodyEnlargeBreast  = EffectUIKitNodeTypeBeautyBody      + (5 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyBodyEnhanceHip     = EffectUIKitNodeTypeBeautyBody      + (6 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyBodyEnhanceNeck    = EffectUIKitNodeTypeBeautyBody      + (7 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyBodySlimArm        = EffectUIKitNodeTypeBeautyBody      + (8 << SUB_OFFSET),
       EffectUIKitNodeTypeBeautyBodyShrinkHead     = EffectUIKitNodeTypeBeautyBody      + (9 << SUB_OFFSET),
       
       
       EffectUIKitNodeTypeMakeupLip                = EffectUIKitNodeTypeMakeup          + (1 << SUB_OFFSET),
       EffectUIKitNodeTypeMakeupBlusher            = EffectUIKitNodeTypeMakeup          + (2 << SUB_OFFSET),
       EffectUIKitNodeTypeMakeupEyelash            = EffectUIKitNodeTypeMakeup          + (3 << SUB_OFFSET),
       EffectUIKitNodeTypeMakeupPupil              = EffectUIKitNodeTypeMakeup          + (4 << SUB_OFFSET),
       EffectUIKitNodeTypeMakeupHair               = EffectUIKitNodeTypeMakeup          + (5 << SUB_OFFSET),
       EffectUIKitNodeTypeMakeupEyeshadow          = EffectUIKitNodeTypeMakeup          + (6 << SUB_OFFSET),
       EffectUIKitNodeTypeMakeupEyebrow            = EffectUIKitNodeTypeMakeup          + (7 << SUB_OFFSET),
       EffectUIKitNodeTypeMakeupFacial             = EffectUIKitNodeTypeMakeup          + (8 << SUB_OFFSET),
       EffectUIKitNodeTypeMakeupEyeLight           = EffectUIKitNodeTypeMakeup          + (9 << SUB_OFFSET),
       EffectUIKitNodeTypeMakeupEyePlump           = EffectUIKitNodeTypeMakeup          + (10 << SUB_OFFSET),
    
    EffectUIKitNodeTypeQualityTemperature          = EffectUIKitNodeTypeQuality          + (1 << SUB_OFFSET),
    EffectUIKitNodeTypeQualityTone                 = EffectUIKitNodeTypeQuality          + (2 << SUB_OFFSET),
    EffectUIKitNodeTypeQualityTone_v1              = EffectUIKitNodeTypeQuality          + (3 << SUB_OFFSET),
    EffectUIKitNodeTypeQualitySaturation           = EffectUIKitNodeTypeQuality          + (4 << SUB_OFFSET),
    EffectUIKitNodeTypeQualityBrightness           = EffectUIKitNodeTypeQuality          + (5 << SUB_OFFSET),
    EffectUIKitNodeTypeQualityBrightness_v1        = EffectUIKitNodeTypeQuality          + (6 << SUB_OFFSET),
    EffectUIKitNodeTypeQualityContrast             = EffectUIKitNodeTypeQuality          + (7 << SUB_OFFSET),
    EffectUIKitNodeTypeQualityHighlight_v1         = EffectUIKitNodeTypeQuality          + (8 << SUB_OFFSET),
    EffectUIKitNodeTypeQualityShadow               = EffectUIKitNodeTypeQuality          + (9 << SUB_OFFSET),
    EffectUIKitNodeTypeQualityLight_sensation      = EffectUIKitNodeTypeQuality          + (10 << SUB_OFFSET),
    EffectUIKitNodeTypeQualityParticle             = EffectUIKitNodeTypeQuality          + (11 << SUB_OFFSET),
    EffectUIKitNodeTypeQualityFade                 = EffectUIKitNodeTypeQuality          + (12 << SUB_OFFSET),
    EffectUIKitNodeTypeQualityVignetting           = EffectUIKitNodeTypeQuality          + (13 << SUB_OFFSET),

};


@interface ComposerNodeModel : NSObject
+ (instancetype)initWithPath:(NSString *)path keyArray:(NSArray<NSString *> *)keyArray tag:(NSString *)tag;

+ (instancetype)initWithPath:(NSString *)path keyArray:(NSArray<NSString *> *)keyArray;

+ (instancetype)initWithPath:(NSString *)path key:(NSString *)key;

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSArray<NSString *> *keyArray;
@property (nonatomic, strong) NSString *tag;
@property (nonatomic, strong) NSArray<NSNumber *> *valueArray;

@end
