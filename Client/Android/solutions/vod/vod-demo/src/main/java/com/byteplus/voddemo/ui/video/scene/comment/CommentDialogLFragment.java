// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.byteplus.voddemo.ui.video.scene.comment;

import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_BUTTON_NEGATIVE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_MESSAGE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_TITLE;

import android.content.Context;
import android.content.res.Configuration;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.DialogFragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.byteplus.vod.scenekit.ui.video.layer.dialog.InputDialog;
import com.byteplus.voddemo.R;
import com.byteplus.voddemo.databinding.VevodDialogCommentLayerBinding;
import com.byteplus.vodcommon.ui.video.scene.comment.model.CommentItem;
import com.vertcdemo.ui.dialog.SolutionCommonDialog;

/**
 * Land scape comment dialog
 */
public class CommentDialogLFragment extends DialogFragment {

    @Override
    public int getTheme() {
        return R.style.vevod_full_screen_dialog;
    }

    private CommentViewModel mViewMode;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mViewMode = new ViewModelProvider(this).get(CommentViewModel.class);
        mViewMode.vid = requireArguments().getString("vid");
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.vevod_dialog_comment_layer, container, false);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        VevodDialogCommentLayerBinding binding = VevodDialogCommentLayerBinding.bind(view);

        Context context = requireContext();

        binding.getRoot().setOnClickListener(v -> dismiss());

        binding.question.setOnClickListener(v -> showQuestionDialog());

        binding.recycler.setLayoutManager(new LinearLayoutManager(context));
        binding.recycler.addItemDecoration(new ItemSpacerDecoration(context, 0, 8));
        CommentItemAdapter adapter = new CommentItemAdapter(this, R.layout.vevod_dialog_comment_layer_item, count -> {
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

    @Override
    public void onConfigurationChanged(@NonNull Configuration newConfig) {
        if (newConfig.orientation != Configuration.ORIENTATION_LANDSCAPE) {
            // This dialog only show when LANDSCAPE, so should dismiss when Leave Landscape
            dismissAllowingStateLoss();
        }
        super.onConfigurationChanged(newConfig);
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
