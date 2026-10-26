> 中文 · [English](./README.md)

# Video One RN

基于 BytePlus ReactNative 视频 SDK 构建的 React Native 视频流媒体应用，提供短剧场景开发的最佳实践。

## 📱 项目概述

Video One RN 是一款移动应用，基于 [BytePlus ReactNative 点播 SDK](https://docs.byteplus.com/en/docs/byteplus-vod/docs-rn-player-quickstart) 开发的短剧场景播放应用，包含完整的视频播放、用户交互功能、通过广告解锁的能力，以及 **投屏**（Android 使用 Google Cast，iOS 使用 AirPlay）。

## 🚀 快速开始

### 环境要求

- Node.js >= 18.0.0
- Yarn（推荐）或 npm
- Expo CLI（`npx expo`）
- Xcode（iOS）/ Android Studio（Android）
- 与 Chromecast / AirPlay 接收端处于 **同一 Wi‑Fi** 的真机（投屏功能需在真机上验证）

### 安装步骤

1. **克隆仓库**

   ```bash
   git clone <repository-url>
   cd video-one-rn
   ```

2. **安装依赖**

   ```bash
   yarn install
   ```

3. **生成原生工程**（首次运行或原生依赖变更后）

   ```bash
   yarn prebuild
   cd ios && pod install && cd ..
   ```

4. **启动开发服务器**

   ```bash
   yarn start
   ```

5. **在设备或模拟器上运行**

   ```bash
   # iOS（建议使用真机验证 AirPlay）
   yarn ios

   # Android（自动配置 Gradle 所需的 node.binary）
   yarn android
   ```

## 📁 项目结构

```
video-one-rn/
├── app/                    # 应用页面 (Expo Router)
│   ├── _layout.tsx         # 根布局
│   ├── index.tsx           # 首页
│   ├── drama_channel.tsx   # 剧集频道页
│   ├── drama_player.tsx    # 视频播放页
│   └── +not-found.tsx      # 404页面
├── components/             # 可复用组件
│   ├── player/             # 视频播放器组件
│   │   ├── VideoPlayer.tsx      # 主视频播放器（投屏时暂停/恢复本地播放）
│   │   ├── EpisodePlayer.tsx    # 剧集播放器包装器（投屏按钮与遮罩）
│   │   ├── PlaybackControls.tsx # 播放控制组件
│   │   └── index.ts
│   ├── cast/               # 投屏（Cast / AirPlay）
│   │   ├── CastButton.tsx           # 平台投屏入口
│   │   ├── CastActiveOverlay.tsx    # 投屏中全屏遮罩
│   │   ├── CastStatusBar.tsx        # 投屏状态条
│   │   ├── AirPlayRelay.ts          # iOS AirPlay 原生桥接
│   │   └── AirPlayRoutePickerView.tsx
│   ├── modals/             # 模态框组件
│   │   ├── EpisodeSelectorModal.tsx  # 剧集选择模态框
│   │   ├── VipUnlockModal.tsx        # VIP解锁模态框
│   │   ├── UnlockMultipleModal.tsx   # 批量解锁模态框
│   │   └── index.ts
│   ├── feed/               # 内容流组件
│   │   ├── FeedCard.tsx              # 内容卡片
│   │   ├── FeedInfoPanel.tsx         # 内容信息面板
│   │   ├── RecommendationOverlay.tsx # 推荐覆盖层
│   │   └── index.ts
│   ├── ui/                 # UI组件
│   │   ├── AdComponent.tsx              # 广告组件
│   │   ├── LikeButton.tsx               # 点赞按钮
│   │   ├── EpisodeSelector.tsx          # 剧集选择器
│   │   ├── PlaybackSpeedSelector.tsx    # 播放速度选择器
│   │   ├── LandscapeEpisodeSelector.tsx # 横屏剧集选择器
│   │   ├── LandscapeQualitySelector.tsx # 横屏画质选择器
│   │   ├── LandscapeSpeedSelector.tsx   # 横屏速度选择器
│   │   ├── HomeCard.tsx                 # 首页卡片
│   │   └── index.ts
│   ├── shared/             # 共享组件
│   │   ├── ThemedText.tsx     # 主题文本组件
│   │   ├── ThemedView.tsx     # 主题视图组件
│   │   ├── UserAvatar.tsx     # 用户头像组件
│   │   └── index.ts
│   ├── drama/              # 剧集相关组件
│   │   ├── DramaCarousel.tsx  # 剧集轮播
│   │   ├── DramaCover.tsx     # 剧集封面
│   │   ├── DramaList.tsx      # 剧集列表
│   │   └── index.ts
│   └── index.ts            # 组件统一导出
├── services/               # API服务
│   ├── api.ts              # 基础API客户端
│   ├── dramaService.ts     # 剧集数据服务
│   ├── unlockService.ts    # 内容解锁服务
│   └── userService.ts      # 用户管理服务
├── hooks/                  # 自定义React钩子
│   ├── useCast.ts          # 统一 Cast / AirPlay 钩子
│   ├── useColorScheme.ts   # 颜色主题钩子
│   ├── useDramaChannel.ts  # 剧集频道钩子
│   └── useThemeColor.ts    # 主题颜色钩子
├── utils/                  # 工具函数
│   ├── apiTestUtils.ts     # API测试工具
│   ├── dramaUtils.ts       # 剧集相关工具
│   ├── imageUtils.ts       # 图片处理工具
│   └── playerConfig.ts     # 播放器配置工具
├── types/                  # TypeScript类型定义
│   └── drama.ts            # 剧集相关类型
├── constants/              # 应用常量
│   ├── Colors.ts           # 颜色定义
│   └── HomeConstants.ts    # 首页常量
├── assets/                 # 静态资源
│   ├── images/             # 图片和图标
│   │   ├── home/           # 首页相关图片
│   │   │   ├── 2x/         # 2倍分辨率图片
│   │   │   ├── 3x/         # 3倍分辨率图片
│   │   │   └── poster/     # 海报图片
│   │   └── ...             # 其他通用图片
│   ├── fonts/              # 自定义字体
│   │   └── SpaceMono-Regular.ttf
│   ├── minidrama/          # 剧集特定资源
│   │   ├── avatars/        # 用户头像 (20个文件)
│   │   ├── common/         # 通用图标和图片
│   │   │   ├── 2x/         # 2倍分辨率图标
│   │   │   ├── 3x/         # 3倍分辨率图标
│   │   │   └── player/     # 播放器专用图标
│   │   ├── licenses/       # 许可证文件
│   │   └── lotties/        # Lottie动画 (点赞/取消点赞)
│   └── ttsdk.lic           # SDK许可证文件
├── android/                # Android特定文件
│   ├── app/                # Android应用模块
│   │   ├── build.gradle    # 应用构建配置
│   │   └── src/main/java/.../CastOptionsProvider.kt  # Google Cast 配置
│   ├── node.gradle         # Gradle 解析 Node 路径
│   ├── build.gradle        # 项目构建配置
│   ├── gradle/             # Gradle包装器
│   ├── gradle.properties   # Gradle属性
│   ├── gradlew             # Gradle包装脚本 (Unix)
│   ├── gradlew.bat         # Gradle包装脚本 (Windows)
│   └── settings.gradle     # Gradle设置
├── ios/                    # iOS特定文件
│   ├── videoonern/         # iOS应用目标
│   │   ├── AppDelegate.swift
│   │   ├── AirPlayRelay.m              # AirPlay AVPlayer 中继
│   │   ├── AirPlayRoutePickerViewManager.m
│   │   ├── Images.xcassets/
│   │   ├── Info.plist
│   │   ├── PrivacyInfo.xcprivacy
│   │   └── SplashScreen.storyboard
│   ├── videoonern.xcodeproj/     # Xcode项目
│   ├── videoonern.xcworkspace/   # Xcode工作空间
│   ├── Podfile             # CocoaPods依赖
│   ├── Podfile.lock        # CocoaPods锁定文件
│   └── Pods/               # CocoaPods依赖包
├── plugins/                # Expo配置插件
│   ├── withLicense.js      # 许可证文件插件
│   ├── withPodfileSources.js # Podfile源配置插件
│   ├── withGoogleCast.js   # Google Cast（Android）配置插件
│   └── xcodeUtils.js       # Xcode工具
├── scripts/                # 构建和工具脚本
│   ├── reset-project.js    # 项目重置脚本
│   └── setup-android-node.sh  # 为 Android Gradle 写入 node.binary
├── babel.config.js         # Babel（Reanimated v4 需 react-native-worklets 插件）
├── metro.config.js         # Metro 打包配置
├── app.json                # Expo应用配置
├── tsconfig.json           # TypeScript配置
├── package.json            # 包配置
├── yarn.lock               # Yarn 锁文件
├── expo-env.d.ts           # Expo TypeScript类型定义
├── eslint.config.js        # ESLint配置
├── detection_tool.py       # 检测工具
├── LICENSE                 # 许可证文件
├── README.md               # 英文文档
└── README.zh_CN.md         # 中文文档
```

## 🏗️ 技术架构

### 核心技术栈

- **React Native 0.83** + **Expo SDK 55**：跨平台开发，已启用新架构（New Architecture）
- **TypeScript**: 类型安全的 JavaScript 超集
- **Expo Router**: 基于文件的路由系统，简化导航管理
- **@byteplus/react-native-vod-player**: BytePlus 点播播放 SDK
- **react-native-google-cast**（Android）：Google Cast 设备发现与远端播放
- **自定义 AirPlay 中继**（iOS）：`AVRoutePickerView` + `AVPlayer` 中继，并将进度同步回本地播放器

### 架构设计模式

1. **组件化架构**: 按功能模块组织组件，提高代码复用性

   - `player/`: 视频播放相关组件
   - `cast/`: 投屏 UI 与原生桥接
   - `modals/`: 模态框组件
   - `feed/`: 内容流组件
   - `ui/`: 通用 UI 组件
   - `shared/`: 共享组件
   - `drama/`: 剧集相关组件

2. **服务层分离**: API 服务按业务领域分离

   - `dramaService.ts`: 剧集数据管理
   - `unlockService.ts`: 内容解锁服务
   - `userService.ts`: 用户管理服务

3. **自定义钩子**: 封装可复用的业务逻辑

   - `useCast.ts`: 统一的 Cast（Android）/ AirPlay（iOS）会话与播放控制
   - `useDramaChannel.ts`: 剧集频道数据管理
   - `useColorScheme.ts`: 主题颜色管理

4. **类型安全**: 全面的 TypeScript 类型定义
   - 完整的接口定义
   - 严格的类型检查
   - 良好的开发体验

## 🎯 功能特性

### 🎬 视频播放功能

- **高质量视频流**: 支持多种画质选择 (720p, 480p 等)
- **播放控制**: 播放/暂停、进度条、音量控制
- **多倍速播放**: 支持 0.5x 到 2.0x 的播放速度
- **横竖屏切换**: 自动适配屏幕方向，提供不同的控制界面
- **进度管理**: 支持拖拽跳转、记忆播放位置
- **视频缓存**: 支持视频预加载自动策略

### 📺 投屏功能

- **Android — Google Cast**：在局域网发现 Chromecast / Cast 设备，将当前剧集 URL 推送到默认接收端（`CC1AD845`），投屏期间暂停本地播放
- **iOS — AirPlay**：系统路由选择器（`AVRoutePickerView`）+ 原生 `AirPlayRelay`，在 AirPlay 目标上播放并回传进度，便于结束投屏后从本地继续
- **投屏 UI**：播放器内的 `CastButton`、投屏中的 `CastActiveOverlay`、可选的 `CastStatusBar`
- **切集**：投屏过程中切换剧集时，Android 可通过 `updateCastMedia` 更新远端片源

### 👥 用户交互功能

- **点赞系统**: 支持点赞/取消点赞，实时更新计数
- **评论功能**: 用户评论和互动
- **触觉反馈**: 提供触觉反馈增强用户体验

### 💰 变现功能

- **广告解锁**: 观看广告解锁付费内容
- **VIP 订阅**: 付费解锁所有内容
- **批量解锁**: 一次性解锁多集内容

### 📱 内容管理

- **剧集轮播**: 首页剧集推荐轮播
- **内容列表**: 分类展示剧集内容
- **推荐系统**: 基于用户行为的智能推荐

## 🔧 开发指南

### 可用脚本命令

```bash
# 开发
yarn start              # 启动 Expo 开发服务器（清缓存）
yarn prebuild           # 重新生成 android/、ios/（expo prebuild --clean）
yarn android            # 配置 node.binary 并在 Android 上运行
yarn ios                # 在 iOS 真机上运行

# 发布构建
yarn android:release    # 构建 Android Release
yarn ios:release          # 在真机上运行 iOS Release
yarn ios:archive        # Xcode Archive（Release, iphoneos）

# 代码质量
yarn lint               # 运行 ESLint

# 项目维护
yarn reset-project      # 重置项目结构
```

### 开发环境配置

1. **配置开发环境**

   - iOS: Xcode、CocoaPods（在 `ios/` 下执行 `pod install`）
   - Android: Android Studio、JDK 17+，确保 `node` 在 `PATH` 中（或设置 `NODE_BINARY`）

2. **启动项目**
   ```bash
   yarn start
   ```

3. **插件或 SDK 变更后重建原生工程**
   ```bash
   yarn prebuild
   cd ios && pod install && cd ..
   ```

## 📱 平台支持

- **iOS**: 支持 iOS 11.0 及以上版本
- **Android**: 支持 Android API level 23 及以上版本

## 🔐 配置说明

### 环境变量配置

1. **API 配置**: 在 `services/api.ts` 中配置 API 端点

   ```typescript
   const API_BASE_URL = "https://your-api-domain.com";
   ```

2. **视频播放器配置**: 配置视频播放器相关参数

   ```typescript
   // 在VideoPlayer组件中配置播放器参数
   ```

3. **变现配置**: 配置广告和支付相关参数
   ```typescript
   // 在unlockService中配置解锁参数
   ```

### 投屏配置

投屏通过 Expo Config Plugin 与原生模块接入，默认配置即可使用。

| 平台 | 方案 | 关键文件 |
| ---- | ---- | -------- |
| Android | `react-native-google-cast` | `plugins/withGoogleCast.js`、`CastOptionsProvider.kt` |
| iOS | AirPlay 路由选择器 + `AirPlayRelay` | `ios/videoonern/AirPlayRelay.m`、`app.json` → `ios.infoPlist` |

**Android Cast 接收端 App ID** — 修改 `android/app/src/main/java/com/byteplus/videoone/rn/CastOptionsProvider.kt` 中的 `CAST_APP_ID`。默认 `CC1AD845` 为 Google 官方媒体接收端，无需单独注册。

**iOS 本地网络权限** — `app.json` 中已配置 `NSLocalNetworkUsageDescription` 与 Bonjour 服务（`_airplay._tcp`、`_googlecast._tcp`、`_CC1AD845._googlecast._tcp`），用于在局域网发现投屏设备。

**Gradle 与 Node** — 执行 `yarn android` 时会运行 `scripts/setup-android-node.sh`，向 `android/local.properties` 写入 `node.binary`，供 Gradle 与 Android Studio 使用。

### 构建配置

- **iOS 配置**: 在 `ios/` 目录中配置 iOS 特定设置
- **Android 配置**: 在 `android/` 目录中配置 Android 特定设置
- **Expo 配置**: 在 `app.json` 中配置 Expo 相关设置

## 🚀 部署指南

### 开发环境部署

1. **本地开发**

   ```bash
   npm start
   ```

2. **真机调试**
   - 安装 Expo Go 应用
   - 扫描二维码连接开发服务器

### 生产环境部署

1. **构建应用**

   ```bash
   expo build:android
   expo build:ios
   ```

## 📄 许可证

本项目采用 MIT 许可证。详情请参阅 [LICENSE](LICENSE) 文件。

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request 来改进项目。

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📞 联系方式

如有问题或建议，请通过以下方式联系：

- 提交 Issue: [GitHub Issues](https://github.com/your-repo/issues)
- 邮箱: your-email@example.com

---

**注意**: 本项目仅供学习和研究使用，请遵守相关法律法规。
