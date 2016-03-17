//
//  ViewController.m
//  MaPay
//
//  Created by biao on 16/3/16.
//  Copyright © 2016年 biao. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<PKPaymentAuthorizationViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *payView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    if (![PKPaymentAuthorizationViewController canMakePayments]) {
        NSLog(@"当前设备不支持Apple Pay");
        self.payView.hidden = YES;
    }else if (![PKPaymentAuthorizationViewController canMakePaymentsUsingNetworks:@[PKPaymentNetworkChinaUnionPay,PKPaymentNetworkVisa]]){
       
        PKPaymentButton *button = [PKPaymentButton buttonWithType:PKPaymentButtonTypeSetUp style:PKPaymentButtonStyleWhiteOutline];
        [button addTarget:self action:@selector(jump) forControlEvents:UIControlEventTouchUpInside];
        [self.payView addSubview:button];
        
    }else{
        PKPaymentButton *button  = [PKPaymentButton buttonWithType:PKPaymentButtonTypeBuy style:PKPaymentButtonStyleBlack];
        [button addTarget:self action:@selector(buy) forControlEvents:UIControlEventTouchUpInside];
        [self.payView addSubview:button];
    }
}
/**
 * 跳转到添加银行卡界面
 */
- (void)jump{
    PKPassLibrary *pl = [[PKPassLibrary alloc]init];
    [pl openPaymentSetup];
}
/**
 *  购买
 */
- (void)buy{
    NSLog(@"购买商品, 开始支付");
    
    //创建一个支付请求
    PKPaymentRequest *request = [[PKPaymentRequest alloc]init];
    
    //配置支付请求
    
    //配置商家ID
    request.merchantIdentifier = @"merchant.mabiao.com";
    //配置货币代码以及国家码
    request.countryCode = @"CN";
    request.currencyCode = @"CNY";
    //配置请求支持的支付网络
    request.supportedNetworks = @[PKPaymentNetworkChinaUnionPay,PKPaymentNetworkVisa];
    //配置商户的处理方式
    request.merchantCapabilities = PKMerchantCapability3DS;
    //配置购买的商品列表
    NSDecimalNumber *price1 = [NSDecimalNumber decimalNumberWithString:@"4000"];
    PKPaymentSummaryItem *item1 = [PKPaymentSummaryItem summaryItemWithLabel:@"iPhone6" amount:price1];
    
    NSDecimalNumber *price2 = [NSDecimalNumber decimalNumberWithString:@"5000"];
    PKPaymentSummaryItem *item2 = [PKPaymentSummaryItem summaryItemWithLabel:@"iPhone6s" amount:price2];
    
    NSDecimalNumber *price = [NSDecimalNumber decimalNumberWithString:@"9000"];
    PKPaymentSummaryItem *item = [PKPaymentSummaryItem summaryItemWithLabel:@"iPhone" amount:price];
    
    // 注意: 支付列表最后一个, 代表汇总
    request.paymentSummaryItems = @[item1,item2,item];
    
    
    
    //配置请求附加项
    //是否显示发票收货地址, 显示哪些选项
    request.requiredBillingAddressFields = PKAddressFieldAll;
    //是否显示快递地址, 显示哪些选项
    request.requiredShippingAddressFields = PKAddressFieldAll ;
    //配置快递方式NSArray<PKShippingMethod *>
    NSDecimalNumber *shipPrice1 = [NSDecimalNumber decimalNumberWithString:@"18.0"];
    PKShippingMethod *method = [PKShippingMethod summaryItemWithLabel:@"顺丰快递" amount:shipPrice1];
    method.detail = @"24小时内送到";
    method.identifier = @"shunfeng";
    
    NSDecimalNumber *shipPrice2 = [NSDecimalNumber decimalNumberWithString:@"10.0"];
    PKShippingMethod *method2 = [PKShippingMethod summaryItemWithLabel:@"韵达快递" amount:shipPrice2];
    method2.detail = @"送货上门";
    method2.identifier = @"yunda";
    //配置快递的类型
    request.shippingType = PKShippingTypeStorePickup;
    
    //添加一些附加数据
    request.applicationData = [@"buyID=12345" dataUsingEncoding:NSUTF8StringEncoding];

    //验证用户的支付授权
    PKPaymentAuthorizationViewController *vc= [[PKPaymentAuthorizationViewController alloc]initWithPaymentRequest:request];
    vc.delegate =  self;
    [self presentViewController:vc animated:YES completion:nil];
    
}
/**
 *  如果当用户授权成功, 就会调用这个方法
 *
 *  @param controller 授权控制器
 *  @param payment    支付对象
 *  @param completion 系统给定的一个回调代码块, 我们需要执行这个代码块, 来告诉系统当前的支付状态是否成功.
 */
- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller didAuthorizePayment:(PKPayment *)payment completion:(void (^)(PKPaymentAuthorizationStatus))completion{
    
// 一般在此处,拿到支付信息, 发送给服务器处理, 处理完毕之后, 服务器会返回一个状态, 告诉客户端,是否支付成功, 然后由客户端进行处理
    BOOL isSucess = YES;
    
    if (isSucess) {
        completion(PKPaymentAuthorizationStatusSuccess);
    }else{
        completion(PKPaymentAuthorizationStatusFailure);
    }
}

/**
 *  当用户授权成功, 或者取消授权时调用
 */
- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller{
    NSLog(@"授权结束");
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
