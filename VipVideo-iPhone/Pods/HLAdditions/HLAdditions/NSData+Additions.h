
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSData (NSDataAdditions)

/**
 * 工厂方法，通过base64编码一个字符串，得到一个nsdata,wrapped表示是否增加折行
 * 返回结果可以用UTF8转码输出。
 */
+(NSData *)base64EncodedData:(NSString*)inDataString withWrapped:(BOOL)wrapped;
/**
 * 工厂方法，通过base64解码的字符串，得到一个nsdata
 * 返回结果可以用UTF8转码输出。
 */
+(NSData *)base64DecodedData:(NSString*)inDataString;

//added ypc
- (NSString*)md5Hash;

//added by yangbaocheng
- (NSString*)data2HexString;
- (NSData *)AES256EncryptWithKey:(NSString *)key
                         encrypt:(BOOL)encrypt;   //加密

- (NSData *)DES256EncryptWithKey:(NSString *)key
                         encrypt:(BOOL)encrypt;     //加解密
@end
