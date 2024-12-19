/*!
 * Copyright (c) 2023 Emeric Grange
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

#include "utils_os_ios_notif.h"
#include "utils_os_ios.h"

#if defined(Q_OS_IOS)

#include <QVariant>
#include <QString>

#import <UserNotifications/UserNotifications.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/* ************************************************************************** */

@interface NotificationDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate>
{
    UtilsIOSNotifications *g_IosNotifier;
}
@end

@implementation NotificationDelegate

- (id)initWithObject:(UtilsIOSNotifications *)localNotification
{
    self = [super init];
    if (self)
    {
        g_IosNotifier = localNotification;
    }
    return self;
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
        willPresentNotification:(UNNotification *)notification
            withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    Q_UNUSED(center)
    long var = [[notification.request.content.userInfo objectForKey:@"ID"] longValue];

    completionHandler(UNNotificationPresentationOptionList | UNNotificationPresentationOptionBanner | UNNotificationPresentationOptionSound);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
        didReceiveNotificationResponse:(UNNotificationResponse *)response
            withCompletionHandler:(void(^)())completionHandler
{
    Q_UNUSED(center)
    Q_UNUSED(response)
    completionHandler();
}
@end

/* ************************************************************************** */

UtilsIOSNotifications::UtilsIOSNotifications()
{
    m_notifdelegate = [[NotificationDelegate alloc] initWithObject:this];
}

bool UtilsIOSNotifications::checkPermission_notification()
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

bool UtilsIOSNotifications::getPermission_notification()
{
    __block BOOL status = false;

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

bool UtilsIOSNotifications::notify(const QString &title, const QString &message, const int channel)
{
    // Create content
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = title.toNSString();
    content.body = message.toNSString();
    content.sound = [UNNotificationSound defaultSound]; // withAudioVolume:1.0

    // Create trigger time
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.33 repeats:NO];

    // Unique identifier
    NSString *identifierNSString = QString::number(channel).toNSString();

    // Create notification request
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifierNSString content:content trigger:trigger];

    // Add request
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = id(m_notifdelegate);

    [center addNotificationRequest:request withCompletionHandler:^(NSError *_Nullable error)
    {
        if (error)
        {
            NSLog(@"Local Notification failed");
        }
    }];

    return true;
}

/* ************************************************************************** */
#endif // Q_OS_IOS
