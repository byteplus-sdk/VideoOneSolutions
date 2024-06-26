
- 符合UI要求的view使用方法，直接copy即可
<com.vertcdemo.solution.chorus.view.LrcView
        android:id="@+id/lrc_view"
        android:layout_width="match_parent"
        android:layout_height="match_parent"
        app:lrcTextSize="16sp"
        app:lrcNormalTextSize="10sp"
        app:lrcCurrentTextColor="#DB74D9"
        app:lrcNormalTextColor="#FFFFFF"
        app:lrcDividerHeight="12dp"/>

 - 调用时加载歌词：
    mLrcView.loadLrc(new File(path));

 - 更新歌词时间：
    mLrcView.updateTime()

 - 其他方法属性，参考：https://github.com/wangchenyan/lrcview
