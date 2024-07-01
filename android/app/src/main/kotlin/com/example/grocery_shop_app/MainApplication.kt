package com.example.grocery_shop_app

import android.app.Application
import com.yandex.mapkit.MapKitFactory

class MainApplication: Application() {
    override fun onCreate() {
        super.onCreate() // Your preferred language. Not required, defaults to system language
        MapKitFactory.setApiKey("bb17504a-c3dc-4879-b193-4605d9fbbf41")// Your generated API key
    }
}