/**
 * @file NodeImageValueTransformer.m
 *
 * @author Perry Spagnola
 * @date 2/13/11 - created
 * @version 1.0
 * @brief Class file for the NodeImageValueTransformer class.
 * @details This class enables the display of the Mac machine icon
 * associated with the model code for the node published by bonjour.
 * The default Mac machine icon is provided if the icon for the
 * published model code cannot be found.
 *
 * @copyright Copyright 2011 Perry M. Spagnola. All rights reserved.
 *
 * @section LICENSE
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details at
 * http://www.gnu.org/copyleft/gpl.html
 */

#import "NodeImageValueTransformer.h"


@implementation NodeImageValueTransformer
+ (Class)transformedValueClass { return [NSString class]; }
+ (BOOL)allowsReverseTransformation { return YES; }
- (id)transformedValue:(id)value {
    
    // DEBUG: NSLog(@"NodeImageValueTransformer transformedValueClass: %@", value);
    
    return [self getComputerIconForModelCode:value];
}

/**
 * Returns the Icon for the ModelCode published by bonjour.
 * if the modelCode can not be associated to an icon the default Mac icon is returned.
 * @param modelCode - the model code to retrieve the icon for
 *
 * @return the icon associated with the model code or the default Mac icon
 * @retval success - the the icon associated with the model code argument
 * @retval failure - the default mac machine icon
 */
-(NSImage *) getComputerIconForModelCode:(NSString *)modelCode {
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSImage *iconImage = nil;
    
    if ((nil != modelCode) && (![modelCode isEqualToString:@""])) {
        // If you have a mapping from model code to file extension or UTI, use it here.
        // For example, assume modelCode could be "txt" or "public.plain-text".
        NSString *fileType = modelCode;
        iconImage = [workspace iconForFileType:fileType];
    }
    
    if (!iconImage || [iconImage isValid] == NO) {
        // Fall back to a default icon if necessary.
        iconImage = [self getDefaultMacComputerIcon];
    }
    
    return iconImage;
}


/**
 * Returns the default Mac machine icon.
 *
 * @return the default Mac icon
 * @retval success - the default mac machine icon
 * @retval failure - nil
 */
-(NSImage *) getDefaultMacComputerIcon {
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    NSString *fileType = NSFileTypeForHFSTypeCode(kComputerIcon);
    NSImage *iconImage = [workspace iconForFileType:fileType];
    return iconImage;
}

@end
