//
//  ResourceModel.h
//  Caravan
//
//  Created by Ravi Chaudhary on 22/02/15.
//  Copyright (c) 2015 Ravi Chaudhary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResourceModel : NSObject

@property (nonatomic, strong) NSString * resourceId;
@property (nonatomic, strong) NSString * imageUrl;
@property (nonatomic, strong) UIImage * resourceImage;
@property (nonatomic, strong) NSString * link;
@property (nonatomic, strong) NSString * content;

@end
