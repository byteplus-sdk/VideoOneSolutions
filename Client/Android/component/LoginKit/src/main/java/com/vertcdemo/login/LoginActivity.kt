// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.login

import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.text.Editable
import android.text.InputFilter
import android.text.Spannable
import android.text.SpannableStringBuilder
import android.text.TextPaint
import android.text.TextUtils
import android.text.method.LinkMovementMethod
import android.text.style.ClickableSpan
import android.view.View
import android.widget.CompoundButton
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.vertcdemo.core.SolutionDataManager
import com.vertcdemo.core.entity.LoginInfo
import com.vertcdemo.core.event.RefreshUserNameEvent
import com.vertcdemo.core.eventbus.SolutionEventBus
import com.vertcdemo.core.net.IRequestCallback
import com.vertcdemo.core.net.ServerResponse
import com.vertcdemo.core.utils.Activities.transparentStatusBar
import com.vertcdemo.core.utils.IMEUtils
import com.vertcdemo.core.utils.TextWatcherAdapter
import com.vertcdemo.login.databinding.ActivityLoginBinding
import com.vertcdemo.login.net.LoginApi
import com.vertcdemo.login.utils.LengthFilterWithCallback
import java.util.regex.Pattern

private const val INPUT_REGEX = "^[\\u4e00-\\u9fa5a-zA-Z0-9@_-]+$"

class LoginActivity : AppCompatActivity() {

    private val mTextWatcher: TextWatcherAdapter = object : TextWatcherAdapter() {
        override fun afterTextChanged(s: Editable) {
            setupConfirmStatus()
        }
    }

    private lateinit var mViewBinding: ActivityLoginBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        transparentStatusBar(this)
        mViewBinding = ActivityLoginBinding.inflate(layoutInflater)
        setContentView(mViewBinding.getRoot())
        mViewBinding.verifyConfirm.setOnClickListener { onClickConfirm() }
        mViewBinding.verifyRootLayout.setOnClickListener { IMEUtils.closeIME(it) }
        mViewBinding.verifyPolicyText.setOnClickListener { mViewBinding.verifyCb.toggle() }
        mViewBinding.verifyPolicyText.text = spannedText
        mViewBinding.verifyPolicyText.movementMethod = LinkMovementMethod.getInstance()
        val userNameFilter: InputFilter = LengthFilterWithCallback(18) { overflow: Boolean ->
            if (overflow) {
                mViewBinding.verifyInputUserNameWaringTv.visibility = View.VISIBLE
                mViewBinding.verifyInputUserNameWaringTv.text =
                    getString(R.string.content_limit, "18")
            } else {
                mViewBinding.verifyInputUserNameWaringTv.visibility = View.GONE
            }
        }
        val userNameFilters = arrayOf(userNameFilter)
        mViewBinding.verifyInputUserNameEt.setFilters(userNameFilters)
        mViewBinding.verifyInputUserNameEt.addTextChangedListener(mTextWatcher)
        mViewBinding.verifyCb.setOnCheckedChangeListener { v: CompoundButton?, isChecked: Boolean -> setupConfirmStatus() }
        setupConfirmStatus()
    }

    private val spannedText: CharSequence
        get() {
            val termsOfService = getString(R.string.login_terms_of_service)
            val privacyPolicy = getString(R.string.login_privacy_policy)
            val completeTip = getString(R.string.read_and_agree, termsOfService, privacyPolicy)
            val ssb = SpannableStringBuilder(completeTip)
            val termsIndex = completeTip.indexOf(termsOfService)
            if (termsIndex >= 0) {
                ssb.setSpan(
                    object : ClickableSpan() {
                        override fun onClick(widget: View) {
                            openBrowser(BuildConfig.TERMS_OF_SERVICE_URL)
                        }

                        override fun updateDrawState(ds: TextPaint) {
                            ds.setColor(Color.parseColor("#4080FF"))
                            ds.isUnderlineText = false
                        }
                    },
                    termsIndex,
                    termsIndex + termsOfService.length,
                    Spannable.SPAN_INCLUSIVE_INCLUSIVE
                )
            }
            val policyIndex = completeTip.indexOf(privacyPolicy)
            if (policyIndex >= 0) {
                ssb.setSpan(
                    object : ClickableSpan() {
                        override fun onClick(widget: View) {
                            openBrowser(BuildConfig.PRIVACY_POLICY_URL)
                        }

                        override fun updateDrawState(ds: TextPaint) {
                            ds.setColor(Color.parseColor("#4080FF"))
                            ds.isUnderlineText = false
                        }
                    },
                    policyIndex,
                    policyIndex + privacyPolicy.length,
                    Spannable.SPAN_INCLUSIVE_INCLUSIVE
                )
            }
            return ssb
        }

    private fun setupConfirmStatus() {
        val userName = mViewBinding.verifyInputUserNameEt.getText().toString().trim { it <= ' ' }
        if (TextUtils.isEmpty(userName)) {
            mViewBinding.verifyConfirm.setAlpha(0.3f)
            mViewBinding.verifyConfirm.setEnabled(false)
        } else {
            val matchRegex = Pattern.matches(INPUT_REGEX, userName)
            val isPolicyChecked = mViewBinding.verifyCb.isChecked
            if (isPolicyChecked && matchRegex) {
                mViewBinding.verifyConfirm.setEnabled(true)
                mViewBinding.verifyConfirm.setAlpha(1f)
            } else {
                if (!matchRegex) {
                    mViewBinding.verifyInputUserNameWaringTv.visibility = View.VISIBLE
                    mViewBinding.verifyInputUserNameWaringTv.text =
                        getString(R.string.content_limit, "18")
                }
                mViewBinding.verifyConfirm.setAlpha(0.3f)
                mViewBinding.verifyConfirm.setEnabled(false)
            }
        }
    }

    private fun onClickConfirm() {
        val userName = mViewBinding.verifyInputUserNameEt.getText().toString().trim { it <= ' ' }
        mViewBinding.verifyConfirm.setEnabled(false)
        IMEUtils.closeIME(mViewBinding.verifyConfirm)
        LoginApi.passwordFreeLogin(
            userName,
            object : IRequestCallback<ServerResponse<LoginInfo>> {
                override fun onSuccess(data: ServerResponse<LoginInfo>) {
                    val login = data.data
                    if (login == null) {
                        Toast.makeText(
                            this@LoginActivity,
                            com.vertcdemo.base.R.string.network_message_1011,
                            Toast.LENGTH_SHORT
                        ).show()
                        return
                    }
                    mViewBinding.verifyConfirm.setEnabled(true)
                    SolutionDataManager.ins().let {
                        it.userName = login.userName
                        it.userId = login.userId
                        it.token = login.loginToken
                    }
                    SolutionEventBus.post(RefreshUserNameEvent(login.userName!!, true))
                    setResult(RESULT_OK)
                    finish()
                }

                override fun onError(errorCode: Int, message: String?) {
                    Toast.makeText(
                        this@LoginActivity,
                        com.vertcdemo.base.R.string.network_message_1011,
                        Toast.LENGTH_SHORT
                    ).show()
                    mViewBinding.verifyConfirm.setEnabled(true)
                }
            })
    }

    private fun openBrowser(url: String) = startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))

}
