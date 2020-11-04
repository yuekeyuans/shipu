package com.example.clock_in

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.os.StatFs
import android.provider.Settings
import android.widget.Toast
import androidx.core.content.FileProvider
import com.aspose.words.Document
import com.aspose.words.SaveFormat
import com.example.clock_in.BuildConfig.APPLICATION_ID

import io.flutter.plugins.GeneratedPluginRegistrant
import org.jsoup.Jsoup
import java.io.*
import java.util.*
import kotlin.collections.ArrayList
import kotlin.experimental.xor

import androidx.annotation.NonNull;
import io.flutter.Log
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;


class MainActivity : FlutterActivity() {
  private val ENCODE_TEXT = "encryption_type1"
  private val CHANNEL_CONVERTER = "com.example.clock_in/converter"
  private val CHANNEL_APP = "com.example.clock_in/app"
  private val CHANNEL_ENCODE = "com.example.clock_in/encription"
  private val CHANNEL_CLEAN = "com.example.clock_in/clean"
  private val CHANNEL_COPY_APP = "com.example.clock_in/copyApp"

  private var isConvertFinish = false
  private var appPath: String? = ""
  private var appPackage: String? = ""
  private val Tag = "com.example.clock_in"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    // 拷贝apk 文件
    MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_COPY_APP).setMethodCallHandler { call, result ->
      run {
        fun backupApp(path: String, outname: String, basePath: String) {
          val `in` = File(path)
          var mBaseFile = File(basePath)
          if (!mBaseFile.exists()) mBaseFile.mkdir()
          val out = File(mBaseFile, "$outname.apk")
          if (!out.exists()) out.createNewFile()
          val fis = FileInputStream(`in`)
          val fos = FileOutputStream(out)
          var count :Int
          val buffer = ByteArray(256 * 1024)
          while (fis.read(buffer).also { count = it } > 0) {
            fos.write(buffer, 0, count)
          }
          fis.close()
          fos.flush()
          fos.close()
        }

        fun backupUserApp(packageName: String, basePath: String) {
          var allPackages = packageManager.getInstalledPackages(0)
          for (packageInfo in allPackages) {
            if (packageInfo.packageName.equals(packageName)) {
              var path = packageInfo.applicationInfo.sourceDir
              var name = packageInfo.applicationInfo.loadLabel(packageManager).toString()
              try {
                backupApp(path, name, basePath)
                Log.d("backup succeed", path)
              } catch (e: Exception) {
                Log.e(Tag, path + "Failed backup  " + e.message)
              }
            }
          }
        }

        if (call.method.equals("backupApk")) {
          var packageName = call.argument<String>("packageName")
          var destPath = call.argument<String>("destPath")
          backupUserApp(packageName!!, destPath!!)
          result.success("backupSucceed")
        }
      }
    }
    // 获取存储大小
    MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_CLEAN).setMethodCallHandler { call, result ->
      run {
        val units = arrayOf("B", "KB", "MB", "GB", "TB")
        fun getUnit(s: Float): String {
          var size = s
          var index = 0
          while (size > 1024 && index < 4) {
            size = size / 1024
            index++
          }
          return String.format(Locale.getDefault(), " %.2f %s", size, units[index])
        }

        if (call.method.equals("avaliableSize")) {
          val statFs = StatFs(Environment.getExternalStorageDirectory().path)
          var availableCount = statFs.availableBytes
          result.success(getUnit((availableCount).toFloat()))
        }
      }
    }
    // 文件加密使用程序
    MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_ENCODE).setMethodCallHandler(MethodChannel.MethodCallHandler { call, result ->
      run {
        fun checkIsEncoded(src: String): Boolean {
          val inFile = File(src)
          if (inFile.exists()) {
            val input = inFile.inputStream()
            var simpleEncode = ENCODE_TEXT.toByteArray()
            var byte = ByteArray(simpleEncode.size)
            input.read(byte, 0, simpleEncode.size).toString()
            if (byte.contentEquals(simpleEncode)) {
              return true
            }
          }
          return false
        }

        fun encodeFile(src: String?, dest: String?, magic: Byte): Boolean {
          val inFile = File(src)
          val outFile = File(dest)
          if (!inFile.exists()) return false
          if (!outFile.exists()) outFile.createNewFile()
          if (checkIsEncoded(src!!)) { // 已加密，直接拷贝
            outFile.writeBytes(inFile.readBytes())
            return true
          }

          // 未加密，加密拷贝
          val input = inFile.inputStream()
          val output = outFile.outputStream()
          var simpleEncode = ENCODE_TEXT.toByteArray()
          output.write(simpleEncode)
          output.write(Int.MAX_VALUE)
          output.write(magic.toInt())
          output.write(Int.MAX_VALUE)

          var c = -1
          val buffer = ByteArray(1024 * 1000)
          while ({ c = input.read(buffer);c }() > 0) {
            var i = 0
            while (i < c) {
              buffer[i] = buffer[i] xor magic
              i++
            }
            output.write(buffer.copyOfRange(0, c))
          }

          input.close()
          output.flush()
          output.close()
          return true
        }

        fun decodeFile(src: String?, dest: String?): Boolean {
          val inFile = File(src)
          val outFile = File(dest)
          if (!inFile.exists()) return false
          if (!outFile.exists()) outFile.createNewFile()
          if (!checkIsEncoded(src!!)) {
            outFile.writeBytes(inFile.readBytes())
            return true
          }

          val input = inFile.inputStream()
          val output = outFile.outputStream()
          var simpleEncode = ENCODE_TEXT.toByteArray()
          var byte = ByteArray(simpleEncode.size)
          input.read(byte, 0, simpleEncode.size).toString()
          if (!byte.contentEquals(simpleEncode)) {
            return false
          }
          input.read()
          val magic = input.read()
          input.read()

          var c = -1
          val buffer = ByteArray(1024 * 1024)
          var magics = magic.toByte()
          while ({ c = input.read(buffer);c }() > 0) {
            var i = 0
            while (i < c) {
              buffer[i] = buffer[i] xor magics
              i++
            }
            output.write(buffer.copyOfRange(0, c))
          }
          input.close()
          output.flush()
          output.close()
          return true
        }

        var name = call.method
        when {
          name.equals("encode") -> {
            val src = call.argument<String>("src")
            val dest = call.argument<String>("dest")
            var magic = Random().nextInt().toByte().toInt()
            if (call.hasArgument("magic")) {
              magic = call.argument<Int>("magic")!!
            }
            encodeFile(src, dest, magic.toByte())
          }
          name.equals("decode") -> {
            val src = call.argument<String>("src")
            val dest = call.argument<String>("dest")
            decodeFile(src, dest)
          }
          name.equals("isEncoded") -> {
            val path = call.argument<String>("src");
            result.success(checkIsEncoded(path!!))
          }
          else -> {
          }
        }
      }
    })
    //  程序安装获取信息的channel
    MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_APP).setMethodCallHandler(MethodChannel.MethodCallHandler { call, result ->
      run {
        // 获取app 信息
        fun getInstalledApps(): ArrayList<String>? {
          val res = ArrayList<String>()
          val packs = this.packageManager.getInstalledPackages(0)
          for (i in packs.indices) {
            res.add(packs[i].packageName)
          }
          return res
        }

        // 启动程序
        fun startApp() {
          startActivity(this.packageManager.getLaunchIntentForPackage(appPackage!!))
        }

        // 安装程序
        fun installApp() {
          var pFile = File(appPath)
          if (!pFile.exists()) return
          val _Intent = Intent()
          _Intent.action = Intent.ACTION_VIEW
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
              val hasInstallPermission = this.packageManager.canRequestPackageInstalls()
              if (!hasInstallPermission) {
                val packageURI = Uri.parse("package:" + packageName)
                val intent = Intent(Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES, packageURI)
                startActivityForResult(intent, 10001)
              } else {
                val apkUri = FileProvider.getUriForFile(this, this.packageName.toString() + ".fileProvider", pFile)
                val install = Intent(Intent.ACTION_VIEW)
                install.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                install.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                install.setDataAndType(apkUri, "application/vnd.android.package-archive")
                startActivity(install)
              }
            } else {
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
        if (method.equals("isInstalled")) {
          var apps = getInstalledApps()
          result.success(apps.toString())
        } else if (method.equals("startApp")) {
          appPackage = call.argument<String>("package")
          startApp()
        } else if (method.equals("installIsilo")) {
          appPath = call.argument<String>("path")
          installApp()
          result.success(appPath)
        }
      }
    })
    // 转换文件的 channel
    MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL_CONVERTER).setMethodCallHandler(MethodChannel.MethodCallHandler { call, result ->
      run {
        fun textConvertToPunyCode(src:String?){
          result.success(PunyCodeUtil.chinese2punycode(src))
        }

        fun punyCodeConvertToText(src:String?){
          result.success(PunyCodeUtil.punycode2chinese(src));
        }

        fun htmlConvertToText(src: String?) {
          var html = File(src).readText()
          val text: String? = Jsoup.parse(html).text()
          var outFile = File(src + ".txt")
          outFile.createNewFile()
          outFile.writeText(text!!)
          result.success(text)
        }


        fun docConvertToHtml(fromPath: String?, toPath: String?) {
          this.isConvertFinish = false
          if (fromPath != null) {
            Thread {
              val file = File(fromPath)
              if (!file.exists()) {
                result.error("0", "file not fond", "cant find the file")
              }
              val stream = FileInputStream(fromPath)
              val document = Document(stream)
              document.save(toPath, SaveFormat.HTML)
              stream.close()
              this.isConvertFinish = true
            }.start()
            result.success("true")
          }
        }

        fun docConvertProcess() = if (this.isConvertFinish) {
          isConvertFinish = false
          result.success(true)
        } else {
          result.success(false)
        }

        val method = call.method
        when {
          method.equals("convertDocToHtml") -> {
            val fromPath = call.argument<String>("fromPath")
            val toPath = call.argument<String>("toPath")
            docConvertToHtml(fromPath, toPath);
          }
          method.equals("convertDocToHtmlProcess") -> {
            docConvertProcess()
          }
          method.equals("htmlConvertToText") -> {
            htmlConvertToText(call.argument<String>("src"))
          }
          method.equals("textConvertToPunyCode") -> {
            textConvertToPunyCode(call.argument<String>("src"))
          }
          method.equals("punyCodeConvertToText") -> {
            punyCodeConvertToText(call.argument<String>("src"))
          }
          else -> {
            result.notImplemented()
          }
        }
      }
    })
  }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
      if (resultCode == 10001) {
        val apkUri = FileProvider.getUriForFile(this, APPLICATION_ID + ".fileProvider", File(appPath)) // 在AndroidManifest中的android:authorities值
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
