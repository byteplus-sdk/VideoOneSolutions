# Home startup warmup / 首页单次预渲染

Demo 默认开启。首次进入短剧 Home，首屏真实卡片绘制、播放器工厂和授权就绪后，选择第一个解析成功且仍可见的可播入口，从 0 离屏 prepare 一次；加载占位不触发，不一定选择列表第一个 item。复用首页已有入口解析，不新增详情接口。

每个播放进程最多一次额外预热。开始前消耗机会，成功、失败、取消、刷新、返回和 Activity 重建都不重试；只有进程重启重新获得机会。即使首页数据预加载选择 ADAPTIVE，额外预渲染也仅在所有可见列表静止时开始。

收到 `VIDEO_RENDERING_START_BEFORE_START` 才算离屏首帧就绪，并立即释放；`PREPARED` 不算完成。没有声音、隐藏 Activity 或轮询，不放入全局 PlayerPool。私有媒体源和临时进度 key 避免覆盖真实续播。开始滚动、候选离屏、刷新、切页、退后台、销毁或修改配置时取消；真实播放优先。异步等待超时为 5 秒，不会中断已经执行中的同步 JNI。

预热期间暂停首页媒体预加载，结束后按当前可见窗口恢复。prepare 流量不受首页 300 KiB 或详情 500 KiB 的数据预加载预算限制。一次预热可以提前经过 so/解码器准备链路；不承诺固定首帧收益，也不将这个已释放实例计为详情预渲染命中。

## Direct Explore / 直接进入 Explore

VideoOne 的 For you 对应 Explore。默认进入 Home；显式路由到 Explore：

```java
Intent intent = new Intent(context, DramaMainActivity.class);
intent.putExtra(DramaMainActivity.EXTRA_INITIAL_TAB, DramaMainActivity.TAB_EXPLORE);
context.startActivity(intent);
```

未传、null、空串和未知值均进入 Home；Activity 重建保留当前 Tab。

直接 Explore 在创建页面前关闭额外首页预热，首条走正常播放完成初始化。**不要再给同一首条增加独立 prepare，也不要随后补做 Home 预热。** 正常“当前播放、下一集预渲染、后五集预加载”仍随翻页更新；这里的“只一次”仅指进程启动预热，不是整个会话只准预渲染一个后续剧集。

## Configuration / 配置

无新增设置页或云控。默认无需调用 API；A/B 关闭时在主线程、进入 Home 前调用：

```java
DramaSettings.enableTheaterStartupWarmup(false);
```

运行中关闭会取消，重新打开不恢复已经消耗的机会。首页入口预加载关闭时也不开始首页预热。

日志标签 `startupWarmup`：Home 最多一次 `start=home`；成功后 `finish=frameReady`，取消/失败记录对应原因及耗时；直接 Explore 为 `normalPlayback=initialExplore`，不出现额外 `start=home`。正常下一集使用 `detailWindow` 日志。

生产接入仍需适配入口集、授权、付费权限与续播协议，详见 [首页预加载说明](HOME_PRELOAD.md)。默认 `DEMO_PER_DRAMA` 逐剧补查只供演示；没有新增后端聚合接口。

## English quick reference

Enabled by default. Home prepares one resolved, visible, playable entry after real cards draw, the player factory and license are ready, and all visible lists are idle. The attempt is consumed before player creation and never retried in that playback process. Release after a real offscreen first frame, error, cancellation, or a 5-second asynchronous timeout; preserve business resume progress.

Direct Explore uses `drama_initial_tab="explore"` and initializes through normal playback of the first item. Do not add a separate startup prepare for that item or a later Home warmup. Normal next-episode prerendering and five-item media preloading continue as the current item changes. Actual cold-start gains require an A/B test on target devices and media.
