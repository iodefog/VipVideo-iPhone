//
//  MMovieModel.m
//  MVideo
//
//  Created by LHL on 17/2/27.
//  Copyright © 2017年 LHL. All rights reserved.
//

#import "MMovieModel.h"

@implementation MMovieModel

+ (id)getMovieModelWithTitle:(NSString *)title
                         url:(NSString *)url {
    MMovieModel *model = [[MMovieModel alloc] init];
    model.title = title;
    model.url = url;
    return model;
}


@end
