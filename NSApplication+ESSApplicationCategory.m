//
//  NSApplication+ESSApplicationCategory.m
//
//  Created by Matthias Gansrigler on 01.10.12.
//  Copyright (c) 2012 Eternal Storms Software. All rights reserved.
//

/*
 SOURCE CODE LICENSE
 
 1) You can use the code in your own products.
 2) You can modify the code as you wish, and use the modified code in your products.
 3) You can redistribute the original, unmodified code, but you have to include the full license text below.
 4) You can redistribute the modified code as you wish (without the full license text below).
 5) In all cases, you must include a credit mentioning Matthias Gansrigler as the original author of the source.
 6) I’m not liable for anything you do with the code, no matter what. So be sensible.
 7) You can’t use my name or other marks to promote your products based on the code.
 8) If you agree to all of that, go ahead and download the source. Otherwise, don’t.
 
 Contact: Matthias Gansrigler || opensource@eternalstorms.at ||  http://eternalstorms.at || @eternalstorms on twitter
 */

#import "NSApplication+ESSApplicationCategory.h"

@interface NSApplication (ESSApplicationCategoryPrivate)

- (void)_registerForceTouchDeviceMonitor;
- (void)_unregisterForceTouchDeviceMonitor;
- (BOOL)_containsForceTouchDevice:(io_iterator_t)iterator;

@end

static BOOL ess_IsCheckingForDevices = NO;
static BOOL ess_DeviceAvailable = NO;

@implementation NSApplication (ESSApplicationCategory)

void ESSBeginAlertSheet(NSString *title,
						NSString *defaultButton,
						NSString *alternateButton,
						NSString *otherButton,
						NSWindow *window,
						void (^didEndBlock)(void *contextInf,
											NSInteger returnCode),
						void (^didDismissBlock)(void *contextInf,
												NSInteger returnCode),
						void *contextInfo,
						NSString *formattedString)
{
	NSMutableDictionary *contextInf = [NSMutableDictionary dictionary];
	if (didEndBlock != nil)
		[contextInf setObject:[[didEndBlock copy] autorelease] forKey:@"didEndBlock"];
	if (didDismissBlock != nil)
		[contextInf setObject:[[didDismissBlock copy] autorelease] forKey:@"didDismissBlock"];
	if (contextInfo != nil)
		[contextInf setObject:contextInfo forKey:@"contextInfo"];
	NSBeginAlertSheet(title, defaultButton, alternateButton, otherButton, window, NSApp, @selector(_esswin:didEndWithCode:context:), @selector(_esswin:didDismissWithCode:context:), [contextInf retain], formattedString,nil);
}

void ESSBeginInformationalAlertSheet(NSString *title,
									 NSString *defaultButton,
									 NSString *alternateButton,
									 NSString *otherButton,
									 NSWindow *window,
									 void (^didEndBlock)(void *contextInf,
														 NSInteger returnCode),
									 void (^didDismissBlock)(void *contextInf,
															 NSInteger returnCode),
									 void *contextInfo,
									 NSString *formattedString)
{
	NSMutableDictionary *contextInf = [NSMutableDictionary dictionary];
	if (didEndBlock != nil)
		[contextInf setObject:[[didEndBlock copy] autorelease] forKey:@"didEndBlock"];
	if (didDismissBlock != nil)
		[contextInf setObject:[[didDismissBlock copy] autorelease] forKey:@"didDismissBlock"];
	if (contextInfo != nil)
		[contextInf setObject:contextInfo forKey:@"contextInfo"];
	NSBeginInformationalAlertSheet(title, defaultButton, alternateButton, otherButton, window, NSApp, @selector(_esswin:didEndWithCode:context:), @selector(_esswin:didDismissWithCode:context:), [contextInf retain], formattedString,nil);
}

void ESSBeginCriticalAlertSheet(NSString *title,
								NSString *defaultButton,
								NSString *alternateButton,
								NSString *otherButton,
								NSWindow *window,
								void (^didEndBlock)(void *contextInf,
													NSInteger returnCode),
								void (^didDismissBlock)(void *contextInf,
														NSInteger returnCode),
								void *contextInfo,
								NSString *formattedString)
{
	NSMutableDictionary *contextInf = [NSMutableDictionary dictionary];
	if (didEndBlock != nil)
		[contextInf setObject:[[didEndBlock copy] autorelease] forKey:@"didEndBlock"];
	if (didDismissBlock != nil)
		[contextInf setObject:[[didDismissBlock copy] autorelease] forKey:@"didDismissBlock"];
	if (contextInfo != nil)
		[contextInf setObject:contextInfo forKey:@"contextInfo"];
	NSBeginCriticalAlertSheet(title, defaultButton, alternateButton, otherButton, window, NSApp, @selector(_esswin:didEndWithCode:context:), @selector(_esswin:didDismissWithCode:context:), [contextInf retain], formattedString,nil);
}

- (void)_esswin:(NSPanel *)panel didEndWithCode:(NSInteger)code context:(void *)context
{
	NSDictionary *dict = (NSDictionary *)context;
	void (^didEndBlock)(void *contextInf, NSInteger returnCode) = [dict objectForKey:@"didEndBlock"];
	void *contextInf = [dict objectForKey:@"contextInfo"];
	
	if (didEndBlock != nil)
		didEndBlock(contextInf,code);
}

- (void)_esswin:(NSPanel *)panel didDismissWithCode:(NSInteger)code context:(void *)context
{
	NSDictionary *dict = (NSDictionary *)context;
	void (^didDismissBlock)(void *contextInf, NSInteger returnCode) = [dict objectForKey:@"didDismissBlock"];
	void *contextInf = [dict objectForKey:@"contextInfo"];
	
	if (didDismissBlock != nil)
		didDismissBlock(contextInf,code);
	[dict autorelease];
}

#pragma mark - Force Touch Availability

static IOHIDManagerRef hidManager;

static void ESS_DeviceMatchingCallback(void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef inIOHIDDeviceRef)
{
	if (ess_IsCheckingForDevices || ess_DeviceAvailable == YES)
		return;
	
	ess_IsCheckingForDevices = YES;
	BOOL deviceAvailable = [NSApp isForceTouchCapableDeviceAvailable:NSApp];
	ess_IsCheckingForDevices = NO;
	
	if (deviceAvailable && ess_DeviceAvailable == NO)
	{
		ess_DeviceAvailable = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:ESS_FORCETOUCHAVAILABILITY_NOTIFICATIONNAME object:nil userInfo:@{kESSForceTouchAvailableUserInfoKey:@(YES)}];
	}
}

static void ESS_DeviceRemovalCallback(void *inContext, IOReturn inResult, void *inSender, IOHIDDeviceRef inIOHIDDeviceRef)
{
	if (ess_IsCheckingForDevices || ess_DeviceAvailable == NO)
		return;
	
	ess_IsCheckingForDevices = YES;
	BOOL deviceAvailable = [NSApp isForceTouchCapableDeviceAvailable:NSApp];
	ess_IsCheckingForDevices = NO;
	
	if (!deviceAvailable && ess_DeviceAvailable == YES)
	{
		ess_DeviceAvailable = NO;
		[[NSNotificationCenter defaultCenter] postNotificationName:ESS_FORCETOUCHAVAILABILITY_NOTIFICATIONNAME object:nil userInfo:@{kESSForceTouchAvailableUserInfoKey:@(NO)}];
	}
}

- (void)_registerForceTouchDeviceMonitor
{
	if (hidManager != NULL)
		return;
	
	hidManager = IOHIDManagerCreate(kCFAllocatorDefault, kIOHIDManagerOptionNone);
	
	/*CFMutableArrayRef multiple = CFArrayCreateMutable(kCFAllocatorDefault, 2, NULL);
	 CFMutableDictionaryRef mDict = IOServiceMatching(kIOHIDDeviceKey);
	 
	 CFDictionaryAddValue(mDict, CFSTR(kIOHIDManufacturerKey), CFSTR("Apple"));
	 CFArrayAppendValue(multiple, mDict);
	 
	 mDict = IOServiceMatching(kIOHIDDeviceKey);
	 
	 CFDictionaryAddValue(mDict, CFSTR(kIOHIDManufacturerKey), CFSTR("Apple Inc."));
	 CFArrayAppendValue(multiple, mDict);
	 
	 IOHIDManagerSetDeviceMatchingMultiple(mRef, multiple);
	 
	 CFRelease(multiple);*/
	
	CFMutableDictionaryRef mDict = IOServiceMatching(kIOHIDDeviceKey);
	IOHIDManagerSetDeviceMatching(hidManager, mDict);
	
	IOHIDManagerRegisterDeviceMatchingCallback(hidManager, ESS_DeviceMatchingCallback, NULL);
	IOHIDManagerRegisterDeviceRemovalCallback(hidManager, ESS_DeviceRemovalCallback, NULL);
	
	IOHIDManagerScheduleWithRunLoop(hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	
	IOHIDManagerOpen(hidManager, kIOHIDManagerOptionNone);
}

- (void)_unregisterForceTouchDeviceMonitor
{
	if (hidManager == NULL)
		return;
	
	IOHIDManagerUnscheduleFromRunLoop(hidManager, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
	IOHIDManagerClose(hidManager, kIOHIDManagerOptionNone);
	CFRelease(hidManager);
}

- (BOOL)isForceTouchCapableDeviceAvailable:(id)sender
{
	CFMutableDictionaryRef mDict = IOServiceMatching(kIOHIDDeviceKey);
	
	io_iterator_t iterator;
	IOReturn ioReturnValue = IOServiceGetMatchingServices(kIOMasterPortDefault, mDict, &iterator);
	
	BOOL result = YES;
	if (ioReturnValue != kIOReturnSuccess)
		NSLog(@"Searching for devices unsuccessful");
	else
	{
		ess_IsCheckingForDevices = YES;
		result = [self _containsForceTouchDevice:iterator];
		if (sender == nil)
			ess_DeviceAvailable = result;
		ess_IsCheckingForDevices = NO;
		IOObjectRelease(iterator);
	}
	
	[self _registerForceTouchDeviceMonitor];
	
	return result;
}

- (BOOL)_containsForceTouchDevice:(io_iterator_t)iterator
{
	if (IOIteratorIsValid(iterator) == false)
		return NO;
	
	io_object_t object = 0;
	BOOL success = NO;
	while ((object = IOIteratorNext(iterator)))
	{
		CFMutableDictionaryRef result = NULL;
		kern_return_t state = IORegistryEntryCreateCFProperties(object, &result, kCFAllocatorDefault, 0);
		if (state == KERN_SUCCESS && result != NULL)
		{
			io_name_t className;
			IOObjectGetClass(object, className);
			if (CFDictionaryContainsKey(result, CFSTR("DefaultMultitouchProperties")))
			{
				CFDictionaryRef dict = CFDictionaryGetValue(result, CFSTR("DefaultMultitouchProperties"));
				CFTypeRef val = NULL;
				if (CFDictionaryGetValueIfPresent(dict, CFSTR("ForceSupported"), &val))
				{
					Boolean aBool = CFBooleanGetValue(val);
					if (aBool) //supported
					{
						CFRelease(result);
						success = YES;
					}
				}
			}
		}
		
		if (success)
		{
			IOObjectRelease(object);
			break;
		} else
		{
			if (result != NULL)
				CFRelease(result);
			
			io_iterator_t childIterator = 0;
			kern_return_t err = IORegistryEntryGetChildIterator(object, kIOServicePlane, &childIterator);
			if (err == KERN_SUCCESS)
			{
				success = [self _containsForceTouchDevice:childIterator];
				IOObjectRelease(childIterator);
			} else
				success = NO;
			
			IOObjectRelease(object);
		}
	}
	
	return success;
}

@end
