//
//  GDataXMLElement+PornExtension.h
//  91porn
//
//  Created by Hahn on 2018/3/24.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "GDataXMLNode.h"

@interface GDataXMLElement (PornExtension)

- (NSArray<GDataXMLElement *> *(^)(NSString *tagName))select;
- (GDataXMLElement *(^)(NSString *tagName))selectFirst;

- (GDataXMLElement *(^)(NSString *Id))getElementById;

- (NSArray<GDataXMLElement *> *(^)(NSString *className))getElementByClass;
- (GDataXMLElement *(^)(NSString *className))getElementByClassFirst;

- (NSString *(^)(NSString *name))attribute;
- (GDataXMLElement *(^)(NSString *name, NSString *value))attributeMake;

@end
