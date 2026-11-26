package com.zeroboard.zeroboard;

import android.content.ContentValues;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.net.Uri;
import android.os.Build;
import android.provider.MediaStore;
import android.util.AtomicFile;
import android.util.Base64;
import android.view.WindowInsets;
import android.widget.FrameLayout;
import android.webkit.JavascriptInterface;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebResourceRequest;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import org.json.JSONTokener;
import org.json.JSONObject;

public final class MainActivity extends FlutterActivity {
    private static final String EDITOR_URL = "file:///android_asset/index.html";
    private static final int PICK_FILE = 701;
    private WebView editor;
    private ValueCallback<Uri[]> picker;

    @Override
    public void configureFlutterEngine(FlutterEngine engine) {
        super.configureFlutterEngine(engine);
        engine.getDartExecutor().getBinaryMessenger().setMessageHandler(
            "zeroboard/editor", (message, reply) -> {
                if (editor == null) attachEditor();
                reply.reply(null);
            });
    }

    private void attachEditor() {
        WebView web = new WebView(this);
        editor = web;
        web.getSettings().setJavaScriptEnabled(true);
        web.getSettings().setDomStorageEnabled(true);
        web.getSettings().setBlockNetworkLoads(true);
        web.addJavascriptInterface(new BoardBridge(), "ZeroBoardNative");
        web.setWebViewClient(new WebViewClient() {
            @Override
            public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {
                return !EDITOR_URL.equals(request.getUrl().toString());
            }

            @Override
            public boolean shouldOverrideUrlLoading(WebView view, String url) {
                return !EDITOR_URL.equals(url);
            }
        });
        web.setWebChromeClient(new WebChromeClient() {
            @Override
            public boolean onShowFileChooser(WebView view, ValueCallback<Uri[]> callback,
                                             FileChooserParams params) {
                if (picker != null) picker.onReceiveValue(null);
                picker = callback;
                try {
                    startActivityForResult(params.createIntent(), PICK_FILE);
                } catch (RuntimeException error) {
                    picker = null;
                    callback.onReceiveValue(null);
                }
                return true;
            }
        });
        FrameLayout viewport = new FrameLayout(this);
        viewport.setBackgroundColor(android.graphics.Color.BLACK);
        viewport.addView(web, new FrameLayout.LayoutParams(-1, -1));
        getWindow().setStatusBarColor(android.graphics.Color.BLACK);
        getWindow().setNavigationBarColor(android.graphics.Color.BLACK);
        getWindow().getDecorView().setSystemUiVisibility(0);
        if (Build.VERSION.SDK_INT >= 35 && getApplicationInfo().targetSdkVersion >= 35) {
            viewport.setOnApplyWindowInsetsListener((view, insets) -> {
                var area = insets.getInsets(WindowInsets.Type.systemBars()
                    | WindowInsets.Type.displayCutout() | WindowInsets.Type.ime());
                view.setPadding(area.left, area.top, area.right, area.bottom);
                return insets;
            });
        }
        addContentView(viewport, new FrameLayout.LayoutParams(-1, -1));
        viewport.requestApplyInsets();
        web.loadUrl(EDITOR_URL);
    }

    @Override
    public void onBackPressed() {
        if (editor == null) {
            finish();
            return;
        }
        editor.evaluateJavascript(
            "window.zeroBoardHandleBack ? window.zeroBoardHandleBack() : false",
            value -> { if (!"true".equals(value)) finish(); });
    }

    @Override
    protected void onDestroy() {
        if (editor != null) {
            if (editor.getParent() instanceof android.view.ViewGroup) {
                ((android.view.ViewGroup) editor.getParent()).removeView(editor);
            }
            editor.destroy();
            editor = null;
        }
        super.onDestroy();
    }

    @Override
    protected void onActivityResult(int request, int result, Intent intent) {
        super.onActivityResult(request, result, intent);
        if (request == PICK_FILE && picker != null) {
            ValueCallback<Uri[]> callback = picker;
            picker = null;
            callback.onReceiveValue(WebChromeClient.FileChooserParams.parseResult(result, intent));
        }
    }

    public final class BoardBridge {
        private AtomicFile dataFile(String key) {
            if (!key.matches("zb2_[A-Za-z_]+")) throw new IllegalArgumentException();
            return new AtomicFile(new File(getFilesDir(), key + ".json"));
        }

        @JavascriptInterface
        public String readData(String key) {
            try {
                return new String(dataFile(key).readFully(), StandardCharsets.UTF_8);
            } catch (Exception error) {
                return "";
            }
        }

        @JavascriptInterface
        public boolean writeData(String key, String json) {
            try {
                new JSONTokener(json).nextValue();
                AtomicFile file = dataFile(key);
                FileOutputStream stream = file.startWrite();
                try {
                    stream.write(json.getBytes(StandardCharsets.UTF_8));
                    file.finishWrite(stream);
                    return true;
                } catch (Exception error) {
                    file.failWrite(stream);
                }
            } catch (Exception error) {
                return false;
            }
            return false;
        }

        @JavascriptInterface
        public String normalizeImage(String encoded) {
            try {
                byte[] bytes = Base64.decode(encoded, Base64.DEFAULT);
                BitmapFactory.Options options = new BitmapFactory.Options();
                options.inJustDecodeBounds = true;
                BitmapFactory.decodeByteArray(bytes, 0, bytes.length, options);
                options.inSampleSize = 1;
                while (Math.max(options.outWidth, options.outHeight) / options.inSampleSize > 2048) {
                    options.inSampleSize *= 2;
                }
                options.inJustDecodeBounds = false;
                Bitmap bitmap = BitmapFactory.decodeByteArray(bytes, 0, bytes.length, options);
                if (bitmap == null) return "";
                try {
                    ByteArrayOutputStream stream = new ByteArrayOutputStream();
                    bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream);
                    return Base64.encodeToString(stream.toByteArray(), Base64.NO_WRAP);
                } finally {
                    bitmap.recycle();
                }
            } catch (Exception error) {
                return "";
            }
        }

        @JavascriptInterface
        public String saveFile(String name, String mime, String encoded) {
            if (Build.VERSION.SDK_INT < 29) {
                return "{\"ok\":false,\"error\":\"Se requiere Android 10 para guardar en Descargas\"}";
            }
            String safeName = new File(name).getName();
            Uri uri = null;
            try {
                byte[] bytes = Base64.decode(encoded, Base64.DEFAULT);
                ContentValues values = new ContentValues();
                values.put(MediaStore.MediaColumns.DISPLAY_NAME, safeName);
                values.put(MediaStore.MediaColumns.MIME_TYPE, mime);
                values.put(MediaStore.MediaColumns.RELATIVE_PATH, "Download/ZeroBoard");
                values.put(MediaStore.MediaColumns.IS_PENDING, 1);
                uri = getContentResolver().insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values);
                if (uri == null) throw new IllegalStateException("No se pudo crear el archivo");
                try (OutputStream stream = getContentResolver().openOutputStream(uri)) {
                    if (stream == null) throw new IllegalStateException("No se pudo abrir el archivo");
                    stream.write(bytes);
                }
                values.clear();
                values.put(MediaStore.MediaColumns.IS_PENDING, 0);
                getContentResolver().update(uri, values, null, null);
                runOnUiThread(() -> Toast.makeText(MainActivity.this,
                    "Guardado en Descargas/ZeroBoard/" + safeName, Toast.LENGTH_LONG).show());
                return "{\"ok\":true}";
            } catch (Exception error) {
                if (uri != null) getContentResolver().delete(uri, null, null);
                return "{\"ok\":false,\"error\":" + JSONObject.quote(error.getMessage()) + "}";
            }
        }
    }
}
