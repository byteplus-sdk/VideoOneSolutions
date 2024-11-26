// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.voddemo.ui.video.scene.comment;

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

import com.byteplus.vod.scenekit.ui.video.layer.dialog.InputDialog;
import com.byteplus.vodcommon.ui.video.scene.comment.model.CommentItem;
import com.byteplus.voddemo.R;
import com.byteplus.voddemo.databinding.VevodDialogCommentBinding;
import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.google.android.material.bottomsheet.BottomSheetDialogFragment;
import com.vertcdemo.ui.dialog.SolutionCommonDialog;

public class CommentDialogFragment extends BottomSheetDialogFragment {

    @Override
    public int getTheme() {
        return R.style.vevod_bottom_sheet_dialog;
    }

    private CommentViewModel mViewMode;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewMode = new ViewModelProvider(this).get(CommentViewModel.class);
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
        return inflater.inflate(R.layout.vevod_dialog_comment, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        VevodDialogCommentBinding binding = VevodDialogCommentBinding.bind(view);

        Context context = requireContext();

        binding.question.setOnClickListener(v -> showQuestionDialog());
        binding.close.setOnClickListener(v -> dismiss());

        binding.recycler.setLayoutManager(new LinearLayoutManager(context));
        binding.recycler.addItemDecoration(new ItemSpacerDecoration(context, 12, 16));
        CommentItemAdapter adapter = new CommentItemAdapter(this, R.layout.vevod_dialog_comment_item, count -> {
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
            if (state == CommentViewModel.State.INIT) {
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
