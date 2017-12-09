//
//  PostJobCell_title.m
//  jianke
//
//  Created by xiaomk on 16/4/18.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "PostJobCell_title.h"
#import "JobModel.h"

@interface PostJobCell_title(){
    JobModel *_jobModel;
    NSUInteger _maxLength;
}

@property (weak, nonatomic) IBOutlet UITextField *tfTitle;
@property (weak, nonatomic) IBOutlet UILabel *labTitleWordNum;
@end

@implementation PostJobCell_title


+ (instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString *identifier = @"PostJobCell_title";
    PostJobCell_title *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (!cell) {
        static UINib* _nib;
        if (!_nib) {
            _nib = [UINib nibWithNibName:@"PostJobCell_title" bundle:nil];
        }
        
        if (_nib) {
            cell = [[_nib instantiateWithOwner:nil options:nil] objectAtIndex:0];
        }
        cell.backgroundColor = [UIColor whiteColor];
    }
    return cell;
}

- (void)refreshWithData:(JobModel*)model andIndexPath:(NSIndexPath *)indexPath{
    if (model) {
        _maxLength = 20;
        _jobModel = model;
        if (model.job_title && model.job_title.length > 0) {
            self.tfTitle.text = model.job_title;
        }
        [self.tfTitle addTarget:self action:@selector(textFielEditChange:) forControlEvents:UIControlEventEditingChanged];
    }
}

- (void)textFielEditChange:(UITextField*)textField{

    UITextRange* selectedRange = [textField markedTextRange];
    NSString* newText = [textField textInRange:selectedRange];
    if (newText.length > 0) return;
    
    if (textField.text.length > _maxLength) {
        textField.text = [textField.text substringToIndex:_maxLength];
    }
    
    self.labTitleWordNum.text = [NSString stringWithFormat:@"%lu/%lu", (unsigned long)textField.text.length, (unsigned long)_maxLength];
    if (_jobModel) {
        _jobModel.job_title = textField.text;
    }
//    ELog(@"===job_title:%@",_postJobCellModel.jobModel.job_title);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
