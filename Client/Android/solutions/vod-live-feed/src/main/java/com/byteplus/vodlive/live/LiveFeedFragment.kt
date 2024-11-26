package com.byteplus.vodlive.live

import android.os.Bundle
import android.text.TextUtils
import android.view.View
import androidx.activity.OnBackPressedCallback
import androidx.core.graphics.Insets
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentResultListener
import androidx.fragment.app.viewModels
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.viewmodel.MutableCreationExtras
import androidx.recyclerview.widget.RecyclerView
import androidx.viewpager2.widget.ViewPager2
import com.byteplus.vodlive.R
import com.byteplus.vodlive.databinding.FragmentLiveFeedBinding
import com.byteplus.vodlive.live.event.ActionEvent
import com.byteplus.vodlive.live.event.AudienceChanged
import com.byteplus.vodlive.live.event.CloseAction
import com.byteplus.vodlive.live.event.CommentAction
import com.byteplus.vodlive.live.event.GiftAction
import com.byteplus.vodlive.live.event.JoinBusinessEvent
import com.byteplus.vodlive.live.event.JoinRoomEvent
import com.byteplus.vodlive.live.event.LikeAction
import com.byteplus.vodlive.live.event.MessageReceivedEvent
import com.byteplus.vodlive.live.player.PlayerScene
import com.byteplus.vodlive.live.room.RTCRoomManager
import com.byteplus.vodlive.live.room.RoomEventBus
import com.byteplus.vodlive.network.model.LiveFeedItem
import com.byteplus.vodlive.utils.OnPageChangeCallbackExt
import com.byteplus.vodlive.utils.get
import com.vertcdemo.core.chat.gift.GiftDialog
import com.vertcdemo.core.chat.input.MessageInputDialog
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import org.greenrobot.eventbus.Subscribe
import org.greenrobot.eventbus.ThreadMode

class LiveFeedFragment : Fragment(R.layout.fragment_live_feed), GiftDialog.IGiftSender {
    private val viewModel: LiveFeedViewModel by viewModels(
        extrasProducer = {
            MutableCreationExtras().apply {
                set(
                    LiveItemKey,
                    requireActivity().intent.getParcelableExtra(EXTRA_LIVE_ROOM) as LiveFeedItem?
                )
                set(RoomManagerKey, RTCRoomManager(requireContext().applicationContext))
            }
        },
        factoryProducer = ::LiveFeedViewModelFactory
    )

    private val liveController by lazy { LiveController(requireContext(), PlayerScene.FEED) }

    private var insets: Insets = Insets.NONE

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        childFragmentManager.setFragmentResultListener(
            MessageInputDialog.REQUEST_KEY_MESSAGE_INPUT,
            this,
            messageInputResultListener
        )

        requireActivity()
            .onBackPressedDispatcher
            .addCallback(
                this,
                object : OnBackPressedCallback(true) {
                    override fun handleOnBackPressed() {
                        liveController.onFinish()
                        requireActivity().finish()
                    }
                })
    }

    private var mLastInputText: String? = null
    private val messageInputResultListener =
        FragmentResultListener { _, result: Bundle ->
            val content = result.getString(MessageInputDialog.EXTRA_CONTENT)
            val actionDone =
                result.getBoolean(MessageInputDialog.EXTRA_ACTION_DONE, false)
            if (actionDone) {
                mLastInputText = null
                val item = viewModel.currentItem ?: return@FragmentResultListener
                viewModel.sendMessage(item, content ?: "")
            } else {
                mLastInputText = content
            }
        }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        val binding = FragmentLiveFeedBinding.bind(view)

        ViewCompat.setOnApplyWindowInsetsListener(view) { _, windowInsets ->
            this.insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars())
            windowInsets
        }

        val adapter = LiveFeedAdapter()

        binding.viewPager.orientation = ViewPager2.ORIENTATION_VERTICAL
        binding.viewPager.adapter = adapter

        // Handle load more
        binding.viewPager.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) {
                if (!viewModel.canLoadMore) {
                    return
                }

                if (position >= adapter.itemCount - 2) {
                    viewModel.loadNext()
                }
            }
        })

        val pageChangeCallback = object : OnPageChangeCallbackExt() {
            override fun onPositionVisibilityChanged(oldPosition: Int, newPosition: Int) {
                if (newPosition == RecyclerView.NO_POSITION) return
                val holder = binding.viewPager.get(newPosition) as? LiveFeedHolder ?: return
                val item = adapter.getItem(newPosition)
                liveController.preview(holder, item)
            }

            override fun onPageSelected(position: Int) {
                super.onPageSelected(position)

                val item = adapter.getItem(position)
                viewModel.switchRoom(item)

                val holder = binding.viewPager.get(position) as LiveFeedHolder
                liveController.select(holder, item)

                val next = position + 1
                if (next < adapter.itemCount) {
                    val nextItem = adapter.getItem(next)
                    liveController.preload(
                        binding.viewPager.get(next) as? LiveFeedHolder,
                        nextItem
                    )
                }
            }
        }
        binding.viewPager.registerOnPageChangeCallback(pageChangeCallback)

        lifecycleScope.launch {
            viewModel.liveItemFlow.collectLatest { items ->
                adapter.setItems(items)
            }
        }

        lifecycle.addObserver(liveController)
        RoomEventBus.register(this)
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onJoinRoomEvent(event: JoinRoomEvent) {
        val holder = liveController.feedHolder ?: return
        if (event.roomId == holder.roomId) {
            if (event is JoinBusinessEvent) {
                holder.showRoomUI(insets, event.audienceCount)
            }
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onMessageEvent(event: MessageReceivedEvent) {
        val holder = liveController.feedHolder ?: return
        if (event.roomId == holder.roomId) {
            holder.onMessageEvent(event)
        }
    }

    @Subscribe(threadMode = ThreadMode.MAIN)
    fun onAudienceCountChanged(event: AudienceChanged) {
        val holder = liveController.feedHolder ?: return
        if (event.roomId == holder.roomId) {
            holder.updateAudienceCount(event.audienceCount)
        }
    }

    @Subscribe(threadMode = ThreadMode.POSTING)
    fun onActionEvent(event: ActionEvent) {
        when (event) {
            is CloseAction -> {
                requireActivity().onBackPressed()
            }

            is GiftAction -> {
                val dialog = GiftDialog()
                dialog.show(childFragmentManager, "gift_dialog")
            }

            is LikeAction -> {
                viewModel.sendLike(event.item)
            }

            is CommentAction -> {
                val dialog = MessageInputDialog()
                if (!TextUtils.isEmpty(mLastInputText)) {
                    val args = Bundle()
                    args.putString(MessageInputDialog.EXTRA_CONTENT, mLastInputText)
                    dialog.arguments = args
                }
                dialog.show(childFragmentManager, "message-input-dialog")
            }
        }
    }

    override fun onDestroyView() {
        RoomEventBus.unregister(this)
        liveController.feedHolder?.unselect()
        super.onDestroyView()
    }

    override fun sendGift(giftType: Int) {
        val item = viewModel.currentItem ?: return
        viewModel.sendGift(item, giftType)
    }
}