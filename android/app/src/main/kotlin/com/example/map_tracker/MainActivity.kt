package com.example.map_tracker

//import android.support.annotation.NonNull
//import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivity
//import io.flutter.embedding.engine.FlutterEngine
import androidx.annotation.NonNull
//import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
//import com.yandex.mapkit.MapKitFactory
import com.yandex.mapkit.MapKitFactory
//import com.ryanheise.audioservice.AudioServicePlugin

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        MapKitFactory.setApiKey("0ac77cdb-3bfc-440f-bacd-51541547420d") // Your generated API key
        //return AudioServicePlugin.getFlutterEngine(context)
        super.configureFlutterEngine(flutterEngine)
    }
}