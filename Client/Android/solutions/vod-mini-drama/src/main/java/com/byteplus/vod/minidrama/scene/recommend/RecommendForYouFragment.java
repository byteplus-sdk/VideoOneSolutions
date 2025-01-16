// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.vod.minidrama.scene.recommend;

import static com.byteplus.vod.minidrama.utils.Route.EXTRA_DRAMA_INFO;
import static com.byteplus.vod.minidrama.utils.Route.EXTRA_EPISODE_NUMBER;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.activity.result.ActivityResultLauncher;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.util.Consumer;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.byteplus.vod.minidrama.remote.model.drama.DramaFeed;
import com.byteplus.vod.minidrama.remote.model.drama.DramaInfo;
import com.byteplus.vod.minidrama.remote.model.drama.DramaRecommend;
import com.byteplus.vod.minidrama.scene.data.DramaItem;
import com.byteplus.vod.minidrama.scene.detail.DramaDetailVideoActivityResultContract;
import com.byteplus.minidrama.R;
import com.byteplus.minidrama.databinding.VevodMiniDramaRecommendForYouFragmentBinding;
import com.byteplus.minidrama.databinding.VevodMiniDramaRecommendForYouItemBinding;
import com.byteplus.vod.scenekit.utils.FormatHelper;
import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Objects;

public class RecommendForYouFragment extends BottomSheetDialogFragment {
    @Override
    public int getTheme() {
        return R.style.VeVodMiniDramaBottomSheetDark;
    }

    private RecommendForYouViewModel viewModel;

    public RecommendForYouFragment() {
        super(R.layout.vevod_mini_drama_recommend_for_you_fragment);
    }

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Bundle arguments = requireArguments();
        viewModel = new ViewModelProvider(this).get(RecommendForYouViewModel.class);
        viewModel.dramaInfo = Objects.requireNonNull((DramaInfo) arguments.getSerializable(EXTRA_DRAMA_INFO));
        viewModel.episodeNumber = arguments.getInt(EXTRA_EPISODE_NUMBER, 0);
    }

    @NonNull
    @Override
    public Dialog onCreateDialog(@Nullable Bundle savedInstanceState) {
        BottomSheetDialog dialog = (BottomSheetDialog) super.onCreateDialog(savedInstanceState);
        dialog.setOnShowListener(source -> {
            View view = dialog.findViewById(com.google.android.material.R.id.design_bottom_sheet);
            assert view != null;
            BottomSheetBehavior.from(view).setState(BottomSheetBehavior.STATE_EXPANDED);
        });
        return dialog;
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        VevodMiniDramaRecommendForYouFragmentBinding binding = VevodMiniDramaRecommendForYouFragmentBinding.bind(view);
        binding.close.setOnClickListener(v -> dismiss());

        binding.swipeRefresh.setEnabled(false);

        binding.recycler.setLayoutManager(new LinearLayoutManager(requireContext()));
        RecommendForYouAdapter adapter = new RecommendForYouAdapter(viewItem -> {
            DramaItem item = new DramaItem(viewItem.info, viewItem.item.episodeNumber);
            DramaDetailVideoActivityResultContract.Input input = new DramaDetailVideoActivityResultContract.Input(
                    Collections.singletonList(item)
            );
            mDramaDetailPageLauncher.launch(input);
            dismiss();
        });

        binding.recycler.setAdapter(adapter);
        viewModel.recommends.observe(this, items -> adapter.setItems(
                map(requireContext(), items))
        );

        viewModel.state.observe(this, state -> {
            if (state == RecommendForYouViewModel.State.INIT) {
                viewModel.load();
            } else if (state == RecommendForYouViewModel.State.LOADING) {
                binding.swipeRefresh.setRefreshing(true);
            } else if (state == RecommendForYouViewModel.State.LOADED
                    || state == RecommendForYouViewModel.State.ERROR) {
                binding.swipeRefresh.setRefreshing(false);
            }
        });
    }

    public ActivityResultLauncher<DramaDetailVideoActivityResultContract.Input> mDramaDetailPageLauncher
            = registerForActivityResult(new DramaDetailVideoActivityResultContract(), result -> {
    });

    static class RecommendForYouAdapter extends RecyclerView.Adapter<RecommendForYouHolder> {

        private List<RenderItem> items = Collections.emptyList();
        private final Consumer<RenderItem> mOnClickListener;

        RecommendForYouAdapter(Consumer<RenderItem> onClickListener) {
            mOnClickListener = onClickListener;
        }

        @NonNull
        @Override
        public RecommendForYouHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
            LayoutInflater inflater = LayoutInflater.from(parent.getContext());
            VevodMiniDramaRecommendForYouItemBinding binding =
                    VevodMiniDramaRecommendForYouItemBinding.inflate(inflater, parent, false);
            return new RecommendForYouHolder(binding);
        }

        @Override
        public void onBindViewHolder(@NonNull RecommendForYouHolder holder, int position) {
            VevodMiniDramaRecommendForYouItemBinding binding = holder.binding;
            RenderItem item = items.get(position);

            binding.getRoot().setSelected(item.isSelected);

            Glide.with(binding.cover)
                    .load(item.coverUrl)
                    .centerCrop()
                    .into(binding.cover);

            binding.description.setText(item.description);
            binding.duration.setText(item.durationText);
            binding.playTimes.setText(item.playTimesText);

            holder.binding.getRoot().setOnClickListener(v -> {
                RenderItem info = items.get(holder.getBindingAdapterPosition());
                mOnClickListener.accept(info);
            });
        }

        @Override
        public int getItemCount() {
            return items.size();
        }

        public void setItems(List<RenderItem> items) {
            List<RenderItem> oldItems = this.items;
            this.items = items;

            DiffUtil.calculateDiff(new DiffUtil.Callback() {
                @Override
                public int getOldListSize() {
                    return oldItems.size();
                }

                @Override
                public int getNewListSize() {
                    return items.size();
                }

                @Override
                public boolean areItemsTheSame(int oldItemPosition, int newItemPosition) {
                    RenderItem oldItem = oldItems.get(oldItemPosition);
                    RenderItem newItem = items.get(newItemPosition);
                    return TextUtils.equals(oldItem.vid, newItem.vid);
                }

                @Override
                public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                    RenderItem oldItem = oldItems.get(oldItemPosition);
                    RenderItem newItem = items.get(newItemPosition);

                    return TextUtils.equals(oldItem.description, newItem.description)
                            && TextUtils.equals(oldItem.coverUrl, newItem.coverUrl)
                            && TextUtils.equals(oldItem.durationText, newItem.durationText)
                            && TextUtils.equals(oldItem.playTimesText, newItem.playTimesText);
                }
            }).dispatchUpdatesTo(this);
        }
    }

    static class RecommendForYouHolder extends RecyclerView.ViewHolder {
        VevodMiniDramaRecommendForYouItemBinding binding;

        public RecommendForYouHolder(@NonNull VevodMiniDramaRecommendForYouItemBinding binding) {
            super(binding.getRoot());
            this.binding = binding;
        }
    }

    List<RenderItem> map(Context context, List<DramaRecommend> recommends) {
        List<RenderItem> items = new ArrayList<>();
        for (DramaRecommend recommend : recommends) {
            boolean isSelected = viewModel.isSelected(recommend);
            items.add(new RenderItem(context, recommend, isSelected));
        }
        return items;
    }

    static class RenderItem {
        public final DramaInfo info;
        public final DramaFeed item;

        public final String vid;
        public final String description;
        public final String coverUrl;
        public final String durationText;
        public final String playTimesText;

        public final int episodeNumber;

        public final boolean isSelected;

        public RenderItem(Context context, DramaRecommend recommend, boolean isSelected) {
            this.info = recommend.info;
            this.item = recommend.feed;
            this.isSelected = isSelected;

            this.vid = item.vid;
            this.coverUrl = item.coverUrl;
            this.episodeNumber = item.episodeNumber;
            this.description = context.getString(R.string.vevod_mini_drama_episode_description,
                    info.dramaTitle,
                    item.episodeNumber,
                    item.title);
            this.durationText = FormatHelper.formatDuration(context, (long) (item.duration * 1000));
            this.playTimesText = FormatHelper.formatCount(context, item.playTimes);
        }
    }
}
