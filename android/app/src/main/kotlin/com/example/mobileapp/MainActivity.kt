package com.example.mobileapp

import android.os.Bundle
import android.util.Log
import androidx.activity.result.contract.ActivityResultContracts
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.SleepSessionRecord
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.android.FlutterFragmentActivity
import kotlinx.coroutines.launch

class MainActivity : FlutterFragmentActivity() {
    private lateinit var healthConnectClient: HealthConnectClient

    private val permissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        permissions.entries.forEach { entry ->
            val permissionName = entry.key
            val isGranted = entry.value
            if (isGranted) {
                Log.d("HealthConnect", "Permission granted: $permissionName")
            } else {
                Log.d("HealthConnect", "Permission denied: $permissionName")
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        try {
            healthConnectClient = HealthConnectClient.getOrCreate(this)
            checkPermissionsAndRun()
        } catch (e: Exception) {
            Log.e("HealthConnect", "Health Connect 초기화 실패: ${e.message}")
            e.printStackTrace()
        }
    }

    private fun checkPermissionsAndRun() {
        val permissions = setOf(
            HealthPermission.getReadPermission(SleepSessionRecord::class)
        )

        lifecycleScope.launch {
            try {
                val granted = healthConnectClient.permissionController.getGrantedPermissions()
                if (granted.containsAll(permissions)) {
                    Log.d("HealthConnect", "이미 모든 권한이 승인됨")
                } else {
                    Log.d("HealthConnect", "권한 요청 필요")
                    permissionLauncher.launch(permissions.toTypedArray())
                }
            } catch (e: Exception) {
                Log.e("HealthConnect", "권한 확인 실패: ${e.message}")
            }
        }
    }
}