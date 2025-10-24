> 中文 · [English](./README.md)

# Video One RN

基于 BytePlus ReactNative SDK 构建的 React Native 视频流媒体应用，提供短剧场景开发的最佳实践。

## 📱 项目概述

Video One RN 是一款移动应用，基于 [BytePlus ReactNative 点播 SDK](https://docs.byteplus.com/en/docs/byteplus-vod/docs-rn-player-quickstart) 开发的短剧场景播放应用，包含完整的视频播放、用户交互功能和通过广告解锁的能力。

## 🚀 快速开始

### 环境要求

- Node.js >= 18.0.0
- npm 或 yarn
- Expo CLI
- iOS 模拟器 (iOS 开发)
- Android Studio (Android 开发)

### 安装步骤

1. **克隆仓库**

   ```bash
   git clone <repository-url>
   cd video-one-rn
   ```

2. **安装依赖**

   ```bash
   npm install
   # 或
   yarn install
   ```

3. **启动开发服务器**

   ```bash
   npm start
   # 或
   yarn start
   ```

4. **在特定平台运行**

   ```bash
   # iOS
   npm run ios

   # Android
   npm run android
   ```

## 📁 项目结构

```
Client/ReactNative/
├── app/                    # 应用页面 (Expo Router)
│   ├── _layout.tsx         # 根布局
│   ├── index.tsx           # 首页
│   ├── drama_channel.tsx   # 剧集频道页
│   ├── drama_player.tsx    # 视频播放页
│   └── +not-found.tsx      # 404页面
├── components/             # 可复用组件
│   ├── player/             # 视频播放器组件
│   │   ├── VideoPlayer.tsx      # 主视频播放器
│   │   ├── EpisodePlayer.tsx    # 剧集播放器包装器
│   │   ├── PlaybackControls.tsx # 播放控制组件
│   │   └── index.ts
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
│   │   └── src/            # Android源代码
│   ├── build.gradle        # 项目构建配置
│   ├── gradle/             # Gradle包装器
│   ├── gradle.properties   # Gradle属性
│   ├── gradlew             # Gradle包装脚本 (Unix)
│   ├── gradlew.bat         # Gradle包装脚本 (Windows)
│   └── settings.gradle     # Gradle设置
├── ios/                    # iOS特定文件
│   ├── videoonern/         # iOS应用目标
│   │   ├── AppDelegate.swift
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
│   ├── withATSConfig.js    # ATS配置插件
│   ├── withLicense.js      # 许可证文件插件
│   ├── withPodfileSources.js # Podfile源配置插件
│   └── xcodeUtils.js       # Xcode工具
├── scripts/                # 构建和工具脚本
│   └── reset-project.js    # 项目重置脚本
├── app.json                # Expo应用配置
├── tsconfig.json           # TypeScript配置
├── package.json            # npm包配置
├── expo-env.d.ts           # Expo TypeScript类型定义
├── eslint.config.js        # ESLint配置
├── detection_tool.py       # 检测工具
├── LICENSE                 # 许可证文件
├── README.md               # 英文文档
└── README-zh_CN.md         # 中文文档
```

## 🏗️ 技术架构

### 核心技术栈

- **React Native**: 跨平台移动开发框架
- **Expo**: 开发平台和工具链，提供丰富的 API 和组件
- **TypeScript**: 类型安全的 JavaScript 超集
- **Expo Router**: 基于文件的路由系统，简化导航管理

### 架构设计模式

1. **组件化架构**: 按功能模块组织组件，提高代码复用性

   - `player/`: 视频播放相关组件
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
# 开发相关
npm start              # 启动Expo开发服务器
npm run android        # 在Android设备/模拟器上运行
npm run ios           # 在iOS设备/模拟器上运行

# 代码质量
npm run lint          # 运行ESLint代码检查

# 项目维护
npm run reset-project # 重置项目结构
```

### 开发环境配置

1. **安装 Expo CLI**

   ```bash
   npm install -g @expo/cli
   ```

2. **配置开发环境**

   - iOS: 安装 Xcode 和 iOS 模拟器
   - Android: 安装 Android Studio 和 Android SDK

3. **启动项目**
   ```bash
   npm start
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
