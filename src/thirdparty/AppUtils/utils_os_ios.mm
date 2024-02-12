/*!
 * Copyright (c) 2020 Emeric Grange
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "utils_os_ios.h"

#if defined(Q_OS_IOS)

#import <UserNotifications/UserNotifications.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/* ************************************************************************** */

bool UtilsIOS::checkPermission_notification()
{
    __block BOOL status = false;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = (UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound);

    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *settings) {
        switch (settings.authorizationStatus) {
            case UNAuthorizationStatusAuthorized:
                //NSLog(@"Notifications are allowed");
                status = true;
                break;
            case UNAuthorizationStatusDenied:
                //NSLog(@"Notifications are denied");
                break;
            case UNAuthorizationStatusNotDetermined:
                //NSLog(@"Notification permissions not determined yet");
                break;
            case UNAuthorizationStatusProvisional:
                //NSLog(@"Provisional authorization granted");
                status = true;
                break;
            default:
                //NSLog(@"Unknown notification authorization status");
                break;
        }

        dispatch_semaphore_signal(semaphore);
    }];

    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);

    return status;
}

bool UtilsIOS::getPermission_notification()
{
    __block bool status = false;

    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = (UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound);

    [center requestAuthorizationWithOptions:options
      completionHandler:^(BOOL granted, NSError *_Nullable error) {
        if (granted)
        {
            NSLog(@"Notification permission granted");
            status = true;
        }

        if (error)
        {
            NSLog(@"Local Notification setup failed");
        }
        else
        {
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
    }];

    return status;
}

/* ************************************************************************** */

void UtilsIOS::screenKeepOn(bool on)
{
    if (on)
    {
        [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    }
    else
    {
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
    }
}

// For reference:
//enum ScreenOrientation_iOS {
//    UIInterfaceOrientationUnknown = 0,          // The orientation of the device is unknown.
//    UIInterfaceOrientationPortrait,             // The device is in portrait mode, with the device upright and the Home button on the bottom.
//    UIInterfaceOrientationPortraitUpsideDown,   // The device is in portrait mode but is upside down, with the device upright and the Home button at the top.
//    UIInterfaceOrientationLandscapeLeft,        // The device is in landscape mode, with the device upright and the Home button on the left.
//    UIInterfaceOrientationLandscapeRight,       // The device is in landscape mode, with the device upright and the Home button on the right.
//};

void UtilsIOS::screenLockOrientation(int orientation)
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];
    if (orientation != 0) value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];

    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

void UtilsIOS::screenLockOrientation(int orientation, bool autoRotate)
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];

    if (orientation == 0 || autoRotate) value = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];
    else if (orientation == 1) value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    else if (orientation == 2) value = [NSNumber numberWithInt:UIInterfaceOrientationPortraitUpsideDown];
    else if (orientation == 4) value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];
    else if (orientation == 8) value = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];

    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

/* ************************************************************************** */

void UtilsIOS::vibrate(int ms)
{
    Q_UNUSED(ms)

    UISelectionFeedbackGenerator *generator = [[UISelectionFeedbackGenerator alloc] init];
    [generator prepare];
    [generator selectionChanged];
    generator = nil;
}

/* ************************************************************************** */
#endif // Q_OS_IOS
