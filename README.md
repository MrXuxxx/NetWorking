# NetWorking
    第一次上传自己的代码，因为着急，没来得及整理，希望大家可以看得懂，如果看不懂可以及时给我留言。我会给大家梳理一下，当然这是第一个版本的断点续传，还有很多问题，我会在日后对此进行不断更新，不过正常的项目需求本人已经亲测过，没什么问题。其中ZSBreakPointDownload文件就是负责断点续传的，使用方法很简单，但是需要记住的是，- (NSURLSession *)backgroundSession;这个方法，如果需求有需要程序再次启动的时候继续下载，请记得在appDelegate中写下一下代码：

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[ZSBreakPointDownload sharedManager] backgroundSession];
    return YES;
}
第一次下载一个链接，需要使用- (void)beginDownloadTask:(NSString *)urlString keyname:(NSString *)keyname;方法。方法中第一个参数是url下载链接，第二个是为这个下载加一个key，为了以后再使用这个任务的时候能够快速找到。因为我在所有下载状态中都加了监听，如果需要监听状态，只需要加上观察者就可以了，很简单，在demo中都有体现，虽然demo写的比较乱，但是我都尽量的规范了一下命名，以便大家可以更好的使用，发现问题后，希望可以给我及时留言，以便本人后期的修改和维护。谢谢！
