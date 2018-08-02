//
//  MMovieModel.h
//  MVideo
//
//  Created by LHL on 17/2/27.
//  Copyright © 2017年 LHL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMovieModel : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) BOOL     canPlay;


+ (id)getMovieModelWithTitle:(NSString *)title
                         url:(NSString *)url;

@end
