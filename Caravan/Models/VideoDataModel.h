//
//  VideoDataModel.h
//  Caravan
//
//  Created by Ravi Chaudhary on 25/02/15.
//  Copyright (c) 2015 Ravi Chaudhary. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoDataModel : NSObject

@property (nonatomic, strong) NSString * videoId;
@property (nonatomic, strong) NSString * frameElement;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) NSString * content;

@end
