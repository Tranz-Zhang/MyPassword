# MyPassword

A simple app use AES-256 encryption to manage your password

The AES-256 encryption is implemented by [RNCryptor](https://github.com/RNCryptor/RNCryptor).

---

# API详细说明

## **1.SDK通用接口**

### CheckSDKFeature
---
* **接口声明**

      public static void CheckSDKFeature()

* **描述**

  检查SDK可用功能，类似于白名单作用。这个接口通过向后台查询当前SDK开放的功能。

  > 注意: 这个接口会走网络通讯向后台查询，因此回调的时间与网络状况相关。第一次查询成功后，会缓存查询结果到内存中，后续请求不会走网络通讯。 这个功能需要通过后台配置来实现，如果没有返回任何支持的SDK功能，请联系我们这边的产品同学进行配置.

* **回调通知**

  接口调用之后，通过消息通知进行回调。通知回调带类型为GameJoy.SDKFeature的参数，可通过与操作判断是否支持某个功能。

  注册事件：*EventID.GAMEJOY_SDK_FEATURE_CHECK_RESULT*

  回调参数：GameJoy.SDKFeature

``` cs
示例代码:

// 注册通知
EventRouter.instance.AddEventHandler<GameJoy.SDKFeature>(EventID.GAMEJOY_SDK_FEATURE_CHECK_RESULT, onReciever);

// 调用方法
GameJoy.CheckSDKFeature();

// 回调函数
public void onReciever(GameJoy.SDKFeature supportedSDKFeature) {
  if ((supportedSDKFeature & GameJoy.SDKFeature.Moment) != 0) {
    // 支持时刻录制
  }

  if ((supportedSDKFeature & GameJoy.SDKFeature.Manual) != 0) {
    // 支持自由录制
  }
  // 如果没有支持的功能，说明SDK目前无法使用，相关功能接口也无法调用。
}
```



### getSystemCurrentTimeMillis
---
* **接口声明**

      public static long getSystemCurrentTimeMillis()

* **返回值**

  一个long值表明当前的时间，单位为毫秒，参考起始时间为1970年

* **描述**

  获取当前系统时间。如果使用时刻功能时，游戏方记录的时间戳不够精准，可考虑使用这个接口来获取更为准确的时间。



### CheckSDKPermission
---
* **接口声明**

      public static void CheckSDKPermission()

* **描述**

  检查SDK所需权限，这个接口主要用于SDK向系统申请一些必要的权限，如系统相册，麦克风等。如果权限检查失败，SDK会弹窗提示用户开启相关权限，这个时候不建议开启录屏功能。

  > 由于权限申请是一次性的，不需要在每次使用录屏功能的时候调用。推荐打开录屏功能的时候调用。

* **回调通知**

  注册事件：*EventID.GAMEJOY_SDK_FEATURE_CHECK_RESULT*

  回调参数：bool值，表明权限申请是否成功

``` cs
示例代码:

// 注册通知
EventRouter.instance.AddEventHandler<bool>(EventID.GAMEJOY_SDK_FEATURE_CHECK_RESULT, onCheckSDKPermission);

// 调用方法
GameJoy.instance.checkSDKPermission();

// 回调函数
public void onCheckSDKPermission(bool isSuccess) {
  if (isSuccess) {
     // 权限检查成功
  } else {
     // 权限检查失败
  }
}

```
