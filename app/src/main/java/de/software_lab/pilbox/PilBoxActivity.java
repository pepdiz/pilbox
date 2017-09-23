// 18sep17abu
// (c) Software Lab. Alexander Burger

package de.software_lab.pilbox;

import java.io.*;
import java.util.*;
import java.util.zip.*;
import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.view.View;
import android.webkit.WebView;
import android.webkit.WebSettings;
import android.webkit.WebViewClient;
import android.content.pm.ActivityInfo;

public class PilBoxActivity extends Activity {
   WebView PilView;
   ResultProxy Result;
   int History = 0;

   @Override protected void onCreate(Bundle state) {
      super.onCreate(state);
      try {
         setContentView(R.layout.activity_pil_box);
         PilView = (WebView)findViewById(R.id.webview);
         WebSettings ws = PilView.getSettings();
         ws.setBuiltInZoomControls(true);
         ws.setDisplayZoomControls(false);
         ws.setJavaScriptEnabled(true);
         ws.setSaveFormData(false);
         ws.setUserAgentString("PilBox");
         PilView.setWebViewClient(new WebViewClient() {
            @Override public void onPageFinished(WebView view, String url) {
               if (++History > 2) {
                  findViewById(R.id.back).setVisibility(view.canGoBack()? View.VISIBLE : View.INVISIBLE);
                  findViewById(R.id.fore).setVisibility(view.canGoForward()? View.VISIBLE : View.INVISIBLE);
               }
               else {
                  PilView.clearHistory();
                  findViewById(R.id.back).setVisibility(View.INVISIBLE);
                  findViewById(R.id.fore).setVisibility(View.INVISIBLE);
               }
               super.onPageFinished(view, url);
            }
         } );
         String arch = System.getProperty("os.arch").toLowerCase();
         if (!arch.startsWith(getString(R.string.arch)) && !arch.startsWith(getString(R.string.arch2)))
            PilView.loadData("<html><body>:(<br>App = " + getString(R.string.arch) +
                  "<br>CPU = " + arch + "</body></html>",
               "text/html",
               null );
         else {
            String home = getFilesDir().getPath() + "/";
            if (state == null) {
               Uri uri = getIntent().getData();

               if (uri != null  &&  uri.getPath() != null) {
                  ZipInputStream zip = new ZipInputStream(getContentResolver().openInputStream(uri));
                  byte[] buf = new byte[4096];
                  ZipEntry ze;
                  int n;

                  String nm = uri.getLastPathSegment().toLowerCase();
                  if (nm.endsWith(".zip"))
                     nm = nm.substring(0, nm.length()-4);
                  PrintWriter pil = new PrintWriter(home + "PIL-" + nm);
                  while ((ze = zip.getNextEntry()) != null) {
                     File f = new File(home + ze.getName());

                     pil.println(ze.getName());
                     if (ze.isDirectory())
                        f.mkdir();
                     else if (f.lastModified() != ze.getTime()) {
                        File p = f.getParentFile();
                        if (p != null)
                           p.mkdirs();
                        OutputStream out = new FileOutputStream(f);
                        while ((n = zip.read(buf)) > 0)
                           out.write(buf, 0, n);
                        out.close();
                        zip.closeEntry();
                        f.setLastModified(ze.getTime());
                     }
                  }
                  pil.close();
                  zip.close();
               }
               File uuid = new File(home + "UUID");
               if (!uuid.exists()) {
                  PrintWriter out = new PrintWriter(uuid);
                  out.println(UUID.randomUUID().toString());
                  out.close();
               }
            }
            PicoLisp.GUI = this;
            startService(new Intent(this, PicoLisp.class));
            PilView.loadUrl(state == null?
               "http://localhost:" + PicoLisp.line1(getAssets().open("run/Port")) + "?" + PicoLisp.line1(home + "UUID") :
               state.getString("url") );
         }
      }
      catch (Exception e) {
         PilView.loadData("<html><body><h3>" + e.toString() + "</h3></body></html>", "text/html", null);
      }
   }

   @Override protected void onSaveInstanceState(Bundle state) {
      super.onSaveInstanceState(state);
      state.putString("url", PilView.getUrl());
   }

   @Override protected void onNewIntent(Intent data) {
      super.onNewIntent(data);
      if (Result != null)
         Result.intent(data);
   }

   @Override protected void onActivityResult(int requestCode, int resultCode, Intent data) {
      super.onActivityResult(requestCode, resultCode, data);
      if (Result != null)
         if (resultCode == RESULT_OK)
            Result.good(requestCode, data);
         else
            Result.bad(requestCode, resultCode);
   }

   public void goBack(View view) {
      if (PilView.canGoBack())
         PilView.goBack();
   }

   public void goFore(View view) {
      if (PilView.canGoForward())
         PilView.goForward();
   }
}
