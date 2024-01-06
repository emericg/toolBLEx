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

- (id) initWithObject:(UtilsIOSNotifications *)localNotification
{
    self = [super init];
    if (self)
    {
        g_IosNotifier = localNotification;
    }
    return self;
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center
        willPresentNotification:(UNNotification *)notification
            withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
    Q_UNUSED(center)
    long var = [[notification.request.content.userInfo objectForKey:@"ID"] longValue];

    completionHandler(UNNotificationPresentationOptionAlert);
}

-(void)userNotificationCenter:(UNUserNotificationCenter *)center
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
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionSound | UNAuthorizationOptionAlert | UNAuthorizationOptionBadge) completionHandler:^(BOOL granted, NSError * _Nullable error)
    {
        Q_UNUSED(granted);
        if (!error)
        {
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
    }];
}

bool UtilsIOSNotifications::notify(const QString &title, const QString &message, const int channel)
{
    // create content
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = title.toNSString();
    content.body = message.toNSString();
    content.sound = [UNNotificationSound defaultSound];
    //content.badge = @([[UIApplication sharedApplication] applicationIconBadgeNumber] + 1);

    // create trigger time
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];

    // unique identifier
    NSString* identifierNSString = QString::number(channel).toNSString();

    // create notification request
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifierNSString content:content trigger:trigger];

    // add request
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = id(m_notifdelegate);

    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            NSLog(@"Local Notification failed");
        }
    }];

    return true;
}

/* ************************************************************************** */
#endif // Q_OS_IOS
