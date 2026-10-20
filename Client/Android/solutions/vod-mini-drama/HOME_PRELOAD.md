# Theater home preloading

The home page selects the first nine distinct dramas in section order (carousel,
trending, new, recommend) and preloads one playable entry episode per drama.
Each task requests **200 KiB (204800 bytes)**. Scrolling does not change this list.
Wi-Fi and cellular use the same parameters; the SDK schedules the downloads.

`DramaHomePreloader` submits the tasks after the home response arrives. If the
server supplies a usable `entry_episode`, it uses that episode and its resume
position. Otherwise this demo calls `getDramaList` for each selected drama and
uses the first unlocked, authorized episode. A customer backend should return
entry episodes in the home response to avoid these extra requests.

On tap or when the home page leaves the foreground, home tasks and outstanding
entry requests stop. Downloaded cache remains available. The detail page uses
its existing `MiniDramaVideoStrategy` for following-episode preloading and
pre-rendering; it does not inherit a nine-video home configuration.

## Manual verification

1. Use a configured debug build with a valid VOD app ID/license and a home
   response containing at least nine different playable dramas.
2. Clear the **video cache** in settings, then cold-start and open Short Drama
   → Theater. Start recording before opening Theater. Stay on the home page
   until tasks finish; do not play a video during this measurement.
3. Record logs:

   ```sh
   adb logcat -v threadtime Player_Kit:V '*:S' > home-preload.log
   ```

4. Find `DramaHomePreloader` messages:

   - `event=batch selected=9 target=9 preloadBytes=204800`
   - Nine `event=submit` messages, indexes 1–9 and nine distinct `mediaId` values.
   - Nine `event=finished` messages for those IDs. A submit message alone does
     not prove that a download completed. `skip`, `error`, or `stopped` requires
     investigation and must not be counted as a successful preload.

5. Match each ID to `VolcCacheTask` `preloadVid ... success` logs. Verify
   `preloadSize -> 204800`, then record the actual `cachedSize` and `cacheKey`.
   For a file smaller than the target, downloading the entire file is sufficient.
   Scroll without refreshing: no additional home batch should be submitted.
6. Tap a drama. Home tasks stop; detail logs should enable the existing scene
   strategy and, when available, report pre-render/cache reuse.

For packet capture, group **media response bodies** by the nine IDs/cache keys
from the logs. Exclude cover images, home/episode JSON, GetPlayInfo, playlists,
headers and retries from the media-body comparison. An MP4 may use multiple
Range requests; count the bytes actually received, not the declared file size.
An HLS video may request a playlist, initialization data and several segments;
count videos, not HTTP requests. SDK chunking and complete segments can make
actual traffic exceed the configured target. The target is not a strict cap on
wire traffic, and a single `Content-Length` does not prove how much was received.

The meeting's setting is 200 KiB, not 300 KiB. If testing a separately changed
300 KiB build, its expected target is 307200 bytes; this branch uses 204800.

Customers with longer feeds can select new nearby entries while scrolling and
cancel obsolete tasks. This demo intentionally keeps a fixed home list.
