// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELSettingConfigDefine_h
#define VELSettingConfigDefine_h

#define VEL_ENCODE_OBJ_PROPERTY(p) [coder encodeObject:_##p forKey:@#p]
#define VEL_ENCODE_INTEGER_PROPERTY(p) [coder encodeObject:@(_##p) forKey:@#p]

#define VEL_DECODE_OBJ_PROPERTY(p) _##p = [coder decodeObjectForKey:@#p]
#define VEL_DECODE_INTEGER_PROPERTY(p) _##p = [[coder decodeObjectForKey:@#p] integerValue]
#define VEL_DECODE_INTEGER_PROPERTY_DEFAULT(p, default) _##p = [([coder decodeObjectForKey:@#p] ?: @(default)) integerValue]
#define VEL_DECODE_INTEGER_PROPERTY_DEFAULT_MIN(p, default, min) _##p = MAX(min, [([coder decodeObjectForKey:@#p]?:@(default)) integerValue])
#define VEL_ENCODE_BOOL_PROPERTY(p) [coder encodeObject:@(_##p) forKey:@#p]
#define VEL_DECODE_BOOL_PROPERTY(p) _##p = [[coder decodeObjectForKey:@#p] boolValue]
#define VEL_DECODE_BOOL_PROPERTY_DEFAULT(p, default) _##p = [([coder decodeObjectForKey:@#p] ?: @(default)) boolValue]


#endif /* VELSettingConfigDefine_h */
