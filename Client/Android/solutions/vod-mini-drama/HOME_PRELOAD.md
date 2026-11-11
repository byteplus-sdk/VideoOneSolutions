# Home preload / 首页预加载

示例使用 TTSDK 1.51.200.7，沿用工程现有 BytePlus 公网 Maven。
The sample uses TTSDK 1.51.200.7 from the existing BytePlus public Maven repository.

首页先准备可见卡片，再用剩余额度准备滑动方向前方一排；后方一排只保留已有任务。
最多9个未完成任务，入口请求也计入；每项300 KiB（307200 bytes）。
完成且缓存有效的项不占下载额度。超出两侧缓冲时取消，保留磁盘缓存。
数据预加载与额外启动预热分开管理；详情 / For you 的策略单独配置。

Home prioritizes visible cards, then prepares one row ahead in the scroll direction.
The row behind only retains existing tasks. At most nine unfinished tasks share
the budget, including entry requests; each media task uses 300 KiB. Completed,
valid cache entries free capacity. Cancel beyond the buffer while retaining disk
data. Startup warmup and detail / For you are managed separately.

| Module / 模块 | Buffer / 缓冲 |
| --- | --- |
| Recommend | 前后各一排，每排2项。One row each side, two items per row. |
| Most trending | 可见模块内前后各一列，每列3项。One column each side within a visible module, three items per column. |
| New release | 可见模块内前后各1项。One item each side within a visible module. |
| Banner | 当前项先于两侧露出的卡片，再准备前方1项、保留后方1项；共用额度，不下载全部8条。Current item before peeks, then one ahead and retain one behind; shares the budget. |

按剧目去重：可见项 → 前方新任务 → 后方已有任务。未滚动时默认向列表后续方向准备。
Deduplicate by drama: visible → new ahead → existing behind. Before scrolling,
the default direction follows the remaining list.

## A/B configuration / A/B 配置

在主线程、进入首页前调用。代码配置可通过 Settings 的本地测试配置覆盖；没有云控接口。
运行中修改会取消旧窗口并重算；更换入口来源后还需刷新首页，重新请求对应协议。

Configure on the main thread before opening Home. Settings can override the code
configuration locally; there is no cloud API. Live changes rebuild the window. Refresh Home
after changing the entry source to request the corresponding protocol.

```java
// Defaults: 1000 dp/s for both drag and fling, 100ms between moving checks.
// 默认：拖动、惯性滚动共用 1000dp/s 阈值，滑动中每 100ms 合并检查。
DramaSettings.setHomePreloadConfig(HomePreloadConfig.defaults());
```

| Setting / 配置 | Default and behavior / 默认与行为 |
| --- | --- |
| maxScrollSpeedDpPerSecond | `1000`; inclusive, finite, ≥0. Zero allows idle only; unknown or faster speed blocks additions. 单一阈值，0表示仅停止后新增；未知或超速时不新增。 |
| updateIntervalMs | `100`, >0; throttle moving updates only. First visible cards and IDLE run immediately. 滑动中默认100ms节流；首屏及停止滑动后立即调度。 |
| entrySource | `DEMO_PER_DRAMA`; use `FEED_ONLY` after server integration. 默认可运行演示，服务端接入后改为仅Feed入口。 |

只修改与默认值不同的参数时使用 Builder，例如接好服务端后：
Use the builder only for overrides, e.g. after server integration:

```java
DramaSettings.setHomePreloadConfig(
        new HomePreloadConfig.Builder()
                .entrySource(HomePreloadConfig.EntrySource.FEED_ONLY)
                .build());
```

仅停止后新增的对照组设置速度为0：
Set the speed to zero for an idle-only comparison:

```java
DramaSettings.setHomePreloadConfig(
        new HomePreloadConfig.Builder()
                .maxScrollSpeedDpPerSecond(0f)
                .build());
```

每次滚动回调采样速度，窗口默认按100ms合并更新，再检查当前候选和速度。
进入IDLE取消剩余间隔等待，在下一次主线程调度更新一次；静止后不周期检测。
Sample speed on scroll callbacks and coalesce window checks every 100ms by default.
Entering IDLE cancels the remaining delay and checks on the next main-loop turn.
There is no periodic idle check. Existing and valid completed tasks remain deduplicated.

测试入口：Short Drama → Settings → Home preloading。打开本地覆盖，
输入速度（0～10000 dp/s）和滑动检查间隔（25～1000ms），点击应用。
默认输入1000dp/s、100ms，覆盖默认关闭；可独立控制首页数据预加载及首条预热。
保存后立即更新首页，重启仍保留；关闭覆盖再应用恢复代码配置。
入口来源由代码设置。旧版“仅停止”配置迁移成速度0，其余旧模式保留速度；保存后删除旧模式。

In Short Drama → Settings → Home preloading, enable the local override,
enter speed (0–10000 dp/s) and interval
(25–1000ms), then apply. Inputs default to 1000 dp/s and 100ms; the override
defaults off. Data preloads and first-video warmup have separate switches.
Apply saves locally and rebuilds Home. Disable the override and apply to restore
the code config. Entry source still comes from code. Old idle-only preferences
migrate to speed zero; other old modes keep their speed. Saving removes the old mode.

调度由布局、滚动和配置事件触发，在主线程串行执行，没有新增线程池。
滚动回调只合并任务；每轮窗口更新统一收集可见列表和候选，并在同轮准入中复用。
完成回调释放额度并触发当前窗口更新；迟到回包重新检查当前候选、请求身份与速度。
最多保留一个待执行回调；静止时不轮询。暂停/离屏时取消回调、移除布局和滚动监听、
清空窗口；重新进入时立即重算。销毁后不能重启，配置监听也随 Fragment 视图销毁移除。
配置修改及监听注册/注销必须在主线程，后台调用会立即抛出 IllegalStateException。
“立即”表示卡片可见后的主线程调度，不额外等待配置间隔；入口接口与媒体请求仍为异步。

Layout, scroll and configuration events serialize scheduling on main, with no new
thread pool and at most one pending callback. There is no idle polling. Pause/detach
cancels callbacks, removes layout/scroll observers and clears the window; re-entry
recomputes immediately. Release is terminal, and Fragment view destruction also
removes the config listener. Config changes and listener registration/removal must
run on main; worker calls throw IllegalStateException. Immediate means no extra
interval after cards become visible; entry/media requests remain asynchronous.

速度按 RecyclerView 实际消耗的距离 / 单调时间换算为 dp/s，持续采样，不用松手瞬间的初速度。
首次样本、开始滚动或超过200ms未采样时视为未知；Drag转Fling保留已有速度。
可见的根列表、横向列表和 ViewPager2 任一不满足条件都不新增；隐藏列表不参与阻塞。
滚动中继续取消超出两侧缓冲的任务。
快速滑动暂停新增，保留缓冲内的已开始任务。

Speed uses consumed RecyclerView distance and monotonic time in dp/s, not the
initial release velocity. The first sample, motion starting and gaps over 200ms
mean unknown speed; drag-to-fling keeps the sample. Every visible root/nested/ViewPager2
list must allow new work; hidden lists do not block. Cancel tasks beyond the two-sided buffer
while moving. Fast scrolling pauses additions and retains started tasks within it.

RecyclerView GapWorker 预取 ViewHolder 的创建/bind，且离屏 View 可能继续缓存；
它不执行媒体预加载。这里采集真实可见 View，不使用 onBind/onViewRecycled 作为媒体窗口，
也不无条件纳入 ViewPager2 的 currentItem。

GapWorker prefetches ViewHolder creation/binding, not media. Offscreen views can
remain cached. Use actual visibility rather than onBind/onViewRecycled or an
unconditionally included ViewPager2 currentItem.

## Server integration and demo simulation / 服务端接入与本地模拟

**VideoOne 当前 `POST drama/v1/getDramaChannel` 仅返回剧目卡片，没有 `entry_episode`。
下面是客户需实现的建议协议，不是已上线的 VideoOne 服务端能力。**
For you 的 `getDramaFeed` 另有 `video_meta`，不要与 Home 接口混淆。

**VideoOne currently returns drama cards from `POST drama/v1/getDramaChannel`,
without `entry_episode`. The following is a proposed customer extension,
not an existing VideoOne server feature.**
For you uses a different endpoint, `getDramaFeed`, with `video_meta`.

| Source / 来源 | Behavior / 行为 |
| --- | --- |
| `DEMO_PER_DRAMA` | 普通首页请求体为 `{}`。无有效入口时逐剧调用现有 `POST drama/v1/getDramaList`，取首个可播项拼 Entry；入口请求与媒体任务合计最多9个未完成，完成后继续准备窗口内其他项。不是批量接口，不保证是真实续播集。Uses `{}` for Home; missing entries trigger a full-list request per drama. Entry requests and media tasks share nine unfinished slots; completion admits remaining window items. The simulated first-playable entry is not a resume lookup or batch API. |
| `FEED_ONLY` | 仅使用有效服务端入口；缺失、null、过期、不可播时跳过，不逐剧补查。此前模拟的 Entry 不会充当服务端结果。Consumes valid server entries only; skips missing/null/expired/unplayable entries without per-drama fallback, including cached demo entries. |

两种上线方式二选一：

1. **推荐：Feed item 内嵌入口**。服务端按登录用户决定首播/续播集，一次返回入口、有效凭证、进度和权限。
2. **聚合查询**。客户新增接收一批剧目 ID 的业务接口，一次返回各剧目的同类入口信息；
   客户需实现客户端适配层并写入 `DramaInfo.entryEpisode`。本示例没有实现该聚合接口。

Production options: preferably embed entries in feed items; alternatively implement
a customer batch endpoint accepting drama IDs and returning entries, with a client
adapter filling `DramaInfo.entryEpisode`. The sample does not implement a batch endpoint.
Select resume episodes, progress, valid authorization and entitlement on the server
for the authenticated user.

`FEED_ONLY` 启用建议的首页扩展请求（需客户服务端配合）：
`include_entry_episode=true`，并携带 `user_id`、`format`、`codec`、`fileType`；
登录凭证仍通过 `X-Login-Token`。`format/codec/fileType` 沿用详情页参数。

`FEED_ONLY` opts into the proposed request extension: `include_entry_episode=true`,
`user_id`, `format`, `codec`, `fileType`, with `X-Login-Token`. Playback parameters
match the detail request. Setting these fields alone cannot add server capability.

建议响应的最小示例；`play_auth_token` 必须替换为真实有效凭证：
Minimal proposed response; replace the placeholder with valid authorization:

```json
{
  "code": 200,
  "response": {
    "recommend": [{
      "drama_id": "demo-drama",
      "entry_episode": {
        "reason": "CONTINUE_PLAY",
        "resume_position_ms": 120000,
        "auth_expire_at_ms": 0,
        "feed": {
          "drama_id": "demo-drama",
          "vid": "demo-vid",
          "order": 3,
          "play_auth_token": "<valid-play-auth-token>",
          "vip": false
        }
      }
    }]
  }
}
```

`entry_episode` 同样适用于 `loop`、`trending`、`new` 下的剧目卡片（实际分组字段见
`DramaTheaterEntity`）。`feed.vid/play_auth_token` 是非空字符串，`order` 为正整数，
`vip` 为布尔值（true 不预取）。`reason` 建议为 `FIRST_PLAY/CONTINUE_PLAY`，当前仅作元数据，
不驱动选择。`resume_position_ms`、`history_updated_at_ms`、`auth_expire_at_ms` 为长整数；
后两者用 Unix 毫秒时间。履历更新时间仅保留，不参与本示例仲裁。

The entry applies to the other channel card groups too (see `DramaTheaterEntity`
for wire names). Require nonempty string `vid/play_auth_token`, positive integer
`order`, and boolean `vip` (true blocks preload). Suggested `reason` values are
`FIRST_PLAY/CONTINUE_PLAY`; this is metadata, not a selection algorithm.
Resume position, history timestamp and auth expiry are long integers in milliseconds;
history/expiry use Unix time. History timestamp is not used to arbitrate progress here.

入口或 feed 缺失/null、vid或token缺失/null/空字符串、order缺失/≤0、vip=true 均不可播。
偏移缺失/null/负值按0；有效期缺失/null/≤0不在客户端判断过期，正值≤当前时间为过期。
未知有效期不代表凭证有效，仍需服务端保证。类型错误不属于合法协议。
请求失败、列表无可播项时跳过；同一可见窗口不会循环重试，可通过离屏重入或刷新重建。

Missing/null entries/feed, missing/null/empty VID/token, nonpositive/missing order,
or vip=true are unusable. Missing/null/negative offset becomes zero.
Missing/null/nonpositive expiry skips the app-side expiry check; a positive expiry
at or before now is expired. The server still owns credential validity.
Failed requests or lists without a playable item are skipped without an in-window
retry loop; leaving/re-entering or refreshing rebuilds candidates.

所有异步回调重新检查对象身份、当前候选和滚动准入；高速期间返回的入口先暂存，
条件恢复后再提交媒体任务。退出首页、刷新、切换配置时取消旧窗口。

Async responses recheck candidate identity, the current window and scroll admission.
Entries arriving during fast motion are retained until admission resumes.
Exit, refresh and configuration changes cancel the old window.

## Budget and offset / 预算与偏移

```java
source.putExtra(CacheLoader.Task.EXTRA_PRELOAD_SIZE_IN_BYTES, 300L * 1024L);
source.putExtra(CacheLoader.Task.EXTRA_PRELOAD_START_TIMESTAMP_MS, 120000L);
```

表示从约第120秒附近预取300 KiB，不是预加载120秒。偏移由业务提供，本通道不查询续播，
也不设置实际播放 seek。VID、URL、VideoModel 均透传到 SDK 任务；缺失/负偏移用0。
`enableTheaterResumePointPreload(false)` 仅关闭首页偏移，不改变详情页播放进度。
预算不是精确网络总流量上限，分片边界、playlist和重试都会影响流量。

This prefetches 300 KiB near 120 seconds; it does not preload 120 seconds.
Business code supplies the offset. The channel does not fetch resume data or
seek the player. VID/URL/VideoModel tasks forward the offset; missing/negative
offset means zero. Disabling home resume-point preloading does not alter detail
playback progress. Budget is not a strict wire-traffic cap due to segment boundaries,
playlists and retries.

## Cache reuse / 缓存复用

完成任务保存缓存证明，首页内存最多保留64份完成记录。入口视频、凭证、资源、起点和预算
相同且缓存仍有效时，重入跳过提交。HLS检查播放列表和分片连续字节；普通文件检查连续缓存。
缓存清除、分片淘汰或目标变化后重新提交；无法可靠检查时按正常预加载处理。

取消前下载的部分数据保留。重入会重新提交任务，由SDK复用磁盘上仍有效的数据。
完成记录不改变SDK磁盘缓存上限，也不把HLS下载百分比或文件总大小当作目标覆盖。

Home retains up to 64 completed-cache records in memory. Matching video,
authorization, resource, offset and budget skip submission only while the captured
cache remains valid. Check HLS manifests and contiguous segment bytes, or ordinary
continuous file ranges. Eviction, clearing, changed targets or unsupported checks
use normal preloading. Cancellation retains partial data; re-entry resubmits and
the SDK reuses valid disk ranges. These records do not increase the disk limit.

## Verification / 接入核验

进入 Short Drama → Home，分别测试纵向列表、Most trending、New release 和轮播。
按相同数据源做 A/B：A速度0，仅停止后新增；B速度1000，慢拖和低速Fling可新增，超速时不新增。
检查 `homeWindow` 的 `pending <= 9`、`bytes=307200`、`submit/remove/finished/reuse`；
成功日志附`downloadMs`（提交到成功回调）、`entryWaitMs`（候选到提交）和`totalMs`。
失败、取消与缓存复用不计为新下载成功。候选到提交包含入口等待及准入等待。
完成后滑出再返回应复用；清缓存后应重新提交；未完成取消后应续用有效磁盘数据。
`demoFallback=requestDramaList` 只应出现在演示补查模式。
同时比较详情接口量、媒体请求、首帧、命中率、额外流量和取消率；代码样例的速度阈值需实测调整。

Test root/nested/carousel scrolling in Short Drama → Home with the same entry source
for both groups. A uses speed zero; B uses 1000 dp/s for both drag and fling.
Check `homeWindow` pending counts, budgets and submit/remove/finished/reuse logs.
Successful completion logs include SDK submission-to-callback `downloadMs`,
candidate-to-submission `entryWaitMs`, and candidate-to-callback `totalMs`.
Failures, cancellations and reuse do not count as new successful downloads.
Verify completed reuse, invalidation after clearing, and partial-cache resumption.
`demoFallback=requestDramaList`
belongs only to demo mode. Compare detail requests, media requests, first frame,
cache hit rate, extra traffic and cancellations before choosing a speed threshold.
