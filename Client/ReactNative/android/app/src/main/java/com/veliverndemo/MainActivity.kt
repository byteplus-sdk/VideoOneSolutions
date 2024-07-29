package com.veliverndemo

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.facebook.react.ReactActivity
import com.facebook.react.ReactActivityDelegate
import com.facebook.react.defaults.DefaultNewArchitectureEntryPoint.fabricEnabled
import com.facebook.react.defaults.DefaultReactActivityDelegate
import android.content.Intent
import android.content.res.Configuration


class MainActivity : ReactActivity() {
  private fun checkPermission(activity: Activity, request: Int): Boolean {
    val permissions = arrayOf(
      Manifest.permission.CAMERA,
      Manifest.permission.RECORD_AUDIO,
      Manifest.permission.READ_PHONE_STATE,
      Manifest.permission.MODIFY_AUDIO_SETTINGS,
      Manifest.permission.ACCESS_NETWORK_STATE,
      Manifest.permission.WRITE_EXTERNAL_STORAGE,
      Manifest.permission.READ_EXTERNAL_STORAGE,
      Manifest.permission.FOREGROUND_SERVICE,
    )
    val sAppContext = this.applicationContext
    val permissionList: MutableList<String> = ArrayList()
    for (permission in permissions) {
      val granted = ContextCompat.checkSelfPermission(
        sAppContext,
        permission
      ) == PackageManager.PERMISSION_GRANTED
      if (granted) continue
      permissionList.add(permission)
    }
    if (permissionList.size == 0) return true
    ActivityCompat.requestPermissions(activity, permissionList.toTypedArray(), request)
    return false
  }

  /**
   * Returns the name of the main component registered from JavaScript. This is used to schedule
   * rendering of the component.
   */
  override fun getMainComponentName(): String = "VeLiveRnDemo"

  /**
   * Returns the instance of the [ReactActivityDelegate]. We use [DefaultReactActivityDelegate]
   * which allows you to enable New Architecture with a single boolean flags [fabricEnabled]
   */
  override fun createReactActivityDelegate(): ReactActivityDelegate =
      DefaultReactActivityDelegate(this, mainComponentName, fabricEnabled)
  
  override fun onConfigurationChanged(newConfig: Configuration) {
    super.onConfigurationChanged(newConfig)
    val intent = Intent("onConfigurationChanged")
    intent.putExtra("newConfig", newConfig)
    sendBroadcast(intent)
  }

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState);
    this.checkPermission(this, 10010)
  }
}
