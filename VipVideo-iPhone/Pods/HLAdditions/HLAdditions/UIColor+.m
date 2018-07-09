//
//  UIColor+.m
//  iMSC
//
//

#import "UIColor+.h"

#if ! __has_feature(objc_arc)
// set -fobjc-arc flag: - Target > Build Phases > Compile Sources > implementation.m + -fobjc-arc
#error This file must be compiled with ARC. Use -fobjc-arc flag or convert project to ARC.
#endif

#if ! __has_feature(objc_arc_weak)
#error ARCWeakRef requires iOS 5 and higher.
#endif

@implementation UIColor (HLCategory)

- (UIColor *)inverseColor {
    
    CGColorRef oldCGColor = self.CGColor;
    
    NSInteger numberOfComponents = CGColorGetNumberOfComponents(oldCGColor);
    
    // can not invert - the only component is the alpha
    // e.g. self == [UIColor groupTableViewBackgroundColor]
    if (numberOfComponents <= 1) {
        return [UIColor colorWithCGColor:oldCGColor];
    }
    
    const CGFloat *oldComponentColors = CGColorGetComponents(oldCGColor);
    CGFloat newComponentColors[numberOfComponents];
    int i = - 1;
    while (++i < numberOfComponents - 1) {
        newComponentColors[i] = 1 - oldComponentColors[i];
    }
    newComponentColors[i] = oldComponentColors[i]; // alpha
    
    CGColorRef newCGColor = CGColorCreate(CGColorGetColorSpace(oldCGColor), newComponentColors);
    UIColor *newColor = [UIColor colorWithCGColor:newCGColor];
    CGColorRelease(newCGColor);
    
    return newColor;
}

+ (UIColor *)colorWithName:(NSString *)name {
    static NSDictionary *colors = nil;
    
    if (colors) {
        return [colors objectForKey:[name lowercaseString]];
    }
    
    @synchronized(self) {
        if (!colors) {
            colors = @{// UIColor colors
                       [@"_black"               lowercaseString]: [self blackColor],
                       [@"_darkgray"            lowercaseString]: [self darkGrayColor],
                       [@"_lightgray"           lowercaseString]: [self lightGrayColor],
                       [@"_white"               lowercaseString]: [self whiteColor],
                       [@"_gray"                lowercaseString]: [self grayColor],
                       [@"_red"                 lowercaseString]: [self redColor],
                       [@"_green"               lowercaseString]: [self greenColor],
                       [@"_blue"                lowercaseString]: [self blueColor],
                       [@"_cyan"                lowercaseString]: [self cyanColor],
                       [@"_yellow"              lowercaseString]: [self yellowColor],
                       [@"_magenta"             lowercaseString]: [self magentaColor],
                       [@"_orange"              lowercaseString]: [self orangeColor],
                       [@"_purple"              lowercaseString]: [self purpleColor],
                       [@"_brown"               lowercaseString]: [self brownColor],
                       [@"_clear"               lowercaseString]: [self clearColor],
                       // web colors, see http://www.w3school.com.cn/html/html_colornames.asp
                       [@"transparent"          lowercaseString]: [self clearColor],
                       [@"AliceBlue"            lowercaseString]: [self colorWithHexString:@"#F0F8FF"],
                       [@"AntiqueWhite"         lowercaseString]: [self colorWithHexString:@"#FAEBD7"],
                       [@"Aqua"                 lowercaseString]: [self colorWithHexString:@"#00FFFF"],
                       [@"Aquamarine"           lowercaseString]: [self colorWithHexString:@"#7FFFD4"],
                       [@"Azure"                lowercaseString]: [self colorWithHexString:@"#F0FFFF"],
                       [@"Beige"                lowercaseString]: [self colorWithHexString:@"#F5F5DC"],
                       [@"Bisque"               lowercaseString]: [self colorWithHexString:@"#FFE4C4"],
                       [@"Black"                lowercaseString]: [self colorWithHexString:@"#000000"],
                       [@"BlanchedAlmond"       lowercaseString]: [self colorWithHexString:@"#FFEBCD"],
                       [@"Blue"                 lowercaseString]: [self colorWithHexString:@"#0000FF"],
                       [@"BlueViolet"           lowercaseString]: [self colorWithHexString:@"#8A2BE2"],
                       [@"Brown"                lowercaseString]: [self colorWithHexString:@"#A52A2A"],
                       [@"BurlyWood"            lowercaseString]: [self colorWithHexString:@"#DEB887"],
                       [@"CadetBlue"            lowercaseString]: [self colorWithHexString:@"#5F9EA0"],
                       [@"Chartreuse"           lowercaseString]: [self colorWithHexString:@"#7FFF00"],
                       [@"Chocolate"            lowercaseString]: [self colorWithHexString:@"#D2691E"],
                       [@"Coral"                lowercaseString]: [self colorWithHexString:@"#FF7F50"],
                       [@"CornflowerBlue"       lowercaseString]: [self colorWithHexString:@"#6495ED"],
                       [@"Cornsilk"             lowercaseString]: [self colorWithHexString:@"#FFF8DC"],
                       [@"Crimson"              lowercaseString]: [self colorWithHexString:@"#DC143C"],
                       [@"Cyan"                 lowercaseString]: [self colorWithHexString:@"#00FFFF"],
                       [@"DarkBlue"             lowercaseString]: [self colorWithHexString:@"#00008B"],
                       [@"DarkCyan"             lowercaseString]: [self colorWithHexString:@"#008B8B"],
                       [@"DarkGoldenRod"        lowercaseString]: [self colorWithHexString:@"#B8860B"],
                       [@"DarkGray"             lowercaseString]: [self colorWithHexString:@"#A9A9A9"],
                       [@"DarkGreen"            lowercaseString]: [self colorWithHexString:@"#006400"],
                       [@"DarkKhaki"            lowercaseString]: [self colorWithHexString:@"#BDB76B"],
                       [@"DarkMagenta"          lowercaseString]: [self colorWithHexString:@"#8B008B"],
                       [@"DarkOliveGreen"       lowercaseString]: [self colorWithHexString:@"#556B2F"],
                       [@"DarkOrchid"           lowercaseString]: [self colorWithHexString:@"#9932CC"],
                       [@"DarkRed"              lowercaseString]: [self colorWithHexString:@"#8B0000"],
                       [@"DarkSalmon"           lowercaseString]: [self colorWithHexString:@"#E9967A"],
                       [@"DarkSeaGreen"         lowercaseString]: [self colorWithHexString:@"#8FBC8F"],
                       [@"DarkSlateBlue"        lowercaseString]: [self colorWithHexString:@"#483D8B"],
                       [@"DarkSlateGray"        lowercaseString]: [self colorWithHexString:@"#2F4F4F"],
                       [@"DarkTurquoise"        lowercaseString]: [self colorWithHexString:@"#00CED1"],
                       [@"DarkViolet"           lowercaseString]: [self colorWithHexString:@"#9400D3"],
                       [@"Darkorange"           lowercaseString]: [self colorWithHexString:@"#FF8C00"],
                       [@"DeepPink"             lowercaseString]: [self colorWithHexString:@"#FF1493"],
                       [@"DeepSkyBlue"          lowercaseString]: [self colorWithHexString:@"#00BFFF"],
                       [@"DimGray"              lowercaseString]: [self colorWithHexString:@"#696969"],
                       [@"DodgerBlue"           lowercaseString]: [self colorWithHexString:@"#1E90FF"],
                       [@"Feldspar"             lowercaseString]: [self colorWithHexString:@"#D19275"],
                       [@"FireBrick"            lowercaseString]: [self colorWithHexString:@"#B22222"],
                       [@"FloralWhite"          lowercaseString]: [self colorWithHexString:@"#FFFAF0"],
                       [@"ForestGreen"          lowercaseString]: [self colorWithHexString:@"#228B22"],
                       [@"Fuchsia"              lowercaseString]: [self colorWithHexString:@"#FF00FF"],
                       [@"Gainsboro"            lowercaseString]: [self colorWithHexString:@"#DCDCDC"],
                       [@"GhostWhite"           lowercaseString]: [self colorWithHexString:@"#F8F8FF"],
                       [@"Gold"                 lowercaseString]: [self colorWithHexString:@"#FFD700"],
                       [@"GoldenRod"            lowercaseString]: [self colorWithHexString:@"#DAA520"],
                       [@"Gray"                 lowercaseString]: [self colorWithHexString:@"#808080"],
                       [@"Green"                lowercaseString]: [self colorWithHexString:@"#008000"],
                       [@"GreenYellow"          lowercaseString]: [self colorWithHexString:@"#ADFF2F"],
                       [@"HoneyDew"             lowercaseString]: [self colorWithHexString:@"#F0FFF0"],
                       [@"HotPink"              lowercaseString]: [self colorWithHexString:@"#FF69B4"],
                       [@"IndianRed"            lowercaseString]: [self colorWithHexString:@"#CD5C5C"],
                       [@"Indigo"               lowercaseString]: [self colorWithHexString:@"#4B0082"],
                       [@"Ivory"                lowercaseString]: [self colorWithHexString:@"#FFFFF0"],
                       [@"Khaki"                lowercaseString]: [self colorWithHexString:@"#F0E68C"],
                       [@"Lavender"             lowercaseString]: [self colorWithHexString:@"#E6E6FA"],
                       [@"LavenderBlush"        lowercaseString]: [self colorWithHexString:@"#FFF0F5"],
                       [@"LawnGreen"            lowercaseString]: [self colorWithHexString:@"#7CFC00"],
                       [@"LemonChiffon"         lowercaseString]: [self colorWithHexString:@"#FFFACD"],
                       [@"LightBlue"            lowercaseString]: [self colorWithHexString:@"#ADD8E6"],
                       [@"LightCoral"           lowercaseString]: [self colorWithHexString:@"#F08080"],
                       [@"LightCyan"            lowercaseString]: [self colorWithHexString:@"#E0FFFF"],
                       [@"LightGoldenRodYellow" lowercaseString]: [self colorWithHexString:@"#FAFAD2"],
                       [@"LightGreen"           lowercaseString]: [self colorWithHexString:@"#90EE90"],
                       [@"LightGrey"            lowercaseString]: [self colorWithHexString:@"#D3D3D3"],
                       [@"LightPink"            lowercaseString]: [self colorWithHexString:@"#FFB6C1"],
                       [@"LightSalmon"          lowercaseString]: [self colorWithHexString:@"#FFA07A"],
                       [@"LightSeaGreen"        lowercaseString]: [self colorWithHexString:@"#20B2AA"],
                       [@"LightSkyBlue"         lowercaseString]: [self colorWithHexString:@"#87CEFA"],
                       [@"LightSlateBlue"       lowercaseString]: [self colorWithHexString:@"#8470FF"],
                       [@"LightSlateGray"       lowercaseString]: [self colorWithHexString:@"#778899"],
                       [@"LightSteelBlue"       lowercaseString]: [self colorWithHexString:@"#B0C4DE"],
                       [@"LightYellow"          lowercaseString]: [self colorWithHexString:@"#FFFFE0"],
                       [@"Lime"                 lowercaseString]: [self colorWithHexString:@"#00FF00"],
                       [@"LimeGreen"            lowercaseString]: [self colorWithHexString:@"#32CD32"],
                       [@"Linen"                lowercaseString]: [self colorWithHexString:@"#FAF0E6"],
                       [@"Magenta"              lowercaseString]: [self colorWithHexString:@"#FF00FF"],
                       [@"Maroon"               lowercaseString]: [self colorWithHexString:@"#800000"],
                       [@"MediumAquaMarine"     lowercaseString]: [self colorWithHexString:@"#66CDAA"],
                       [@"MediumBlue"           lowercaseString]: [self colorWithHexString:@"#0000CD"],
                       [@"MediumOrchid"         lowercaseString]: [self colorWithHexString:@"#BA55D3"],
                       [@"MediumPurple"         lowercaseString]: [self colorWithHexString:@"#9370D8"],
                       [@"MediumSeaGreen"       lowercaseString]: [self colorWithHexString:@"#3CB371"],
                       [@"MediumSlateBlue"      lowercaseString]: [self colorWithHexString:@"#7B68EE"],
                       [@"MediumSpringGreen"    lowercaseString]: [self colorWithHexString:@"#00FA9A"],
                       [@"MediumTurquoise"      lowercaseString]: [self colorWithHexString:@"#48D1CC"],
                       [@"MediumVioletRed"      lowercaseString]: [self colorWithHexString:@"#C71585"],
                       [@"MidnightBlue"         lowercaseString]: [self colorWithHexString:@"#191970"],
                       [@"MintCream"            lowercaseString]: [self colorWithHexString:@"#F5FFFA"],
                       [@"MistyRose"            lowercaseString]: [self colorWithHexString:@"#FFE4E1"],
                       [@"Moccasin"             lowercaseString]: [self colorWithHexString:@"#FFE4B5"],
                       [@"NavajoWhite"          lowercaseString]: [self colorWithHexString:@"#FFDEAD"],
                       [@"Navy"                 lowercaseString]: [self colorWithHexString:@"#000080"],
                       [@"OldLace"              lowercaseString]: [self colorWithHexString:@"#FDF5E6"],
                       [@"Olive"                lowercaseString]: [self colorWithHexString:@"#808000"],
                       [@"OliveDrab"            lowercaseString]: [self colorWithHexString:@"#6B8E23"],
                       [@"Orange"               lowercaseString]: [self colorWithHexString:@"#FFA500"],
                       [@"OrangeRed"            lowercaseString]: [self colorWithHexString:@"#FF4500"],
                       [@"Orchid"               lowercaseString]: [self colorWithHexString:@"#DA70D6"],
                       [@"PaleGoldenRod"        lowercaseString]: [self colorWithHexString:@"#EEE8AA"],
                       [@"PaleGreen"            lowercaseString]: [self colorWithHexString:@"#98FB98"],
                       [@"PaleTurquoise"        lowercaseString]: [self colorWithHexString:@"#AFEEEE"],
                       [@"PaleVioletRed"        lowercaseString]: [self colorWithHexString:@"#D87093"],
                       [@"PapayaWhip"           lowercaseString]: [self colorWithHexString:@"#FFEFD5"],
                       [@"PeachPuff"            lowercaseString]: [self colorWithHexString:@"#FFDAB9"],
                       [@"Peru"                 lowercaseString]: [self colorWithHexString:@"#CD853F"],
                       [@"Pink"                 lowercaseString]: [self colorWithHexString:@"#FFC0CB"],
                       [@"Plum"                 lowercaseString]: [self colorWithHexString:@"#DDA0DD"],
                       [@"PowderBlue"           lowercaseString]: [self colorWithHexString:@"#B0E0E6"],
                       [@"Purple"               lowercaseString]: [self colorWithHexString:@"#800080"],
                       [@"Red"                  lowercaseString]: [self colorWithHexString:@"#FF0000"],
                       [@"RosyBrown"            lowercaseString]: [self colorWithHexString:@"#BC8F8F"],
                       [@"RoyalBlue"            lowercaseString]: [self colorWithHexString:@"#4169E1"],
                       [@"SaddleBrown"          lowercaseString]: [self colorWithHexString:@"#8B4513"],
                       [@"Salmon"               lowercaseString]: [self colorWithHexString:@"#FA8072"],
                       [@"SandyBrown"           lowercaseString]: [self colorWithHexString:@"#F4A460"],
                       [@"SeaGreen"             lowercaseString]: [self colorWithHexString:@"#2E8B57"],
                       [@"SeaShell"             lowercaseString]: [self colorWithHexString:@"#FFF5EE"],
                       [@"Sienna"               lowercaseString]: [self colorWithHexString:@"#A0522D"],
                       [@"Silver"               lowercaseString]: [self colorWithHexString:@"#C0C0C0"],
                       [@"SkyBlue"              lowercaseString]: [self colorWithHexString:@"#87CEEB"],
                       [@"SlateBlue"            lowercaseString]: [self colorWithHexString:@"#6A5ACD"],
                       [@"SlateGray"            lowercaseString]: [self colorWithHexString:@"#708090"],
                       [@"Snow"                 lowercaseString]: [self colorWithHexString:@"#FFFAFA"],
                       [@"SpringGreen"          lowercaseString]: [self colorWithHexString:@"#00FF7F"],
                       [@"SteelBlue"            lowercaseString]: [self colorWithHexString:@"#4682B4"],
                       [@"Tan"                  lowercaseString]: [self colorWithHexString:@"#D2B48C"],
                       [@"Teal"                 lowercaseString]: [self colorWithHexString:@"#008080"],
                       [@"Thistle"              lowercaseString]: [self colorWithHexString:@"#D8BFD8"],
                       [@"Tomato"               lowercaseString]: [self colorWithHexString:@"#FF6347"],
                       [@"Turquoise"            lowercaseString]: [self colorWithHexString:@"#40E0D0"],
                       [@"Violet"               lowercaseString]: [self colorWithHexString:@"#EE82EE"],
                       [@"VioletRed"            lowercaseString]: [self colorWithHexString:@"#D02090"],
                       [@"Wheat"                lowercaseString]: [self colorWithHexString:@"#F5DEB3"],
                       [@"White"                lowercaseString]: [self colorWithHexString:@"#FFFFFF"],
                       [@"WhiteSmoke"           lowercaseString]: [self colorWithHexString:@"#F5F5F5"],
                       [@"Yellow"               lowercaseString]: [self colorWithHexString:@"#FFFF00"],
                       [@"YellowGreen"          lowercaseString]: [self colorWithHexString:@"#9ACD32"] };
        }
    }
    
    return [colors objectForKey:[name lowercaseString]];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString {
    if ([hexString hasPrefix:@"#"]) {
        hexString = [hexString substringFromIndex:1];
    }
    if ([[hexString lowercaseString] hasPrefix:@"0x"]) {
        hexString = [hexString substringFromIndex:2];
    }
    if ([hexString length] != 6) {
        return nil;
    }
    
    NSScanner *scanner = [[NSScanner alloc] initWithString:hexString];
    unsigned hexValue = 0;
    if ([scanner scanHexInt:&hexValue] && [scanner isAtEnd]) {
        int r = ((hexValue & 0xFF0000) >> 16);
        int g = ((hexValue & 0x00FF00) >>  8);
        int b = ( hexValue & 0x0000FF)       ;
        return [self colorWithRed:((float)r / 255)
                            green:((float)g / 255)
                             blue:((float)b / 255)
                            alpha:1.0];
    }
    
    return nil;
}

+ (UIColor *)colorWithName:(NSString *)name alpha:(CGFloat)alpha {
    return [[self colorWithName:name] colorWithAlphaComponent:alpha];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha {
    return [[self colorWithHexString:hexString] colorWithAlphaComponent:alpha];
}

@end
