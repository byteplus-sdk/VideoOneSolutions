// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
package com.vertcdemo.login.fragment

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
import android.widget.Toast
import androidx.activity.OnBackPressedCallback
import androidx.core.view.ViewCompat
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import com.vertcdemo.core.net.SolutionRetrofit
import com.vertcdemo.core.utils.TextWatcherAdapter
import com.vertcdemo.login.BuildConfig
import com.vertcdemo.login.R
import com.vertcdemo.login.UserViewModel
import com.vertcdemo.login.databinding.FragmentLoginBinding
import com.vertcdemo.login.http.LoginApi
import com.vertcdemo.login.http.request.LoginRequest
import com.vertcdemo.login.utils.LengthFilterWithCallback
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.regex.Pattern

private const val INPUT_REGEX = "^[\\u4e00-\\u9fa5a-zA-Z0-9@_-]+$"

class LoginFragment : Fragment(R.layout.fragment_login) {

    private val userViewModel by activityViewModels<UserViewModel>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requireActivity().onBackPressedDispatcher.addCallback(
            this,
            object : OnBackPressedCallback(true) {
                override fun handleOnBackPressed() {
                    requireActivity().finish()
                }
            })
    }

    private val mTextWatcher: TextWatcherAdapter = object : TextWatcherAdapter() {
        override fun afterTextChanged(s: Editable) {
            setupConfirmStatus()
        }
    }

    private lateinit var mViewBinding: FragmentLoginBinding

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        WindowCompat.getInsetsController(
            requireActivity().window, view
        ).isAppearanceLightStatusBars = true

        mViewBinding = FragmentLoginBinding.bind(view)

        mViewBinding.verifyConfirm.setOnClickListener { onClickConfirm() }
        mViewBinding.verifyPolicy.text = spannedText
        mViewBinding.verifyPolicy.movementMethod = LinkMovementMethod.getInstance()
        val userNameFilter: InputFilter = LengthFilterWithCallback(18) { overflow: Boolean ->
            if (overflow) {
                mViewBinding.verifyInputUserNameWaringTv.visibility = View.VISIBLE
                mViewBinding.verifyInputUserNameWaringTv.text =
                    getString(R.string.content_limit, "18")
            } else {
                mViewBinding.verifyInputUserNameWaringTv.visibility = View.GONE
            }
        }
        mViewBinding.verifyPolicy.setOnCheckedChangeListener { _, _ -> setupConfirmStatus() }
        val userNameFilters = arrayOf(userNameFilter)
        mViewBinding.verifyInputUserNameEt.setFilters(userNameFilters)
        mViewBinding.verifyInputUserNameEt.addTextChangedListener(mTextWatcher)
        setupConfirmStatus()

        mViewBinding.appVersion.text =
            getString(R.string.login_app_version, BuildConfig.APP_VERSION)

        ViewCompat.setOnApplyWindowInsetsListener(mViewBinding.guidelineBottom) { _, windowInsets ->
            val insets = windowInsets.getInsets(WindowInsetsCompat.Type.systemBars())
            mViewBinding.guidelineBottom.setGuidelineEnd(insets.bottom)
            windowInsets
        }
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
                            ds.setColor(Color.parseColor("#346CF9"))
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
                            ds.setColor(Color.parseColor("#346CF9"))
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
            val isPolicyChecked = mViewBinding.verifyPolicy.isChecked
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

        lifecycleScope.launch {
            try {
                val login = withContext(Dispatchers.Default) {
                    SolutionRetrofit.getApi(LoginApi::class.java)
                        .login(LoginRequest.create(userName))
                }

                if (login == null) {
                    Toast.makeText(
                        requireContext(),
                        com.vertcdemo.base.R.string.network_message_1011,
                        Toast.LENGTH_LONG
                    ).show()
                    return@launch
                }

                userViewModel.onLoginSuccess(login.userName!!, login.userId!!, login.loginToken!!)

                findNavController()
                    .navigate(R.id.action_exit_login)
            } catch (e: Exception) {
                Toast.makeText(
                    requireContext(),
                    com.vertcdemo.base.R.string.network_message_1011,
                    Toast.LENGTH_SHORT
                ).show()
                mViewBinding.verifyConfirm.setEnabled(true)
            }
        }
    }

    private fun openBrowser(url: String) = startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
}