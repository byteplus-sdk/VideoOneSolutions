// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.solution.interactivelive.feature.main.audiencelink;

import static com.vertcdemo.solution.interactivelive.feature.main.audiencelink.LinkedAudiencesAdapter.OnItemClickedListener2.BUTTON_CAMERA;
import static com.vertcdemo.solution.interactivelive.feature.main.audiencelink.LinkedAudiencesAdapter.OnItemClickedListener2.BUTTON_HANGUP;
import static com.vertcdemo.solution.interactivelive.feature.main.audiencelink.LinkedAudiencesAdapter.OnItemClickedListener2.BUTTON_MICROPHONE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_BUTTON_NEGATIVE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_BUTTON_POSITIVE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_MESSAGE;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_REQUEST_KEY;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_RESULT;
import static com.vertcdemo.ui.dialog.SolutionCommonDialog.EXTRA_TITLE;

import android.annotation.SuppressLint;
import android.app.Dialog;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.os.SystemClock;
import android.text.Html;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentResultListener;
import androidx.lifecycle.ViewModelProvider;
import androidx.recyclerview.widget.LinearLayoutManager;

import com.vertcdemo.core.eventbus.SolutionEventBus;
import com.vertcdemo.core.net.IRequestCallback;
import com.vertcdemo.core.ui.BottomDialogFragmentX;
import com.vertcdemo.solution.interactivelive.R;
import com.vertcdemo.solution.interactivelive.bean.LiveResponse;
import com.vertcdemo.solution.interactivelive.bean.LiveRoomInfo;
import com.vertcdemo.solution.interactivelive.bean.LiveUserInfo;
import com.vertcdemo.solution.interactivelive.core.LiveRTCManager;
import com.vertcdemo.solution.interactivelive.core.annotation.LivePermitType;
import com.vertcdemo.core.annotation.MediaStatus;
import com.vertcdemo.solution.interactivelive.databinding.DialogManageAudiencesBinding;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkApplyEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkCancelEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkFinishEvent;
import com.vertcdemo.solution.interactivelive.event.AudienceLinkStatusEvent;
import com.vertcdemo.solution.interactivelive.event.LiveRTSUserEvent;
import com.vertcdemo.solution.interactivelive.event.UserMediaChangedEvent;
import com.vertcdemo.solution.interactivelive.feature.main.HostViewModel;
import com.vertcdemo.ui.CenteredToast;
import com.vertcdemo.ui.dialog.SolutionCommonDialog;

import org.greenrobot.eventbus.Subscribe;
import org.greenrobot.eventbus.ThreadMode;

import java.util.Collections;
import java.util.List;

public class ManageAudiencesDialog extends BottomDialogFragmentX {

    public interface IManageAudience {
        List<AudienceLinkRequest> getAudienceLinkRequests();

        List<LiveUserInfo> getLinkedAudiences();

        void replyAudienceRequestByHost(AudienceLinkApplyEvent event, @LivePermitType int permitType);
    }

    /**
     * @see #mEndAllCoAudiencesCallback
     * @see #showEndAllCoAudiencesDialog()
     */
    private static final String REQUEST_KEY_END_ALL_CO_AUDIENCES = "request_key_end_all_co_audiences";

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        return inflater.inflate(R.layout.dialog_manage_audiences, container, false);
    }

    @Override
    public int getTheme() {
        return R.style.LiveBottomSheetDialogTheme;
    }

    private DialogManageAudiencesBinding mBinding;

    private ApplicationAdapter mApplicationAdapter;
    private LinkedAudiencesAdapter mLinkedAudiencesAdapter;

    private LiveRoomInfo mLiveRoomInfo;

    private long mStartAudienceLinkTime;

    private static final int MSG_TIME_TICK = 1;

    @SuppressLint("HandlerLeak")
    private final Handler mHandler = new Handler() {
        @Override
        public void handleMessage(@NonNull Message msg) {
            if (MSG_TIME_TICK == msg.what) {
                if (mStartAudienceLinkTime > 0 && mIsCoHost) {
                    final long duration = SystemClock.uptimeMillis() - mStartAudienceLinkTime;
                    mBinding.coHost.timing.setText(formatAudienceLinkDuration(duration));
                    sendEmptyMessageDelayed(msg.what, 1000);
                }
            }
        }
    };

    HostViewModel mHostViewModel;

    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        mHostViewModel = new ViewModelProvider(requireParentFragment()).get(HostViewModel.class);

        final FragmentManager childFragmentManager = getChildFragmentManager();

        childFragmentManager.setFragmentResultListener(REQUEST_KEY_END_ALL_CO_AUDIENCES, this, mEndAllCoAudiencesCallback);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        mBinding = DialogManageAudiencesBinding.bind(view);

        final Bundle arguments = requireArguments();
        mLiveRoomInfo = (LiveRoomInfo) arguments.getSerializable("roomInfo");
        mStartAudienceLinkTime = arguments.getLong("startAudienceLinkTime");

        mBinding.tabCoHost.setOnClickListener(v -> switchTab(true));
        mBinding.tabCoHostApplication.setOnClickListener(v -> switchTab(false));

        IManageAudience source;
        final Fragment fragment = getParentFragment();
        if (fragment instanceof IManageAudience) {
            source = (IManageAudience) fragment;
        } else {
            source = null;
        }

        // region CoHost
        mBinding.coHost.emptyAction.setOnClickListener(v -> switchTab(false));
        mLinkedAudiencesAdapter = new LinkedAudiencesAdapter(source == null ? Collections.emptyList() : source.getLinkedAudiences(), this::handleCoAudienceItemClicked);
        mBinding.coHost.recycler.setLayoutManager(new LinearLayoutManager(requireContext()));
        mBinding.coHost.recycler.setAdapter(mLinkedAudiencesAdapter);

        mBinding.coHost.button.setOnClickListener(v -> showEndAllCoAudiencesDialog());

        mBinding.questionMark.setOnClickListener(v -> CenteredToast.show(R.string.audience_link_manage_tips));
        // endregion

        // region applications
        mApplicationAdapter = new ApplicationAdapter(source == null ? Collections.emptyList() : source.getAudienceLinkRequests(), (event, permitType) -> {
            if (source != null) {
                source.replyAudienceRequestByHost(event, permitType);
            }

            if (permitType == LivePermitType.REJECT) {
                // No subsequence Event, so remove the request manually.
                mApplicationAdapter.removeItem(event.applicant.userId);
                mBinding.getRoot().post(this::checkEmptyStatus);
            }
        });
        mApplicationAdapter.setLinkedCount(mLinkedAudiencesAdapter.getItemCount());
        mBinding.application.recycler.setLayoutManager(new LinearLayoutManager(requireContext()));
        mBinding.application.recycler.setAdapter(mApplicationAdapter);

        mHostViewModel.showAudienceDot.observe(getViewLifecycleOwner(), hasApplication -> {
            mBinding.audienceDot.setVisibility(hasApplication ? View.VISIBLE : View.GONE);
        });
        // endregion

        boolean hasNewAudienceApplication = mHostViewModel.showAudienceDot.getValue();
        switchTab(!hasNewAudienceApplication);
        SolutionEventBus.register(this);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        SolutionEventBus.unregister(this);
        mHandler.removeCallbacksAndMessages(null);
    }

    boolean mIsCoHost = false;

    public boolean isApplicationTab() {
        return !mIsCoHost;
    }

    void switchTab(boolean isCoHost) {
        mIsCoHost = isCoHost;
        mBinding.tabCoHost.setSelected(isCoHost);
        final Typeface bold = Typeface.defaultFromStyle(Typeface.BOLD);
        final Typeface normal = Typeface.defaultFromStyle(Typeface.NORMAL);
        mBinding.tabCoHost.setTypeface(isCoHost ? bold : normal);
        mBinding.tabCoHostApplication.setSelected(!isCoHost);
        mBinding.tabCoHostApplication.setTypeface(!isCoHost ? bold : normal);

        mBinding.groupCoHost.setVisibility(isCoHost ? View.VISIBLE : View.GONE);
        mBinding.groupApplication.setVisibility(isCoHost ? View.GONE : View.VISIBLE);

        if (!isCoHost) {
            mHostViewModel.showAudienceDot.postValue(false);
        }

        if (isCoHost) {
            mHandler.sendEmptyMessage(MSG_TIME_TICK);
        } else {
            mHandler.removeMessages(MSG_TIME_TICK);
        }

        checkEmptyStatus();
    }

    void checkEmptyStatus() {
        if (mIsCoHost) {
            final boolean hasCoHost = hasCoHost();
            mBinding.coHost.groupContent.setVisibility(hasCoHost ? View.VISIBLE : View.GONE);
            mBinding.coHost.groupEmpty.setVisibility(hasCoHost ? View.GONE : View.VISIBLE);
        } else {
            final boolean hasApplication = hasApplication();
            mBinding.application.groupContent.setVisibility(hasApplication ? View.VISIBLE : View.GONE);
            mBinding.application.groupEmpty.setVisibility(hasApplication ? View.GONE : View.VISIBLE);
            if (hasApplication) {
                mBinding.application.tips.setText(formatCoHostApplicationCount(mApplicationAdapter.getItemCount()));
            }
        }
    }

    boolean hasCoHost() {
        return mLinkedAudiencesAdapter.getItemCount() > 0;
    }

    boolean hasApplication() {
        return mApplicationAdapter.getItemCount() > 0;
    }

    void showEndAllCoAudiencesDialog() {
        SolutionCommonDialog dialog = new SolutionCommonDialog();
        Bundle args = new Bundle();
        args.putString(EXTRA_REQUEST_KEY, REQUEST_KEY_END_ALL_CO_AUDIENCES);
        args.putInt(EXTRA_TITLE, R.string.end_all_co_audiences_title);
        args.putInt(EXTRA_MESSAGE, R.string.end_all_co_audiences_message);
        args.putInt(EXTRA_BUTTON_POSITIVE, R.string.confirm);
        args.putInt(EXTRA_BUTTON_NEGATIVE, R.string.cancel);
        dialog.setArguments(args);
        dialog.show(getChildFragmentManager(), "end_all_co_host_dialog");
    }

    private final FragmentResultListener mEndAllCoAudiencesCallback = (requestKey, result) -> {
        final int button = result.getInt(EXTRA_RESULT);
        if (button == Dialog.BUTTON_POSITIVE) {
            String roomId = mLiveRoomInfo.roomId;
            LiveRTCManager.ins().getRTSClient().finishAudienceLinkByHost(roomId, data -> {
                CenteredToast.show(R.string.audience_link_disconnect_all);
            });
        }
    };

    void handleCoAudienceItemClicked(LinkedAudienceItem item, int button) {
        switch (button) {
            case BUTTON_MICROPHONE: {
                if (!item.microphoneOn) {
                    // Only can close Audience's microphone
                    return;
                }

                final int cameraStatus = MediaStatus.KEEP;
                final int microphoneStatus = MediaStatus.OFF;
                manageAudienceMediaStatus(item, cameraStatus, microphoneStatus);
                break;
            }
            case BUTTON_CAMERA: {
                if (!item.cameraOn) {
                    // Only can close Audience's camera;
                    return;
                }

                final int cameraStatus = MediaStatus.OFF;
                final int microphoneStatus = MediaStatus.KEEP;
                manageAudienceMediaStatus(item, cameraStatus, microphoneStatus);
                break;
            }
            case BUTTON_HANGUP: {
                showConfirmHangupUserDialog(item);
                break;
            }
        }
    }

    void manageAudienceMediaStatus(LinkedAudienceItem item, @MediaStatus int camera, @MediaStatus int mic) {
        final String roomId = mLiveRoomInfo.roomId;
        final String hostId = mLiveRoomInfo.anchorUserId;
        final String audienceId = item.info.userId;

        final IRequestCallback<LiveResponse> callback = o -> {

        };
        LiveRTCManager.rts().requestManageGuest(roomId, hostId, roomId, audienceId, camera, mic, callback);
        SolutionEventBus.post(new UserMediaChangedEvent(roomId, audienceId, hostId, mic, camera));
    }

    void showConfirmHangupUserDialog(LinkedAudienceItem item) {
        final String roomId = mLiveRoomInfo.roomId;
        final String hostId = mLiveRoomInfo.anchorUserId;
        final String audienceId = item.info.userId;
        final String audienceName = item.info.userName;

        EndCoAudienceDialog dialog = new EndCoAudienceDialog();
        final Bundle args = new Bundle();
        args.putString("roomId", roomId);
        args.putString("hostId", hostId);
        args.putString("audienceId", audienceId);
        args.putString("audienceName", audienceName);
        dialog.setArguments(args);
        dialog.show(getChildFragmentManager(), "end_co_audience_dialog");
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onLiveRTSUserEvent(LiveRTSUserEvent event) {
        if (!event.isJoin()) {
            mApplicationAdapter.removeItem(event.audienceUserId);
            mBinding.getRoot().post(this::checkEmptyStatus);
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkApplyEvent(AudienceLinkApplyEvent event) {
        mApplicationAdapter.addItem(event);
        mBinding.application.recycler.post(this::checkEmptyStatus);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkCancelEvent(AudienceLinkCancelEvent event) {
        mApplicationAdapter.removeItem(event.userId);
        mBinding.application.recycler.post(this::checkEmptyStatus);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkStatusEvent(AudienceLinkStatusEvent event) {
        if (event.isJoin()) {
            mApplicationAdapter.removeItem(event.userId);
        }

        mLinkedAudiencesAdapter.updateItem(event);
        mApplicationAdapter.setLinkedCount(mLinkedAudiencesAdapter.getItemCount());
        if (mLinkedAudiencesAdapter.getItemCount() == 1 && mStartAudienceLinkTime <= 0) {
            // First Audience link
            mStartAudienceLinkTime = SystemClock.uptimeMillis();
            mHandler.sendEmptyMessage(MSG_TIME_TICK);
        }
        mBinding.getRoot().post(this::checkEmptyStatus);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onAudienceLinkFinishEvent(AudienceLinkFinishEvent event) {
        mLinkedAudiencesAdapter.clear();
        mApplicationAdapter.setLinkedCount(mLinkedAudiencesAdapter.getItemCount());
        mStartAudienceLinkTime = 0;

        mBinding.getRoot().post(this::checkEmptyStatus);
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    public void onUserMediaChangedEvent(UserMediaChangedEvent event) {
        mLinkedAudiencesAdapter.onAudienceMediaUpdateEvent(event);
    }

    CharSequence formatCoHostApplicationCount(int count) {
        return Html.fromHtml(getString(R.string.audience_link_request_count, count));
    }

    CharSequence formatAudienceLinkDuration(long duration) {
        final long durationInSeconds = duration / 1000;
        final long minutes = durationInSeconds / 60;
        final long seconds = durationInSeconds % 60;
        return Html.fromHtml(getString(R.string.audience_link_time, minutes, seconds));
    }
}
