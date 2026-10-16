// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.byteplus.live.sport.compare

import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.ActivityInfo
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.TextureView
import android.view.View
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import androidx.constraintlayout.widget.Guideline
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import com.byteplus.live.sport.R
import com.byteplus.live.sport.player.SportLiveEnv
import com.byteplus.live.sport.player.SportPlayerStats

/**
 * Live Comparison page — three click-switched tabs (no swipe):
 *  1. Low latency: two independent players, each picking a pull protocol.
 *  2. Enhancement: a processed (SR/sharpen) vs original player pair, same source.
 *  3. Cost reduction: an H.265 vs H.264 pair, with two sub-tabs swapping streams.
 *
 * All streams are single-address. Only the visible tab's players run; switching
 * tabs releases the others (so at most two streams pull at once). Players start
 * muted and can be controlled independently.
 */
class LiveCompareActivity : AppCompatActivity() {

    private enum class Tab { LATENCY, ENHANCE, COST }

    private var config: CompareConfig? = null
    private var activeTab = Tab.LATENCY
    // True between onResume and onPause; gates playback so onCreate's initial
    // selectTab only binds config (onResume starts the actual playback).
    private var started = false

    // --- Tab 1 (latency) ---
    private val latencySlots = arrayOfNulls<CompareSlot>(2)
    private val latencySelected = arrayOf(0, 0) // protocol index per card
    private lateinit var latencyOverlays: Array<TextView>
    private lateinit var latencyReservedHints: Array<TextView>
    private lateinit var protocolTabRows: Array<LinearLayout>
    private lateinit var latencyPlayButtons: Array<ImageView>
    private lateinit var latencyMuteButtons: Array<ImageView>

    // --- Tab 2 (enhance) ---
    private var enhanceProcessed: CompareSlot? = null
    private var enhanceOrigin: CompareSlot? = null
    private lateinit var enhancePlayButtons: Array<ImageView>
    private lateinit var enhanceMuteButtons: Array<ImageView>
    private var srOn = true
    private var sharpenOn = true

    // --- Tab 3 (cost) ---
    private enum class CostSubTab { SAME_QUALITY, SAME_BITRATE }
    private var costSubTab = CostSubTab.SAME_QUALITY
    private var costH265: CompareSlot? = null
    private var costH264: CompareSlot? = null
    private lateinit var costBitrateOverlays: Array<TextView>
    private lateinit var costPlayButtons: Array<ImageView>
    private lateinit var costMuteButtons: Array<ImageView>
    private lateinit var subtabSameQuality: TextView
    private lateinit var subtabSameBitrate: TextView
    private var chartDialog: BitrateChartDialog? = null
    // Which cost slot the open chart dialog is tracking (0 = H.265, 1 = H.264).
    private var chartSlotIndex = -1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContentView(R.layout.live_sport_activity_compare)
        requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_PORTRAIT
        WindowCompat.getInsetsController(window, window.decorView)
            .isAppearanceLightStatusBars = true

        val statusGuide = findViewById<Guideline>(R.id.guideline_status_bar)
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.root)) { _, insets ->
            statusGuide.setGuidelineBegin(
                insets.getInsets(WindowInsetsCompat.Type.systemBars()).top
            )
            insets
        }

        SportLiveEnv.ensureInitialized(this)
        config = CompareConfigRepo.load(this)

        bindHead()
        bindLatencyTab()
        bindEnhanceTab()
        bindCostTab()

        selectTab(Tab.LATENCY)
    }

    override fun onResume() {
        super.onResume()
        started = true
        playActiveTab()
    }

    override fun onPause() {
        super.onPause()
        started = false
        pauseAllSlots()
    }

    override fun onDestroy() {
        chartDialog?.dismiss()
        releaseAllSlots()
        super.onDestroy()
    }

    // region head + tab switching

    private fun bindHead() {
        findViewById<ImageView>(R.id.btn_back).setOnClickListener { finish() }
        findViewById<View>(R.id.tab_latency).setOnClickListener { selectTab(Tab.LATENCY) }
        findViewById<View>(R.id.tab_enhance).setOnClickListener { selectTab(Tab.ENHANCE) }
        findViewById<View>(R.id.tab_cost).setOnClickListener { selectTab(Tab.COST) }
    }

    private fun selectTab(tab: Tab) {
        activeTab = tab

        // Release the players of the tabs we're leaving so at most one tab's
        // players are alive at a time.
        if (tab != Tab.LATENCY) releaseLatency()
        if (tab != Tab.ENHANCE) releaseEnhance()
        if (tab != Tab.COST) releaseCost()

        tabContent(Tab.LATENCY).visibility = if (tab == Tab.LATENCY) View.VISIBLE else View.GONE
        tabContent(Tab.ENHANCE).visibility = if (tab == Tab.ENHANCE) View.VISIBLE else View.GONE
        tabContent(Tab.COST).visibility = if (tab == Tab.COST) View.VISIBLE else View.GONE

        updateTabStyles()

        when (tab) {
            Tab.LATENCY -> bindLatencyStreams()
            Tab.ENHANCE -> bindEnhanceStreams()
            Tab.COST -> bindCostStreams()
        }
        playActiveTab()
    }

    private fun tabContent(tab: Tab): View = when (tab) {
        Tab.LATENCY -> findViewById(R.id.content_latency)
        Tab.ENHANCE -> findViewById(R.id.content_enhance)
        Tab.COST -> findViewById(R.id.content_cost)
    }

    private fun updateTabStyles() {
        setTabStyle(R.id.tab_latency_text, R.id.tab_latency_indicator, activeTab == Tab.LATENCY)
        setTabStyle(R.id.tab_enhance_text, R.id.tab_enhance_indicator, activeTab == Tab.ENHANCE)
        setTabStyle(R.id.tab_cost_text, R.id.tab_cost_indicator, activeTab == Tab.COST)
    }

    private fun setTabStyle(textId: Int, indicatorId: Int, active: Boolean) {
        val text = findViewById<TextView>(textId)
        text.setTextColor(if (active) COLOR_TAB_ACTIVE else COLOR_TAB_INACTIVE)
        text.setTypeface(null, if (active) android.graphics.Typeface.BOLD else android.graphics.Typeface.NORMAL)
        findViewById<View>(indicatorId).visibility = if (active) View.VISIBLE else View.INVISIBLE
    }

    // endregion

    // region lifecycle helpers

    private fun playActiveTab() {
        if (!started) return
        when (activeTab) {
            Tab.LATENCY -> latencySlots.forEach { it?.playIfAllowed() }
            Tab.ENHANCE -> { enhanceProcessed?.playIfAllowed(); enhanceOrigin?.playIfAllowed() }
            Tab.COST -> { costH265?.playIfAllowed(); costH264?.playIfAllowed() }
        }
        updateActiveSlotControls()
    }

    private fun pauseAllSlots() {
        latencySlots.forEach { it?.pause() }
        enhanceProcessed?.pause(); enhanceOrigin?.pause()
        costH265?.pause(); costH264?.pause()
    }

    private fun releaseAllSlots() {
        releaseLatency(); releaseEnhance(); releaseCost()
    }

    private fun bindSlotControls(
        slotProvider: () -> CompareSlot?,
        playButton: ImageView,
        muteButton: ImageView,
    ) {
        playButton.setOnClickListener {
            val slot = slotProvider() ?: return@setOnClickListener
            if (slot.isPlaying) {
                slot.pause(fromUser = true)
            } else {
                slot.play(fromUser = true)
            }
            updateSlotControls(slot, playButton, muteButton)
        }
        muteButton.setOnClickListener {
            val slot = slotProvider() ?: return@setOnClickListener
            slot.setMuted(!slot.isMuted)
            updateSlotControls(slot, playButton, muteButton)
        }
        updateSlotControls(slotProvider(), playButton, muteButton)
    }

    private fun updateSlotControls(
        slot: CompareSlot?,
        playButton: ImageView,
        muteButton: ImageView,
    ) {
        val visible = slot?.hasStream == true
        playButton.visibility = if (visible) View.VISIBLE else View.GONE
        muteButton.visibility = if (visible) View.VISIBLE else View.GONE
        playButton.isSelected = slot?.isPlaying == true
        muteButton.isSelected = slot?.isMuted != false
    }

    private fun updateActiveSlotControls() {
        when (activeTab) {
            Tab.LATENCY -> updateLatencyControls()
            Tab.ENHANCE -> updateEnhanceControls()
            Tab.COST -> updateCostControls()
        }
    }

    // endregion

    // region tab 1 — latency

    private fun bindLatencyTab() {
        val content = findViewById<View>(R.id.content_latency)
        protocolTabRows = arrayOf(
            content.findViewById(R.id.protocol_tabs_1),
            content.findViewById(R.id.protocol_tabs_2),
        )
        latencyOverlays = arrayOf(
            content.findViewById(R.id.latency_overlay_1),
            content.findViewById(R.id.latency_overlay_2),
        )
        latencyReservedHints = arrayOf(
            content.findViewById(R.id.reserved_hint_1),
            content.findViewById(R.id.reserved_hint_2),
        )
        latencyPlayButtons = arrayOf(
            content.findViewById(R.id.btn_play_pause_1),
            content.findViewById(R.id.btn_play_pause_2),
        )
        latencyMuteButtons = arrayOf(
            content.findViewById(R.id.btn_mute_1),
            content.findViewById(R.id.btn_mute_2),
        )
        latencySlots[0] = CompareSlot(this, content.findViewById<TextureView>(R.id.player_texture_1))
        latencySlots[1] = CompareSlot(this, content.findViewById<TextureView>(R.id.player_texture_2))
        latencySlots[0]?.onStats = { stats -> updateLatencyOverlay(0, stats) }
        latencySlots[1]?.onStats = { stats -> updateLatencyOverlay(1, stats) }
        for (i in latencySlots.indices) {
            bindSlotControls({ latencySlots[i] }, latencyPlayButtons[i], latencyMuteButtons[i])
        }

        content.findViewById<View>(R.id.btn_view_doc).setOnClickListener { openDoc(config?.docUrlLatency) }

        buildProtocolTabs(0)
        buildProtocolTabs(1)
        // Both cards default to RTM; the user switches one side to compare the
        // latency of two protocols against the same source.
        latencySelected[0] = 0
        latencySelected[1] = 0
        refreshProtocolTabSelection(0)
        refreshProtocolTabSelection(1)
    }

    private fun buildProtocolTabs(card: Int) {
        val row = protocolTabRows[card]
        row.removeAllViews()
        val protocols = config?.latency ?: emptyList()
        protocols.forEachIndexed { index, entry ->
            val chip = LayoutInflater.from(this)
                .inflate(R.layout.live_sport_compare_item_protocol, row, false) as TextView
            chip.text = protocolLabel(entry.protocol)
            if (index > 0) {
                (chip.layoutParams as LinearLayout.LayoutParams).marginStart = dp(8)
            }
            chip.setOnClickListener { onProtocolPicked(card, index) }
            row.addView(chip)
        }
    }

    private fun onProtocolPicked(card: Int, index: Int) {
        val entry = config?.latency?.getOrNull(index) ?: return
        latencySelected[card] = index
        refreshProtocolTabSelection(card)
        if (entry.protocol.reserved) {
            Toast.makeText(
                this,
                getString(R.string.live_sport_compare_protocol_reserved_toast, protocolLabel(entry.protocol)),
                Toast.LENGTH_SHORT,
            ).show()
        }
        bindLatencyCard(card)
        if (started && activeTab == Tab.LATENCY) latencySlots[card]?.playIfAllowed()
        updateLatencyControls(card)
    }

    private fun refreshProtocolTabSelection(card: Int) {
        val row = protocolTabRows[card]
        for (i in 0 until row.childCount) {
            val chip = row.getChildAt(i) as TextView
            val selected = i == latencySelected[card]
            chip.isSelected = selected
            chip.setTextColor(if (selected) COLOR_CHIP_ACTIVE else COLOR_CHIP_INACTIVE)
        }
    }

    /** (Re)bind both latency cards to their currently selected protocols. */
    private fun bindLatencyStreams() {
        bindLatencyCard(0)
        bindLatencyCard(1)
    }

    /** (Re)bind a single latency card without disturbing the other one. */
    private fun bindLatencyCard(card: Int) {
        val entry = config?.latency?.getOrNull(latencySelected[card])
        val playerConfig = entry?.toPlayerConfig()
        latencySlots[card]?.bind(playerConfig)
        val reserved = entry?.protocol?.reserved == true || playerConfig == null
        latencyReservedHints[card].visibility = if (reserved) View.VISIBLE else View.GONE
        latencyOverlays[card].visibility = if (reserved) View.GONE else View.VISIBLE
        if (!reserved) {
            latencyOverlays[card].text = getString(
                R.string.live_sport_compare_latency_overlay,
                getString(R.string.live_sport_compare_no_data),
            )
        }
        updateLatencyControls(card)
    }

    private fun updateLatencyOverlay(card: Int, stats: SportPlayerStats) {
        latencyOverlays[card].text = getString(
            R.string.live_sport_compare_latency_overlay, stats.delayMs.toString(),
        )
    }

    private fun releaseLatency() {
        latencySlots.forEach { it?.release() }
        updateLatencyControls()
    }

    private fun updateLatencyControls() {
        latencySlots.indices.forEach { updateLatencyControls(it) }
    }

    private fun updateLatencyControls(card: Int) {
        updateSlotControls(latencySlots[card], latencyPlayButtons[card], latencyMuteButtons[card])
    }

    private fun protocolLabel(protocol: CompareProtocol): String = getString(
        when (protocol) {
            CompareProtocol.RTM -> R.string.live_sport_compare_protocol_rtm
            CompareProtocol.FLV_LOW_LATENCY -> R.string.live_sport_compare_protocol_flv_ll
            CompareProtocol.FLV -> R.string.live_sport_compare_protocol_flv
            CompareProtocol.HLS -> R.string.live_sport_compare_protocol_hls
            CompareProtocol.RTMPS -> R.string.live_sport_compare_protocol_rtmps
        }
    )

    // endregion

    // region tab 2 — enhance

    private fun bindEnhanceTab() {
        val content = findViewById<View>(R.id.content_enhance)
        enhanceProcessed = CompareSlot(this, content.findViewById<TextureView>(R.id.player_texture_processed))
        enhanceOrigin = CompareSlot(this, content.findViewById<TextureView>(R.id.player_texture_origin))
        enhancePlayButtons = arrayOf(
            content.findViewById(R.id.btn_play_pause_processed),
            content.findViewById(R.id.btn_play_pause_origin),
        )
        enhanceMuteButtons = arrayOf(
            content.findViewById(R.id.btn_mute_processed),
            content.findViewById(R.id.btn_mute_origin),
        )
        bindSlotControls({ enhanceProcessed }, enhancePlayButtons[0], enhanceMuteButtons[0])
        bindSlotControls({ enhanceOrigin }, enhancePlayButtons[1], enhanceMuteButtons[1])

        content.findViewById<View>(R.id.btn_view_doc).setOnClickListener { openDoc(config?.docUrlEnhance) }

        val srSwitch = content.findViewById<androidx.appcompat.widget.SwitchCompat>(R.id.switch_sr)
        val sharpenSwitch = content.findViewById<androidx.appcompat.widget.SwitchCompat>(R.id.switch_sharpen)
        srSwitch.isChecked = srOn
        sharpenSwitch.isChecked = sharpenOn
        // Only the processed player reacts; the original is untouched.
        srSwitch.setOnCheckedChangeListener { _, checked ->
            srOn = checked
            enhanceProcessed?.setSrEnabled(checked)
        }
        sharpenSwitch.setOnCheckedChangeListener { _, checked ->
            sharpenOn = checked
            enhanceProcessed?.setSharpenEnabled(checked)
        }
    }

    private fun bindEnhanceStreams() {
        val flv = config?.enhance
        enhanceProcessed?.bind(flv?.toPlayerConfig(enableSR = srOn, enableSharpen = sharpenOn))
        enhanceOrigin?.bind(flv?.toPlayerConfig())
        updateEnhanceControls()
    }

    private fun releaseEnhance() {
        enhanceProcessed?.release()
        enhanceOrigin?.release()
        updateEnhanceControls()
    }

    private fun updateEnhanceControls() {
        updateSlotControls(enhanceProcessed, enhancePlayButtons[0], enhanceMuteButtons[0])
        updateSlotControls(enhanceOrigin, enhancePlayButtons[1], enhanceMuteButtons[1])
    }

    // endregion

    // region tab 3 — cost

    private fun bindCostTab() {
        val content = findViewById<View>(R.id.content_cost)
        costH265 = CompareSlot(this, content.findViewById<TextureView>(R.id.player_texture_h265))
        costH264 = CompareSlot(this, content.findViewById<TextureView>(R.id.player_texture_h264))
        costBitrateOverlays = arrayOf(
            content.findViewById(R.id.bitrate_overlay_h265),
            content.findViewById(R.id.bitrate_overlay_h264),
        )
        costPlayButtons = arrayOf(
            content.findViewById(R.id.btn_play_pause_h265),
            content.findViewById(R.id.btn_play_pause_h264),
        )
        costMuteButtons = arrayOf(
            content.findViewById(R.id.btn_mute_h265),
            content.findViewById(R.id.btn_mute_h264),
        )
        costH265?.onStats = { stats -> updateCostOverlay(0, stats) }
        costH264?.onStats = { stats -> updateCostOverlay(1, stats) }
        bindSlotControls({ costH265 }, costPlayButtons[0], costMuteButtons[0])
        bindSlotControls({ costH264 }, costPlayButtons[1], costMuteButtons[1])

        content.findViewById<View>(R.id.btn_view_doc).setOnClickListener { openDoc(config?.docUrlCost) }

        subtabSameQuality = content.findViewById(R.id.subtab_same_quality)
        subtabSameBitrate = content.findViewById(R.id.subtab_same_bitrate)
        subtabSameQuality.setOnClickListener { onCostSubTabPicked(CostSubTab.SAME_QUALITY) }
        subtabSameBitrate.setOnClickListener { onCostSubTabPicked(CostSubTab.SAME_BITRATE) }
        refreshCostSubTabSelection()

        // Tapping a bitrate overlay opens the last-minute waveform.
        costBitrateOverlays[0].setOnClickListener { openBitrateChart(0) }
        costBitrateOverlays[1].setOnClickListener { openBitrateChart(1) }
    }

    private fun onCostSubTabPicked(sub: CostSubTab) {
        if (costSubTab == sub) return
        costSubTab = sub
        refreshCostSubTabSelection()
        bindCostStreams()
        if (started && activeTab == Tab.COST) { costH265?.playIfAllowed(); costH264?.playIfAllowed() }
        updateCostControls()
    }

    private fun refreshCostSubTabSelection() {
        subtabSameQuality.isSelected = costSubTab == CostSubTab.SAME_QUALITY
        subtabSameBitrate.isSelected = costSubTab == CostSubTab.SAME_BITRATE
        subtabSameQuality.setTextColor(
            if (costSubTab == CostSubTab.SAME_QUALITY) COLOR_CHIP_ACTIVE else COLOR_CHIP_INACTIVE
        )
        subtabSameBitrate.setTextColor(
            if (costSubTab == CostSubTab.SAME_BITRATE) COLOR_CHIP_ACTIVE else COLOR_CHIP_INACTIVE
        )
    }

    private fun bindCostStreams() {
        val pair = when (costSubTab) {
            CostSubTab.SAME_QUALITY -> config?.costSameQuality
            CostSubTab.SAME_BITRATE -> config?.costSameBitrate
        }
        costH265?.bind(pair?.h265?.toPlayerConfig())
        costH264?.bind(pair?.h264?.toPlayerConfig())
        for (i in 0..1) {
            costBitrateOverlays[i].text = getString(
                R.string.live_sport_compare_bitrate_overlay,
                getString(R.string.live_sport_compare_no_data),
            )
        }
        updateCostControls()
    }

    private fun updateCostOverlay(index: Int, stats: SportPlayerStats) {
        costBitrateOverlays[index].text = getString(
            R.string.live_sport_compare_bitrate_overlay, stats.bitrateKbps.toString(),
        )
        // Feed the live chart if it's tracking this slot.
        if (chartSlotIndex == index) chartDialog?.onSample(stats.bitrateKbps)
    }

    private fun openBitrateChart(index: Int) {
        val slot = if (index == 0) costH265 else costH264
        slot ?: return
        chartSlotIndex = index
        val dialog = BitrateChartDialog(this).also { chartDialog = it }
        dialog.setOnDismiss { chartSlotIndex = -1 }
        dialog.show(slot.bitrateHistory())
    }

    private fun releaseCost() {
        costH265?.release()
        costH264?.release()
        updateCostControls()
    }

    private fun updateCostControls() {
        updateSlotControls(costH265, costPlayButtons[0], costMuteButtons[0])
        updateSlotControls(costH264, costPlayButtons[1], costMuteButtons[1])
    }

    // endregion

    private fun openDoc(url: String?) {
        if (url.isNullOrEmpty()) return
        runCatching {
            startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
        }.onFailure {
            if (it is ActivityNotFoundException) {
                Toast.makeText(this, url, Toast.LENGTH_SHORT).show()
            }
        }
    }

    private fun dp(v: Int): Int = (v * resources.displayMetrics.density + 0.5f).toInt()

    companion object {
        private val COLOR_TAB_ACTIVE = 0xFF1664FF.toInt()
        private val COLOR_TAB_INACTIVE = 0xFF42464E.toInt()
        private val COLOR_CHIP_ACTIVE = 0xFF0066FC.toInt()
        private val COLOR_CHIP_INACTIVE = 0xFF737A87.toInt()
    }
}
