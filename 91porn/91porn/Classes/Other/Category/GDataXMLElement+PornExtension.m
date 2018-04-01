//
//  GDataXMLElement+PornExtension.m
//  91porn
//
//  Created by Hahn on 2018/3/24.
//  Copyright © 2018年 Hahn. All rights reserved.
//

#import "GDataXMLElement+PornExtension.h"

@implementation GDataXMLElement (PornExtension)

- (NSArray<GDataXMLElement *> *(^)(NSString *))select {
    return ^(NSString *tagName) {
        NSError *error = nil;
        NSString *xpath = [NSString stringWithFormat:@".//%@", tagName];
        NSArray<GDataXMLElement *> *nodes = [self nodesForXPath:xpath error:&error];
        if (error != nil) NSLog(@"%@\nError element:%@", error, self);
        return nodes;
    };
}

- (GDataXMLElement *(^)(NSString *))selectFirst {
    return ^(NSString *tagName) {
        NSError *error = nil;
        NSString *xpath = [NSString stringWithFormat:@".//%@", tagName];
        NSArray *nodes = [self nodesForXPath:xpath error:&error];
        if (error != nil) NSLog(@"%@\nError element:%@", error, self);
        if (nodes.count > 0) {
            return (GDataXMLElement *)nodes.firstObject;
        } else {
//            return [[GDataXMLElement alloc] init];
            return (GDataXMLElement *)nil;
        }
    };
}

- (GDataXMLElement *(^)(NSString *))getElementById {
    return ^(NSString *Id) {
        NSError *error = nil;
        NSString *xpath = [NSString stringWithFormat:@".//*[@id='%@']", Id];
        NSArray *nodes = [self nodesForXPath:xpath error:&error];
        if (error != nil) NSLog(@"%@\nError element:%@", error, self);
        if (nodes.count > 0) {
            return (GDataXMLElement *)nodes.firstObject;
        } else {
//            return [[GDataXMLElement alloc] init];
            return (GDataXMLElement *)nil;
        }
    };
}

- (NSArray<GDataXMLElement *> *(^)(NSString *))getElementByClass {
    return ^(NSString *className) {
        NSError *error = nil;
        NSString *xpath = [NSString stringWithFormat:@".//*[@class='%@']", className];
        NSArray<GDataXMLElement *> *nodes = [self nodesForXPath:xpath error:&error];
        if (error != nil) NSLog(@"%@\nError element:%@", error, self);
        return nodes;
    };
}

- (GDataXMLElement *(^)(NSString *))getElementByClassFirst {
    return ^(NSString *className) {
        NSError *error = nil;
        NSString *xpath = [NSString stringWithFormat:@".//*[@class='%@']", className];
        NSArray *nodes = [self nodesForXPath:xpath error:&error];
        if (error != nil) NSLog(@"%@\nError element:%@", error, self);
        if (nodes.count > 0) {
            return (GDataXMLElement *)nodes.firstObject;
        } else {
//            return [[GDataXMLElement alloc] init];
            return (GDataXMLElement *)nil;
        }
    };
}

- (NSString *(^)(NSString *))attribute {
    return ^(NSString *name) {
        return [self attributeForName:name].stringValue;
    };
}

- (GDataXMLElement *(^)(NSString *, NSString *))attributeMake {
    return ^(NSString *name, NSString *value) {
        GDataXMLNode *node = [self attributeForName:name];
        if (node != nil) {
            node.stringValue = value;
        } else {
            GDataXMLNode *newAtt = [GDataXMLNode attributeWithName:name stringValue:value];
            [self addAttribute:newAtt];
        }
        return self;
    };
}

@end
