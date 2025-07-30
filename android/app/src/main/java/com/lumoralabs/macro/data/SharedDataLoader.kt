package com.lumoralabs.macro.data

import android.content.Context
import org.json.JSONObject
import java.io.IOException

object SharedDataLoader {
    fun loadJsonFromAsset(context: Context, fileName: String): JSONObject? {
        return try {
            val inputStream = context.assets.open("shared/data/$fileName")
            val size = inputStream.available()
            val buffer = ByteArray(size)
            inputStream.read(buffer)
            inputStream.close()
            val json = String(buffer, Charsets.UTF_8)
            JSONObject(json)
        } catch (ex: IOException) {
            ex.printStackTrace()
            null
        }
    }
}
