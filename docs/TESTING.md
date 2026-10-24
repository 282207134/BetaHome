# 验证记录

验证日期：2026-10-24（Asia/Tokyo）。

## 环境

| 项目 | 环境 |
| --- | --- |
| 开发主机 | Windows 11 |
| Flutter / Dart | Flutter 3.47.7 stable / Dart 3.13.5 |
| Android | Android 15 / API 35，x86_64 模拟器 |
| 项目专用 AVD | `beta_home_review` |
| 截图分辨率 | 428 × 926 |
| 页面布局巡检 | 浅色 320 × 760、深色 428 × 926 |

## 验证内容

| 检查 | 结果 |
| --- | --- |
| Dart 格式与静态检查 | 已通过，`flutter analyze` 无问题 |
| 业务测试 | 5 项通过：组合筛选/排序、按日与按月计价、数据重启恢复、无效 JSON 回退、订单快照序列化 |
| Android 完整流程 | 已通过：登录 → 搜索 → 收藏 → 房源详情 → 日期 → 联系资料 → 付款方式 → 确认 → 错误 PIN 拦截 → 正确 PIN → 凭证 |
| 消息与主题 | 本地消息发送、深色主题切换已通过 |
| 页面布局 | 覆盖 55 个页面（54 个命名路由与启动页）的浅色窄屏和深色常规屏检查，并验证登录表单错误提示；银行卡预览窄屏调整后，浅色/深色及登录回归通过 |
| 运行截图 | 116 张 PNG：每种主题 55 个页面加 3 个弹层（收藏排序、分享、退出登录） |
| 图片检查 | PNG 可读取，全部为 428 × 926；已人工查看首页、详情、筛选、地图、聊天、个人中心、日历、汇总和凭证 |
| Release 安装包 | 构建成功，约 60.7 MiB；已安装启动，并验证进入演示首页后强制退出、重新打开可恢复会话 |

截图使用测试预置的演示资料、收藏与订单，用于呈现完整页面。图片来自真实 Flutter 控件运行结果；原稿导出图保存在 `docs/design`，运行截图保存在 `docs/screenshots`。

发布包模拟器运行视图：[release-home.png](testing/release-home.png)。完整截图清单见 [验证数据](testing/screenshot-validation.json)。

## 复现命令

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed lib test integration_test test_driver
flutter analyze
flutter test

# 设备 ID 请使用 flutter devices 查询
$env:BETA_DEVICE_ID = "emulator-5556"
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart -d emulator-5556
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screen_layout_test.dart -d emulator-5556
```

截图驱动在本机回环地址使用临时端口 9742，并通过 ADB 转发逐张保存图片，测试结束关闭。该能力只在测试代码中使用，正式应用入口不会启动截图服务。

只复测指定布局页面：

```powershell
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/screen_layout_test.dart --dart-define=LAYOUT_ROUTES=/add-card -d emulator-5556
```

只刷新指定页面的两种主题截图：

```powershell
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart --dart-define=CAPTURE_ONLY=true "--dart-define=CAPTURE_ROUTES=/receipt,/summary" -d emulator-5556
```

## 运行范围

- Android 应用与交互已在模拟器运行；iOS 和 Web 提供工程入口，本次没有完成对应平台的发布验收。
- 本机 Windows 的 `flutter_tester` 在加载 PNG 的独立探针中异常退出，因此带图片的界面巡检使用 Android 设备驱动执行；业务单元测试可正常在主机执行。
- 登录、验证码、PIN、支付、聊天、通话、地图与安全设置为本地演示逻辑。没有真实扣款、房产交易、GPS 请求或对外通信。
- 默认保留设计稿英文。语言设置保存偏好，不等同于已提供完整翻译。
- Android 演示安装包采用开发签名，不是应用商店发布包。
