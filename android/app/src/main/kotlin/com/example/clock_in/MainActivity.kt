package com.example.clock_in

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.net.ConnectivityManager
import android.net.Uri
import android.net.wifi.WifiConfiguration
import android.net.wifi.WifiManager
import android.net.wifi.p2p.WifiP2pManager
import android.net.wifi.p2p.WifiP2pManager.Channel
import android.os.Build
import android.os.Bundle
import android.os.Looper
import android.os.ResultReceiver
import android.provider.Settings
import android.widget.Toast
import androidx.core.content.FileProvider
import com.aspose.words.SaveFormat
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File
import java.io.FileInputStream
import java.lang.reflect.Field
import java.lang.reflect.InvocationTargetException


class MainActivity: FlutterActivity() {
  private val CHANNEL_CONVERTER = "com.example.clock_in/converter"
  private val CHANNEL_ISILO = "com.example.clock_in/isilo"
  private val CHANNEL_WIFI = "com.example.clock_in/wifi"
  private var isConvertFinish =false;
  private var appPath:String? = "";
  private val Tag = "com.example.clock_in"



  override fun onCreate(savedInstanceState: Bundle?) {


    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)
    
    //  程序安装获取信息的channel
    MethodChannel(flutterView, CHANNEL_ISILO).setMethodCallHandler(MethodChannel.MethodCallHandler{call, result->
      run{
        //获取app 信息
        fun getInstalledApps(): ArrayList<String>? {
          val res = ArrayList<String>()
          val packs = this.getPackageManager().getInstalledPackages(0)
          for (i in packs.indices) {
            res.add(packs[i].packageName)
          }
          return res
        }
        //启动程序
        fun startIsiloApp(){
          val packageName = "com.dcco.app.iSilo";
          startActivity(this.packageManager.getLaunchIntentForPackage(packageName))
        }

        //安装程序
        fun installApp() {
          var pFile = File(appPath)
          if (!pFile.exists()) return
          val _Intent = Intent()
          _Intent.action = Intent.ACTION_VIEW
          val _uri: Uri
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
              val hasInstallPermission = this.packageManager.canRequestPackageInstalls();
              if(!hasInstallPermission){
                val packageURI = Uri.parse("package:" + packageName)
                val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, packageURI)
                startActivityForResult(intent, 10001)
              }else{
                val apkUri = FileProvider.getUriForFile(this, this.getPackageName().toString() + ".fileProvider", pFile)
                val install = Intent(Intent.ACTION_VIEW)
                install.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                install.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                install.setDataAndType(apkUri, "application/vnd.android.package-archive")
                startActivity(install)
              }
            }else{
              val apkUri = FileProvider.getUriForFile(this, "com.example.clock_in" + ".fileProvider", pFile)
              val install = Intent(Intent.ACTION_VIEW)
              install.flags = Intent.FLAG_ACTIVITY_NEW_TASK
              install.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
              install.setDataAndType(apkUri, "application/vnd.android.package-archive")
              startActivity(install)
            }
          } else {
            val install = Intent(Intent.ACTION_VIEW)
            install.setDataAndType(Uri.fromFile(pFile), "application/vnd.android.package-archive")
            install.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            startActivity(install)
          }
        }

        var method = call.method
        if(method.equals("isInstalled")){
          var apps = getInstalledApps()
          result.success(apps.toString());
        }else if(method.equals("startIsilo")){
          startIsiloApp();
        }else if(method.equals("installIsilo")){
          appPath = call.argument<String>("path")
          installApp();
          result.success(appPath)
        }
      }
    })
    // 转换文件的 channel
    MethodChannel(flutterView,CHANNEL_CONVERTER).setMethodCallHandler(MethodChannel.MethodCallHandler { call, result ->
      run {
        val method = call.method;
        if (method.equals("convertToHtml")) {
          this.isConvertFinish = false
          val path = call.argument<String>("path")
          if (path != null) {
            Thread {
              val file = File(path)
              if (!file.exists()) {
                    result.error("0", "file not fond", "cant find the file")
              }
              val stream = FileInputStream(path)
              val document = com.aspose.words.Document(stream)
              stream.close()
              document.save(path + ".html", SaveFormat.HTML)
              this.isConvertFinish = true
            }.start()
            result.success("true")
          }
        } else if(call.method.equals("convertProcess")){
            if(this.isConvertFinish){
              isConvertFinish = false
              result.success("true")
            }else{
              result.success("false")
            }
        }else{
          result.notImplemented()
        }
      }
    })
  }


  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
      if (resultCode == 10001) {
        val apkUri = FileProvider.getUriForFile(this, BuildConfig.APPLICATION_ID + ".fileProvider",File(appPath)) //在AndroidManifest中的android:authorities值
        val install = Intent(Intent.ACTION_VIEW)
        install.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        install.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        install.setDataAndType(apkUri, "application/vnd.android.package-archive")
        this.startActivity(install)
      } else {
        Toast.makeText(this, "未打开'安装未知来源'开关,无法安装,请打开后重试", Toast.LENGTH_SHORT)
      }
  }

}
