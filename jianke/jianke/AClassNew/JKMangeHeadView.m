//
//  JKMangeHeadView.m
//  jianke
//
//  Created by fire on 16/9/6.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "JKMangeHeadView.h"
#import "JobDetailModel.h"

@interface JKMangeHeadView ()


@property (weak, nonatomic) IBOutlet UILabel *viewNumLab;
@property (weak, nonatomic) IBOutlet UILabel *accNumLab;
@property (weak, nonatomic) IBOutlet UILabel *hireNumLab;
- (IBAction)btnOnclick:(id)sender;

@end

@implementation JKMangeHeadView

- (void)setData:(JobDetailModel *)model{
    if (model) {
        [self.titleBtn setTitle:model.parttime_job.job_title forState:UIControlStateNormal];
        self.viewNumLab.text = model.parttime_job.view_count ? model.parttime_job.view_count.stringValue : @"0" ;
        if (model.parttime_job.source.integerValue == 1) {
            self.accNumLab.text = @"0";
            self.hireNumLab.text = @"0";
        }else{
            self.accNumLab.text = model.apply_job_resumes_count ? model.apply_job_resumes_count.stringValue : @"0" ;
            self.hireNumLab.text = model.parttime_job.all_hired_resume_count ? model.parttime_job.all_hired_resume_count.stringValue : @"0" ;
        }
    }
}

- (IBAction)btnOnclick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(jkHeadView:btnOnClick:)]) {
        [self.delegate jkHeadView:self btnOnClick:sender];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
