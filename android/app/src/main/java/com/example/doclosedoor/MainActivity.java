package com.example.doclosedoor;

import io.flutter.embedding.android.FlutterActivity;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import android.os.PowerManager;
import android.os.PowerManager.WakeLock;

public class MainActivity extends FlutterActivity {
  private static final String CHANNEL = "flutter.dev/PowerManager/Wakelock";

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    super.configureFlutterEngine(flutterEngine);

    PowerManager pwrManager = (PowerManager) getSystemService(POWER_SERVICE);
    WakeLock wakeLock = pwrManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "Wakelock");

    new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
      .setMethodCallHandler(
        (call, result) -> {
          if (call.method.equals("acquire")) {
            if (! wakeLock.isHeld()) {
              wakeLock.acquire();
            }
            System.out.println("[Debug] WakeLock lock!");
            result.success(true);
          } else if (call.method.equals("release")) {
            if (wakeLock.isHeld()){
              wakeLock.release();
            }
            System.out.println("[Debug] WakeLock release!");
            result.success(true);
          } else if (call.method.equals("isHeld")) {
            result.success(wakeLock.isHeld());
          }else {
            result.notImplemented();
          }
        }
      );
  }
}
