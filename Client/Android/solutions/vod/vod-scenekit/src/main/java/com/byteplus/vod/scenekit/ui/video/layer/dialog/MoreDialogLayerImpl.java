// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0


package com.byteplus.vod.scenekit.ui.video.layer.dialog;

import android.animation.Animator;
import android.animation.AnimatorListenerAdapter;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.DrawableRes;
import androidx.annotation.NonNull;
import androidx.annotation.StringRes;
import androidx.core.content.res.ResourcesCompat;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.byteplus.playerkit.player.Player;
import com.byteplus.playerkit.player.PlayerEvent;
import com.byteplus.playerkit.player.event.ActionSetLooping;
import com.byteplus.playerkit.player.playback.DisplayModeHelper;
import com.byteplus.playerkit.player.playback.PlaybackController;
import com.byteplus.playerkit.player.playback.VideoView;
import com.byteplus.playerkit.utils.event.Dispatcher;
import com.byteplus.playerkit.utils.event.Event;
import com.byteplus.vod.scenekit.R;
import com.byteplus.vod.scenekit.VideoSettings;
import com.byteplus.vod.scenekit.ui.video.layer.GestureLayer;
import com.byteplus.vod.scenekit.ui.video.layer.Layers;
import com.byteplus.vod.scenekit.ui.video.scene.PlayScene;
import com.byteplus.vod.scenekit.utils.UIUtils;
import com.byteplus.vod.settingskit.Option;

import java.util.ArrayList;
import java.util.List;


public class MoreDialogLayerImpl extends MoreDialogLayer {
 
    private RecyclerView mGridView;
    private Adapter mAdapter;

    private TextView mLoop;
    private TextView mNoLoop;

    @Override
    public String tag() {
        return "more_dialog";
    }

    @Override
    protected View createDialogView(@NonNull ViewGroup parent) {
        final View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_more_dialog_layer, parent, false);
        mGridView = view.findViewById(R.id.recyclerView);
        mGridView.setLayoutManager(new GridLayoutManager(parent.getContext(), 5));
        mAdapter = new Adapter() {
            @NonNull
            @Override
            public ItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
                ItemViewHolder holder = super.onCreateViewHolder(parent, viewType);
                holder.itemView.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                        int position = holder.getBindingAdapterPosition();
                        Item item = getItem(position);
                        switch (item.type) {
                            case Item.RENDER_FULLSCREEN:
                                toggleDisplayMode();
                                break;
                            case Item.SUPER_RES:
                                toggleSuperResolution(holder, position, item);
                                break;
                            default:
                                Toast.makeText(context(), v.getResources().getString(item.title) +
                                        " is not impl yet!", Toast.LENGTH_SHORT).show();
                                break;
                        }
                    }
                });
                return holder;
            }
        };

        mAdapter.setList(createItems(parent.getContext()));
        mGridView.setAdapter(mAdapter);

        mLoop = view.findViewById(R.id.loop);
        mNoLoop = view.findViewById(R.id.noLoop);

        mLoop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setLoop(true);
            }
        });
        mNoLoop.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setLoop(false);
            }
        });

        view.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                animateDismiss();
            }
        });

        setAnimateDismissListener(new AnimatorListenerAdapter() {
            @Override
            public void onAnimationEnd(Animator animation) {
                GestureLayer layer = layerHost().findLayer(GestureLayer.class);
                if (layer != null) {
                    layer.showController();
                }
            }
        });
        return view;
    }

    @Override
    public boolean onBackPressed() {
        return super.onBackPressed();
    }

    @Override
    public void show() {
        super.show();
        syncViewLoopState();
    }

    @Override
    public void onVideoViewPlaySceneChanged(int fromScene, int toScene) {
        if (!PlayScene.isFullScreenMode(playScene())) {
            dismiss();
        }
    }

    public void setLoop(boolean loop) {
        final Player player = player();
        if (player == null || !player.isInPlaybackState()) {
            return;
        }
        player.setLooping(loop);
    }

    public void setViewLoop(boolean loop) {
        if (isShowing()) {
            mLoop.setSelected(loop);
            mNoLoop.setSelected(!loop);
        }
    }

    private void syncViewLoopState() {
        final Player player = player();
        if (player == null || !player.isInPlaybackState()) {
            return;
        }
        setViewLoop(player.isLooping());
    }

    @Override
    protected void onBindPlaybackController(@NonNull PlaybackController controller) {
        controller.addPlaybackListener(mPlaybackListener);
    }

    @Override
    protected void onUnbindPlaybackController(@NonNull PlaybackController controller) {
        controller.removePlaybackListener(mPlaybackListener);
    }

    final Dispatcher.EventListener mPlaybackListener = new Dispatcher.EventListener() {
        @Override
        public void onEvent(Event event) {
            switch (event.code()) {
                case PlayerEvent.Action.SET_LOOPING:
                    setViewLoop(event.cast(ActionSetLooping.class).isLooping);
                    break;
            }
        }
    };

    @Override
    protected int backPressedPriority() {
        return Layers.BackPriority.MORE_DIALOG_LAYER_BACK_PRIORITY;
    }

    private void toggleDisplayMode() {
        VideoView videoView = videoView();
        if (videoView != null) {
            int displayMode = videoView.getDisplayMode();
            if (displayMode == DisplayModeHelper.DISPLAY_MODE_ASPECT_FIT) {
                videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FILL);
            } else {
                videoView.setDisplayMode(DisplayModeHelper.DISPLAY_MODE_ASPECT_FIT);
            }
        }
    }

    private void toggleSuperResolution(Adapter.ItemViewHolder holder, int position, Item item) {
        Player player = player();
        if (player != null) {
            item.selected = !item.selected;
            player.setSuperResolutionEnabled(item.selected);
        }
        holder.image.setSelected(item.selected);
        holder.text.setSelected(item.selected);

        // change global options
        Option superResOption = VideoSettings.option(VideoSettings.COMMON_SUPER_RESOLUTION);
        superResOption.userValues().saveValue(superResOption, item.selected);
    }

    private List<Item> createItems(Context context) {
        List<Item> items = new ArrayList<>();
        items.add(new Item(Item.SHARE, R.string.vevod_more_dialog_item_share, R.drawable.vevod_more_dialog_layer_share_ic, false));
        items.add(new Item(Item.COLLECT, R.string.vevod_more_dialog_item_collect, R.drawable.vevod_more_dialog_layer_collect_ic_selecor, false));
        items.add(new Item(Item.DOWNLOAD, R.string.vevod_more_dialog_item_download, R.drawable.vevod_more_dialog_layer_download_ic_selector, false));
        items.add(new Item(Item.DANMAKU_CONFIG, R.string.vevod_more_dialog_item_danmaku, R.drawable.vevod_more_dialog_layer_danmaku_setting_ic, false));
        items.add(new Item(Item.RENDER_FULLSCREEN, R.string.vevod_more_dialog_item_full_width, R.drawable.vevod_more_dialog_layer_fullwidth_ic_selector, false));
        items.add(new Item(Item.PURE_AUDIO_MODE, R.string.vevod_more_dialog_item_audio_mode, R.drawable.vevod_more_dialog_layer_audio_mode_ic_selector, false));
        items.add(new Item(Item.BACKGROUND, R.string.vevod_more_dialog_item_play_background, R.drawable.vevod_more_dialog_layer_play_background_ic_selector, false));
        items.add(new Item(Item.TIMER, R.string.vevod_more_dialog_item_timer, R.drawable.vevod_more_dialog_layer_timer_ic_selector, false));
        items.add(new Item(Item.ASSIST_FUNC, R.string.vevod_more_dialog_item_assist_func, R.drawable.vevod_more_dialog_layer_assist_func_ic, false));
        items.add(new Item(Item.NOT_INTERESTED, R.string.vevod_more_dialog_item_not_interested, R.drawable.vevod_more_dialog_layer_not_interested_ic, false));
        items.add(new Item(Item.FEED_BACK, R.string.vevod_more_dialog_item_feedback, R.drawable.vevod_more_dialog_layer_feedback_ic, false));
        items.add(new Item(Item.REPORT, R.string.vevod_more_dialog_item_report, R.drawable.vevod_more_dialog_layer_report_ic, false));

        items.add(new Item(Item.SUPER_RES,
                R.string.vevod_more_dialog_item_super_res,
                R.drawable.vevod_more_dialog_layer_super_res_selector,
                VideoSettings.booleanValue(VideoSettings.COMMON_SUPER_RESOLUTION)));
        return items;
    }

    static class Item {
        static final int SHARE = 0;
        static final int COLLECT = 1;
        static final int DOWNLOAD = 2;
        static final int DANMAKU_CONFIG = 3;
        static final int RENDER_FULLSCREEN = 4;
        static final int PURE_AUDIO_MODE = 5;
        static final int BACKGROUND = 6;
        static final int TIMER = 7;
        static final int ASSIST_FUNC = 8;
        static final int NOT_INTERESTED = 9;
        static final int FEED_BACK = 10;
        static final int REPORT = 11;
        static final int SUPER_RES = 12;

        int type;
        @StringRes
        int title;
        @DrawableRes
        int iconResId;
        boolean selected;

        public Item(int type, @StringRes int title, @DrawableRes int iconResId, boolean selected) {
            this.type = type;
            this.title = title;
            this.iconResId = iconResId;
            this.selected = selected;
        }
    }

    static class Adapter extends RecyclerView.Adapter<Adapter.ItemViewHolder> {

        private final List<Item> mItems = new ArrayList<>();

        public void setList(List<Item> items) {
            mItems.clear();
            mItems.addAll(items);
            notifyDataSetChanged();
        }

        @NonNull
        @Override
        public ItemViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            View view = LayoutInflater.from(parent.getContext()).inflate(R.layout.vevod_more_dialog_layer_item, parent, false);
            return new ItemViewHolder(view);
        }

        @Override
        public void onBindViewHolder(@NonNull ItemViewHolder holder, int position) {
            Item item = getItem(position);
            holder.bind(item);
            int row = position / 5;

            ViewGroup.MarginLayoutParams lp = (ViewGroup.MarginLayoutParams) holder.itemView.getLayoutParams();
            lp.topMargin = row == 0 ? 0 : (int) UIUtils.dip2Px(holder.itemView.getContext(), 16);

            holder.image.setSelected(item.selected);
            holder.text.setSelected(item.selected);
        }


        @Override
        public int getItemCount() {
            return mItems.size();
        }

        public Item getItem(int position) {
            return mItems.get(position);
        }

        static class ItemViewHolder extends RecyclerView.ViewHolder {
            ImageView image;
            TextView text;

            public ItemViewHolder(@NonNull View itemView) {
                super(itemView);
                image = itemView.findViewById(R.id.image);
                text = itemView.findViewById(R.id.text);
            }

            public void bind(Item item) {
                image.setImageDrawable(ResourcesCompat.getDrawable(itemView.getResources(), item.iconResId, null));
                text.setText(item.title);
            }
        }
    }
}
