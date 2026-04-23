package com.byteplus.aichat

import android.os.Bundle
import androidx.activity.enableEdgeToEdge
import androidx.appcompat.app.AppCompatActivity
import com.vertcdemo.core.utils.fixNavigationBar

class AiChatActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        enableEdgeToEdge()
        fixNavigationBar()

        setContentView(R.layout.activity_ai_chat)
    }
}