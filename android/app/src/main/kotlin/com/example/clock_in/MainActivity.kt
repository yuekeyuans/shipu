package com.example.clock_in

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.os.StatFs
import android.provider.Settings
import android.widget.Toast
import androidx.core.content.FileProvider
import com.aspose.words.Document
import com.aspose.words.SaveFormat
import com.example.clock_in.BuildConfig.*
import io.flutter.Log
import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream
import java.util.*
import kotlin.collections.ArrayList

class MainActivity: FlutterActivity() {
  val ENCODE_TEXT = "encryption_type1"

  private val CHANNEL_CONVERTER = "com.example.clock_in/converter"
  private val CHANNEL_ISILO = "com.example.clock_in/isilo"
  private val CHANNEL_WIFI = "com.example.clock_in/wifi"
  private val CHANNEL_ENCODE = "com.example.clock_in/encription"
  private val CHANNEL_CLEAN = "com.example.clock_in/clean"
  private val CHANNEL_COPY_APP = "com.example.clock_in/copyApp"

  private var isConvertFinish =false
  private var appPath:String? = ""
  private val Tag = "com.example.clock_in"

  override fun onCreate(savedInstanceState: Bundle?) {

    super.onCreate(savedInstanceState)
    GeneratedPluginRegistrant.registerWith(this)



    //拷贝apk 文件
    MethodChannel(flutterView, CHANNEL_COPY_APP).setMethodCallHandler{call, result->
      run {
        fun backupApp(path: String, outname: String, basePath:String) {
          val `in` = File(path)
          var mBaseFile = File(basePath)
          if (!mBaseFile.exists()) mBaseFile.mkdir()
          val out = File(mBaseFile, "$outname.apk")
          if (!out.exists()) out.createNewFile()
          val fis = FileInputStream(`in`)
          val fos = FileOutputStream(out)
          var count: Int = 0;
          val buffer = ByteArray(256 * 1024)
          while (fis.read(buffer).also { count = it } > 0) {
            fos.write(buffer, 0, count)
          }
          fis.close()
          fos.flush()
          fos.close()
        }

        fun backupUserApp(packageName:String, basePath:String) {
          var allPackages = packageManager.getInstalledPackages(0);
          for (packageInfo in allPackages) {
            if(packageInfo.packageName.equals(packageName)) {
              var path = packageInfo.applicationInfo.sourceDir;
              var name = packageInfo.applicationInfo.loadLabel(packageManager).toString();
              try {
                backupApp(path, name, basePath);
                Log.d("backup succeed", path)
              } catch (e: Exception) {
                Log.e(Tag, path + "Failed backup  " + e.message)
              }
            }
          }
        }

        if(call.method.equals("backupApk")){
          var packageName = call.argument<String>("packageName")
          var destPath = call.argument<String>("destPath")
          backupUserApp(packageName!!, destPath!!)
          result.success("backupSucceed")
        }
      }
    }
    //获取存储大小
    MethodChannel(flutterView, CHANNEL_CLEAN).setMethodCallHandler{call, result->
      run{
        val  units = arrayOf("B", "KB", "MB", "GB", "TB")
        fun getUnit(s:Float):String {
          var size = s
          var index = 0
          while (size > 1024 && index < 4) {
            size = size / 1024
            index++
          }
          return String.format(Locale.getDefault(), " %.2f %s", size, units[index])
        }

        if(call.method.equals("avaliableSize")){
          val statFs = StatFs(Environment.getExternalStorageDirectory().path)
          var blockSize = statFs.blockSizeLong
          var availableCount = statFs.availableBytes
          result.success(getUnit((availableCount).toFloat()))
        }
      }
    }
    // 文件加密使用程序
    MethodChannel(flutterView, CHANNEL_ENCODE).setMethodCallHandler(MethodChannel.MethodCallHandler { call, result ->
      run {
        fun checkIsEncoded(src:String):Boolean{
          val inFile = File(src)
          if(inFile.exists()){
            val input = inFile.inputStream()
            var simpleEncode = ENCODE_TEXT.toByteArray()
            var byte = ByteArray(simpleEncode.size)
            if(input.read(byte, 0, simpleEncode.size).toString() == simpleEncode.toString()) {
              return true
            }
          }
          return false
        }


        fun encodeFile(src:String?, dest:String?, magic:Int):Boolean{
          val inFile = File(src)
          val outFile = File(dest)
          if(!inFile.exists()) return false
          if(!outFile.exists()) outFile.createNewFile()
          if(checkIsEncoded(src!!)){    //已加密，直接拷贝
            outFile.writeBytes(inFile.readBytes())
            return true
          }

          // 未加密，加密拷贝
          val input = inFile.inputStream()
          val output = outFile.outputStream()
          var simpleEncode = ENCODE_TEXT.toByteArray()
          output.write(simpleEncode)
          output.write(Int.MAX_VALUE)
          output.write(magic)
          output.write(Int.MAX_VALUE)
          var data :Int = input.read()
          while(data > -1){
            output.write((data xor magic))
            data = input.read()
          }

          input.close()
          output.flush()
          output.close()
          return true
        }
        fun decodeFile(src:String?, dest:String?):Boolean{
          val inFile = File(src)
          val outFile = File(dest)
          if(!inFile.exists()) return false
          if(!outFile.exists()) outFile.createNewFile()
          if(!checkIsEncoded(src!!)){
            outFile.writeBytes(inFile.readBytes())
            return true
          }

          val input = inFile.inputStream()
          val output = outFile.outputStream()
          var simpleEncode = ENCODE_TEXT.toByteArray()
          var byte = ByteArray(simpleEncode.size)
          if(input.read(byte, 0, simpleEncode.size).toString() != simpleEncode.toString()){
            return false
          }
          input.read()
          val magic = input.read()
          input .read()

          var data :Int = input.read()
          while(data > -1){
            output.write((data xor magic))
            data = input.read()
          }
          input.close()
          output.flush()
          output.close()
          return true
        }

        var name = call.method
        if(name.equals("encode") || name.equals("decode")){
          val src = call.argument<String>("src")
          val dest = call.argument<String>("dest")
          if(name.equals("encode")){
            var magic = Random().nextInt()
            if(call.hasArgument("magic")){
              magic = call.argument<Int>("magic")!!
            }
            encodeFile(src, dest, magic)
          }else{
            decodeFile(src,dest)
          }
          result.success("success")
        }
      }
    })
    //  程序安装获取信息的channel
    MethodChannel(flutterView, CHANNEL_ISILO).setMethodCallHandler(MethodChannel.MethodCallHandler{call, result->
      run{
        //获取app 信息
        fun getInstalledApps(): ArrayList<String>? {
          val res = ArrayList<String>()
          val packs = this.packageManager.getInstalledPackages(0)
          for (i in packs.indices) {
            res.add(packs[i].packageName)
          }
          return res
        }
        //启动程序
        fun startIsiloApp(){
          val packageName = "com.dcco.app.iSilo"
          startActivity(this.packageManager.getLaunchIntentForPackage(packageName))
        }

        //安装程序
        fun installApp() {
          var pFile = File(appPath)
          if (!pFile.exists()) return
          val _Intent = Intent()
          _Intent.action = Intent.ACTION_VIEW
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O){
              val hasInstallPermission = this.packageManager.canRequestPackageInstalls()
              if(!hasInstallPermission){
                val packageURI = Uri.parse("package:" + packageName)
                val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, packageURI)
                startActivityForResult(intent, 10001)
              }else{
                val apkUri = FileProvider.getUriForFile(this, this.packageName.toString() + ".fileProvider", pFile)
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
          result.success(apps.toString())
        }else if(method.equals("startIsilo")){
          startIsiloApp()
        }else if(method.equals("installIsilo")){
          appPath = call.argument<String>("path")
          installApp()
          result.success(appPath)
        }
      }
    })
    // 转换文件的 channel
    MethodChannel(flutterView,CHANNEL_CONVERTER).setMethodCallHandler(MethodChannel.MethodCallHandler { call, result ->
      run {
        val method = call.method
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
              val document = Document(stream)
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
        val apkUri = FileProvider.getUriForFile(this, APPLICATION_ID + ".fileProvider",File(appPath)) //在AndroidManifest中的android:authorities值
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
