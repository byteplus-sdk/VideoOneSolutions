package com.vertc.api.example.examples.thirdpart.bytebeauty.fragments;

import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.core.util.Consumer;
import androidx.recyclerview.widget.DiffUtil;
import androidx.recyclerview.widget.RecyclerView;

import com.vertc.api.example.R;
import com.vertc.api.example.examples.thirdpart.bytebeauty.bean.EffectNode;

import java.util.Collections;
import java.util.List;


class EffectNodeAdapter extends RecyclerView.Adapter<NodeViewHolder> {

    @NonNull
    private List<? extends EffectNode> mItems = Collections.emptyList();
    @NonNull
    private final Consumer<EffectNode> mNodeClick;

    public EffectNodeAdapter(@NonNull Consumer<EffectNode> iNodeClick) {
        mNodeClick = iNodeClick;
    }

    @NonNull
    @Override
    public NodeViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        return new NodeViewHolder(LayoutInflater.from(parent.getContext())
                .inflate(R.layout.view_holder_beauty, parent, false));
    }

    @Override
    public void onBindViewHolder(@NonNull NodeViewHolder holder, int position) {
        EffectNode node = mItems.get(position);
        ((TextView) holder.itemView).setText(node.title);
        holder.itemView.setSelected(node.selected);
        holder.itemView.setOnClickListener((v) -> mNodeClick.accept(node));
    }

    @Override
    public int getItemCount() {
        return mItems.size();
    }

    public void setList(@NonNull List<? extends EffectNode> items) {
        List<? extends EffectNode> oldItems = mItems;
        mItems = items;
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
                EffectNode oldItem = oldItems.get(oldItemPosition);
                EffectNode newItem = items.get(newItemPosition);
                return oldItem == newItem;
            }

            @Override
            public boolean areContentsTheSame(int oldItemPosition, int newItemPosition) {
                EffectNode oldItem = oldItems.get(oldItemPosition);
                EffectNode newItem = items.get(newItemPosition);
                return oldItem.key.equals(newItem.key) && oldItem.selected == newItem.selected;
            }
        }).dispatchUpdatesTo(this);
    }
}