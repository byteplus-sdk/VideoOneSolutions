// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.vod.minidrama.scene.comment;

import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_BUTTON_NEGATIVE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_MESSAGE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_TITLE;

import android.app.Dialog;
import android.content.Context;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.byteplus.minidrama.R;
import com.byteplus.minidrama.databinding.VevodMiniDramaDialogCommentBinding;
import com.byteplus.vod.scenekit.ui.video.layer.dialog.InputDialog;
import com.byteplus.vodcommon.ui.video.scene.comment.model.CommentItem;
import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.vertcdemo.ui.dialog.SolutionCommonDialog;

public class MDCommentDialogFragment extends BottomSheetDialogFragment {

    @Override
    public int getTheme() {
        return R.style.VeVodMiniDramaBottomSheetLight;
    }

    private MDCommentViewModel mViewMode;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewMode = new ViewModelProvider(this).get(MDCommentViewModel.class);
        mViewMode.vid = requireArguments().getString("vid");
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

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.vevod_mini_drama_dialog_comment, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        VevodMiniDramaDialogCommentBinding binding = VevodMiniDramaDialogCommentBinding.bind(view);

        Context context = requireContext();

        binding.question.setOnClickListener(v -> showQuestionDialog());
        binding.close.setOnClickListener(v -> dismiss());

        binding.recycler.setLayoutManager(new LinearLayoutManager(context));
        binding.recycler.addItemDecoration(new MDItemSpacerDecoration(context, 12, 16));
        MDCommentItemAdapter adapter = new MDCommentItemAdapter(this, R.layout.vevod_mini_drama_dialog_comment_item, count -> {
            binding.title.setText(context.getString(R.string.vevod_comment_dialog_num, count));
        });
        binding.recycler.setAdapter(adapter);

        binding.inputComment.setOnClickListener(v -> {
            InputDialog inputDialog = new InputDialog();
            inputDialog.setSendCallback(content -> {
                CommentItem item = CommentItem.self(content);
                adapter.addFirstItem(item);
                binding.recycler.scrollToPosition(0);
            });
            inputDialog.show(getChildFragmentManager(), "comment-input-dialog");
        });

        mViewMode.state.observe(getViewLifecycleOwner(), state -> {
            if (state == MDCommentViewModel.State.INIT) {
                mViewMode.load();
            }
        });

        mViewMode.comments.observe(getViewLifecycleOwner(), adapter::setItems);
    }

    void showQuestionDialog() {
        SolutionCommonDialog dialog = new SolutionCommonDialog();
        final Bundle args = new Bundle();
        args.putInt(EXTRA_TITLE, R.string.vevod_tips);
        args.putInt(EXTRA_MESSAGE, R.string.vevod_comment_question_message);
        args.putInt(EXTRA_BUTTON_NEGATIVE, R.string.vevod_close);
        dialog.setArguments(args);
        dialog.show(getChildFragmentManager(), "comment_question");
    }
}
