# Home preload window / 首页预加载窗口

| Rule / 规则 | Behavior / 行为 |
| --- | --- |
| Candidate / 候选 | One playable entry episode per visible drama, deduplicated by drama ID. 每个可见剧目选择一个可播入口集，按剧目 ID 去重。 |
| Limit / 上限 | Up to 9 entries, including pending entry requests. 最多 9 项，包含入口信息尚未返回的候选。 |
| Budget / 预算 | 300 KiB (307200 bytes) per entry. 每项明确设置 300 KiB。 |
| Update / 更新 | Update after layout, refresh and idle scrolling, including nested lists and the carousel. 布局、刷新和停止滑动后更新，覆盖横向列表及轮播。 |
| Cancellation / 取消 | Remove offscreen entries first, retain overlaps, then add new visible entries. 先移除离屏项、保留交集，再加入新可见项。 |
| Lifecycle / 生命周期 | Stop tasks and pending entry requests when leaving Home. Keep cached data. 离开首页时取消任务及入口请求，保留磁盘缓存。 |

The window contains the actual visible cards, not the first nine items in the
server response. Fewer visible or playable cards produce a smaller window.
Home uses data preloading only; it does not prepare a player.

窗口由真实可见卡片决定，不是服务端返回列表的前九项。可见或可播数量不足时按实际数量；
首页仅预加载数据，不创建预渲染播放器。

## Entry metadata / 入口信息

When a valid `entry_episode` is available, reuse its playback credentials and
resume position. The demo falls back to a per-drama episode-list request when
entry metadata is missing. Production feeds should return entry episodes,
authorization and resume positions in one batch, adapted to business rules.

有有效 `entry_episode` 时复用其播放凭证及续播位置；缺失时 Demo 兼容逐剧查询列表。
生产首页应按业务规则批量返回入口集、鉴权和续播位置，减少完整列表请求。

`DramaHomePreloader` verifies the entry instance in asynchronous callbacks.
A response for a removed entry cannot recreate a task, even if the same drama
has since re-entered the viewport.

`DramaHomePreloader` 在异步回调中校验 Entry 对象身份，防止剧目离屏后重新入屏时，
旧响应复活已经失效的任务。

## Verification / 验证

1. Open Short Drama → Home, then scroll the vertical list, Most trending,
   New release and the carousel. 进入短剧 → 主页，分别滚动纵向、横向列表及轮播。
2. Inspect `homeWindow` logs: `count <= 9`, `bytes=307200`, `submit` for new
   entries and `remove` for obsolete ones. 检查数量、预算及新增/取消记录。
3. Stop scrolling repeatedly without changing visible items. Overlapping tasks
   must not be resubmitted. 可见项不变时，重复停止滑动不能反复提交相同任务。
4. Leave or refresh Home while entry requests are pending. No stale callback
   should add an old entry. 入口请求未完成时退出或刷新，旧回调不得补入过期项。

The budget is not an exact wire-traffic cap: playlists, segment boundaries and
retries can change observed traffic. Match media IDs, task budgets and actual
requests rather than counting HTTP requests alone.

预算不是网络总流量的精确上限；playlist、分片边界及重试会影响实际流量。
核验时同时比对媒体 ID、任务预算和真实请求，不能只数 HTTP 请求次数。
