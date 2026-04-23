// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

package com.vertcdemo.login

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import com.vertcdemo.core.SolutionDataManager
import com.vertcdemo.core.event.AppLoginEvent
import com.vertcdemo.core.eventbus.SolutionEventBus

data class User(
    val userId: String,
    val userName: String
)

class UserViewModel : ViewModel() {
    val user: LiveData<User>
        get() = _user

    val logged: LiveData<Boolean>
        get() = _logged


    fun logout() {
        _logged.value = false
        _user.value = User("", "")

        SolutionDataManager.logout()
    }

    fun closeAccount() {
        deleteAccount()
        logout()
    }

    fun onLoginSuccess(userName: String, userId: String, token: String) {
        SolutionDataManager.ins().let {
            it.userName = userName
            it.userId = userId
            it.token = token
        }

        _user.value = User(userId, userName)
        _logged.value = true
        SolutionEventBus.post(AppLoginEvent())
    }

    private val _user = MutableLiveData(
        User(
            userId = SolutionDataManager.userId!!,
            userName = SolutionDataManager.userName!!,
        )
    )

    private val _logged = MutableLiveData(SolutionDataManager.token?.isNotEmpty() == true)

    private fun deleteAccount() {
        // Open source code not support, no account recorded
    }
}