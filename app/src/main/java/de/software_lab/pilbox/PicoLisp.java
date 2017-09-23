// 15sep17abu
// (c) Software Lab. Alexander Burger

package de.software_lab.pilbox;

import java.io.*;
import android.app.Service;
import android.os.IBinder;
import android.os.SystemClock;
import android.content.Intent;
import android.widget.Toast;

public class PicoLisp extends Service {
   String Home;
   Process Proc;
   static PilBoxActivity GUI;

   @Override public void onCreate() {
      try {
         Home = getFilesDir().getPath();
         String vers = Home + "/Version";
         if (!(new File(vers)).exists() ||
                !line1(vers).equals(line1(getAssets().open("run/Version"))) ) {
            copyAssets("run", getAssets().list("run"), Home);
            mkExec(Home + "/bin/picolisp");
            mkExec(Home + "/bin/ssl");
            mkExec(Home + "/lib/ext");
            mkExec(Home + "/lib/ht");
            mkExec(Home + "/lib/libssl.so.1.0.0");
            mkExec(Home + "/lib/libcrypto.so.1.0.0");
         }
      }
      catch (Exception e) {
         toast("Cannot init PicoLisp\n" + e.toString());
      }
   }

   @Override public int onStartCommand(Intent intent, int flags, int startId) {
      try {
         File pid = new File(Home + "/PID");
         pid.delete();
         rmDir(new File(Home + "/.pil/tmp"));
         (new File(Home + "/log")).renameTo(new File(Home + "/log-"));
         ProcessBuilder pb =
            new ProcessBuilder("bin/picolisp", "lib.l", "App.l");
         pb.environment().put("HOME", Home);
         pb.environment().put("PORT", line1(Home + "/Port"));
         pb.redirectErrorStream(true);
         pb.directory(new File(Home));
         Proc = pb.start();
         (new Thread() {
            InputStream in = Proc.getInputStream();
            OutputStream out = new FileOutputStream(Home + "/log");
            public void run() {
               try {
                  int c;

                  while ((c = in.read()) > 0) {
                     out.write(c);
                     out.flush();
                  }
                  out.close();
               }
               catch (IOException e) {}
            }
         } ).start();
         while (!pid.exists())
            SystemClock.sleep(80);
         SystemClock.sleep(80);
         new Reflector(this, Home + "/JAVA", Home + "/LISP", Home + "/RQST", Home + "/RPLY").start();
      }
      catch (Exception e) {
         toast("Cannot start PicoLisp\n" + e.toString());
      }
      return START_NOT_STICKY;
   }

   @Override public IBinder onBind(Intent intent) {
      return null;
   }

   @Override public void onTaskRemoved(Intent rootIntent) {
      stop();
      super.onTaskRemoved(rootIntent);
   }

   @Override public void onDestroy() {
      stop();
      super.onDestroy();
   }

   static String line1(InputStream in) throws IOException {
      BufferedReader rd = new BufferedReader(new InputStreamReader(in));
      String s = rd.readLine();
      rd.close();
      return s;
   }

   static String line1(String nm) throws IOException {
      BufferedReader rd = new BufferedReader(new FileReader(nm));
      String s = rd.readLine();
      rd.close();
      return s;
   }

   void copyAssets(String src, String[] lst, String dst) throws IOException {
      for (int i = 0; i < lst.length; ++i) {
         String s = src + "/" + lst[i];
         String[] x = getAssets().list(s);
         if (x.length == 0) {
            InputStream in = getAssets().open(s);
            OutputStream out = new FileOutputStream(new File(dst, lst[i]));
            byte[] buf = new byte[4096];
            int n;
            while ((n = in.read(buf)) > 0)
               out.write(buf, 0, n);
            out.close();
            in.close();
         }
         else {
            String d = dst + "/" + lst[i];
            mkDir(d);
            copyAssets(s, x, d);
         }
      }
   }

   void mkExec(String nm) throws IOException {
      File f = new File(nm);
      if (f.exists())
         f.setExecutable(true);
   }

   void mkDir(String nm) {
      File dir = new File(nm);
      if (!dir.exists())
         dir.mkdir();
   }

   void rmDir(File dir) {
      if (dir.exists())
         for (File f : dir.listFiles()) {
            if (f.isDirectory())
               rmDir(f);
            f.delete();
         }
   }

   void stop() {
      stopSelf();
      try {
         android.os.Process.sendSignal(
            Integer.parseInt(line1(Home + "/PID")),
            15 );
         Proc.waitFor();
         SystemClock.sleep(1000);
      }
      catch (Exception e) {}
   }

   public void loadUrl(final String url) {
      if (GUI != null)
         GUI.runOnUiThread(new Thread() {public void run() {GUI.PilView.loadUrl(url);}});
   }

   public void setResultProxy(ResultProxy p) {
      if (GUI != null)
         GUI.Result = p;
   }

   public void clearHistory() {
      GUI.History = 0;
   }

   public void clearCache() {
      GUI.runOnUiThread(new Thread() {
         public void run() {GUI.PilView.clearCache(true);}
      } );
   }

   public void toast(final String s) {
      GUI.runOnUiThread(new Thread() {
         public void run() {Toast.makeText(GUI, s, Toast.LENGTH_LONG).show();}
      } );
   }
}
