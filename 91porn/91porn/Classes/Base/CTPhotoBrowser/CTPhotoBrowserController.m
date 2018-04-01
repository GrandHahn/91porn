//
//  CTPhotoBrowserController.m
//  CTPhotoBrowser
//
//  Created by Hahn on 2017/2/22.
//  Copyright © 2017年 Hahn. All rights reserved.
//

#import "CTPhotoBrowserController.h"
#import "CTPhotoBrowserCollectionLayout.h"
#import "CTPhotoBrowserViewCell.h"
#import <Photos/Photos.h>

// new modified for MeiZiTu
#import "SVProgressHUD.h"
#define CTScreenH [UIScreen mainScreen].bounds.size.height
#define CTScreenW [UIScreen mainScreen].bounds.size.width

#define CTNavHeight ((UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers.firstObject).navigationBar.frame.size.height
#define CTStatusHeight [UIApplication sharedApplication].statusBarFrame.size.height
#define CTNavAndStatusHeight (CTNavHeight + CTStatusHeight)

#define iPhoneX (812 == CTScreenH)
#define iPhoneXBottomOffset (iPhoneX ? 34.0 : 0)

static NSString * const CTPhotoBrowserViewCellID = @"CTPhotoBrowserViewCell";

@interface CTPhotoBrowserController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) UIButton *closeBtn;
@property (nonatomic, weak) UIButton *saveBtn;
@end

@implementation CTPhotoBrowserController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    UINavigationController *nav = self.navigationController;
    if (nav) {
        NSLog(@"\nCTPhotoBrowserController:\n请使用modal/present的方式弹出控制器，暂时没适配push");
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.imageArray.count == 0) {
        NSLog(@"请初始化图片数组");
        return;
    }
    NSInteger index = 0;
    if (self.indexOfImageWillShow < 0 || self.indexOfImageWillShow >= self.imageArray.count) {
        NSLog(@"indexOfImageWillShow不应超出图片数量范围");
        index = 0;
    } else {
        index = self.indexOfImageWillShow;
    }
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI
- (void)setupUI {
    // 1.初始化
    CTPhotoBrowserCollectionLayout *layout = [[CTPhotoBrowserCollectionLayout alloc] init];
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setTitle:@"关 闭" forState:UIControlStateNormal];
    closeBtn.backgroundColor = [UIColor darkGrayColor];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    closeBtn.alpha = 0.6;
    
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [saveBtn setTitle:@"保 存" forState:UIControlStateNormal];
    saveBtn.backgroundColor = [UIColor darkGrayColor];
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    saveBtn.alpha = 0.6;
    
    // 2.添加子控件
    [self.view addSubview:collectionView];
    [self.view addSubview:closeBtn];
    [self.view addSubview:saveBtn];
    
    self.collectionView = collectionView;
    self.closeBtn = closeBtn;
    self.saveBtn = saveBtn;
    
    // 3.设置控件的frame
    // self.collectionView.frame = self.view.bounds;
    // 给宽度增加20就能使图片有间距，可能会因为cell和子控件布局的不巧当造成bug
    self.collectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width + 20, self.view.bounds.size.height);
    CGFloat btnW = 90;
    CGFloat btnH = 32;
    CGFloat btnY = [UIScreen mainScreen].bounds.size.height - btnH - 20 - iPhoneXBottomOffset;
    self.closeBtn.frame = CGRectMake(20, btnY, btnW, btnH);
    CGFloat saveBtnX = [UIScreen mainScreen].bounds.size.width - btnW - 20;
    self.saveBtn.frame = CGRectMake(saveBtnX, btnY, btnW, btnH);
    
    // 4.设置两个按钮属性
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [saveBtn addTarget:self action:@selector(saveBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    // 5.设置collectionView属性
    [self.collectionView registerClass:[CTPhotoBrowserViewCell class] forCellWithReuseIdentifier:CTPhotoBrowserViewCellID];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
}

#pragma mark - event
- (void)closeBtnClick {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)saveBtnClick {
//    CTPhotoBrowserViewCell *cell = self.collectionView.visibleCells.firstObject;
//    
//    UIImage *image = cell.imageView.image;
//    
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    
    [self saveBtnClickNew];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSLog(@"saveSuccess");
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CTPhotoBrowserViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CTPhotoBrowserViewCellID forIndexPath:indexPath];
    
    id image = self.imageArray[indexPath.item];
    if ([image isKindOfClass:[UIImage class]]) {
        cell.image = image;
    } else if ([image isKindOfClass:[NSString class]]) {
        cell.imageURL = image;
    } else {
        NSLog(@"传入的不是NSString类型的url或UIImage类型");
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
// 注：由于cell内部有scrollview，此代理不会响应
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didSelectItemAtIndexPath:%@", indexPath);
}

#pragma mark - CTDismissDelegate

- (NSInteger)currentIndex {
    CTPhotoBrowserViewCell *cell = self.collectionView.visibleCells.firstObject;
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    return indexPath.item;
}

- (UIImageView *)imageViewForDismiss {
    UIImageView *imageView = [[UIImageView alloc] init];
    CTPhotoBrowserViewCell *cell = self.collectionView.visibleCells.firstObject;
    imageView.image = cell.imageView.image;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    return imageView;
}


#pragma mark - save photo
- (PHFetchResult<PHAsset *> *)createdAssets {
    
    CTPhotoBrowserViewCell *cell = self.collectionView.visibleCells.firstObject;
    UIImage *image = cell.imageView.image;
    
    
    // 1.添加图片到相机胶卷
    __block NSString *createdAssetId = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    // 取得图片
    PHFetchResult<PHAsset *> *createdAssets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
    return createdAssets;
}
- (PHAssetCollection *)createdCollection {
    // 2.创建自定义相册
    // 相册名
    NSString *title = [NSBundle mainBundle].infoDictionary[@"CFBundleDisplayName"];
    // 取所有相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 遍历查找是否已经有创建同名相册
    PHAssetCollection *createdCollection = nil;
    for (PHAssetCollection *collection in collections) {
        if ([collection.localizedTitle isEqualToString:title]) {
            createdCollection = collection;
        }
    }
    
    // 还没有创建过相册
    if (!createdCollection) {
        __block NSString *createdAssetCollectionId = nil;
        [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
            createdAssetCollectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title].placeholderForCreatedAssetCollection.localIdentifier;
        } error:nil];
        // 取得相册
        createdCollection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createdAssetCollectionId] options:nil].firstObject;
    }
    return createdCollection;
}
- (void)saveImageIntoAlbum {
    //    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    /*
     reason: 'This method can only be called from inside of -[PHPhotoLibrary performChanges:completionHandler:] or -[PHPhotoLibrary performChangesAndWait:error:]'
     */
    
    
    
    CTPhotoBrowserViewCell *cell = self.collectionView.visibleCells.firstObject;
    UIImage *image = cell.imageView.image;
    
    
    // 1.添加图片到相机胶卷
    // 取得图片
    PHFetchResult<PHAsset *> *createdAssets = self.createdAssets;
    
    // 2.创建自定义相册
    // 取得相册
    PHAssetCollection *createdCollection = self.createdCollection;
    
    // 无值则返回
    if (createdAssets == nil || createdCollection == nil) {
        NSLog(@"fail");
        return;
    }
    
    // 3.图片添加到自定义相册
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        PHAssetCollectionChangeRequest *request =[PHAssetCollectionChangeRequest changeRequestForAssetCollection:createdCollection];
        [request insertAssets:createdAssets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    // 结果
    if (error) {
        NSLog(@"fail");
        [SVProgressHUD showErrorWithStatus:@"保存失败"];
    } else {
        NSLog(@"success");
        if (image == nil) {
            [SVProgressHUD showErrorWithStatus:@"保存失败"];
        } else {
            [SVProgressHUD showSuccessWithStatus:@"保存成功"];
        }
    }
}
- (void)saveBtnClickNew {
    // 处理授权
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            switch (status) {
                case PHAuthorizationStatusAuthorized:
                    [self saveImageIntoAlbum];
                    break;
                case PHAuthorizationStatusDenied:
                    if (oldStatus == PHAuthorizationStatusNotDetermined) {
                        return;
                    }
                    NSLog(@"请允许访问相册");
                    [SVProgressHUD showErrorWithStatus:@"保存失败"];
                    break;
                case PHAuthorizationStatusRestricted:
                    NSLog(@"系统原因，无法访问");
                    [SVProgressHUD showErrorWithStatus:@"保存失败"];
                    break;
                default:
                    break;
            }
        });
    }];
}
@end
