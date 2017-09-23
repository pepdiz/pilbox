// 31aug16abu
// (c) Software Lab. Alexander Burger

package de.software_lab.pilbox;

import java.io.*;
import java.util.*;
import java.math.*;
import java.lang.reflect.*;
import android.os.Looper;

// java Reflector
public class Reflector extends Thread {
   PicoLisp Context;
   String InJava, OutLisp, OutRqst, InRply;
   InOut Io, Rpc;

   Reflector(PicoLisp context, String java, String lisp, String rqst, String rply) {
      Context = context;
      InJava = java;
      OutLisp = lisp;
      OutRqst = rqst;
      InRply = rply;
   }

   // (java "cls" 'T ['any ..]) -> obj       New object
   // (java 'obj 'msg ['any ..]) -> any      Send message to object
   // (java 'obj "fld" ["fld" ..]) -> any    Value of object field
   // (java "cls" 'msg ['any ..]) -> any     Call method in class
   // (java "cls" "fld" ["fld" ..]) -> any   Value of class field
   // (java T "cls" ["cls" ..]) -> obj       Define interface
   // (java 'obj) -> [lst ..]                Reflect object
   // (java "cls") -> [lst lst ..]           Reflect class
   public void run() {
      Looper.prepare();  // For InvocationHandler
      for (;;) {
         try {
            int i;
            Object x, y, z, lst[];
            Io = new InOut(Context, new FileInputStream(InJava), new FileOutputStream(OutLisp));
            Rpc = new InOut(Context, new FileInputStream(InRply), new FileOutputStream(OutRqst));
            while ((lst = (Object[])Io.read()) != null) {
               try {
                  y = lst[0];
                  if (lst.length == 1) {                       // Reflect object or class
                     Class cls;
                     if (y instanceof String)
                        cls = ((Class)(y = Class.forName((String)y))).getSuperclass();
                     else if (y instanceof Class)
                        cls = ((Class)y).getSuperclass();
                     else
                        cls = y.getClass();
                     Field[] fld = cls.getDeclaredFields();
                     Io.Out.write(InOut.BEG);
                     Io.Out.write(InOut.BEG);
                     Io.print(cls);
                     Io.Out.write(InOut.DOT);
                     Io.print(cls.getName());
                     if (y instanceof Class) {
                        Class[] cl = ((Class)y).getDeclaredClasses();
                        if (cl.length == 0)
                           Io.Out.write(InOut.NIX);
                        else {
                           Io.Out.write(InOut.BEG);
                           for (i = 0; i < cl.length; ++i) {
                              Io.Out.write(InOut.BEG);
                              Io.print(cl[i]);
                              Io.Out.write(InOut.DOT);
                              Io.print(cl[i].getName());
                           }
                           Io.Out.write(InOut.END);
                        }
                     }
                     for (i = 0; i < fld.length; ++i) {
                        if (!(y instanceof Class)) {
                           Io.Out.write(InOut.BEG);
                           if (fld[i].isAccessible())
                              Io.print(fld[i].get(y));
                           else {
                              fld[i].setAccessible(true);
                              Io.print(fld[i].get(y));
                              fld[i].setAccessible(false);
                           }
                           Io.Out.write(InOut.DOT);
                        }
                        Io.prSym(fld[i].getName());
                     }
                     Io.Out.write(InOut.END);
                  }
                  else if (y == InOut.T) {                     // Define interface
                     Class[] c = new Class[lst.length - 1];
                     for (i = 0; i < c.length; ++i)
                        c[i] = Class.forName((lst[i+1]).toString());
                     InvocationHandler h = new InvocationHandler() {
                        public Object invoke(Object o, Method m, Object[] lst) {
                           String nm = m.getName();
                           switch (nm) {
                           case "equals":
                              return o == lst[0];
                           case "hashCode":
                              return System.identityHashCode(o);
                           case "toString":
                              return o.getClass().getName() + "@" + Integer.toHexString(System.identityHashCode(o));
                           default:
                              try {
                                 Rpc.print(o);
                                 Rpc.prSym(nm);
                                 Rpc.print(lst);
                                 Rpc.flush();
                                 return Rpc.read();
                              }
                              catch (IOException e) {}
                              return null;
                           }
                        }
                     };
                     Io.print(Proxy.newProxyInstance(c[0].getClassLoader(), c, h));
                  }
                  else if ((z = lst[1]) instanceof String) {
                     if (y instanceof String) {                // Value of class field
                        Class cls = Class.forName((String)y);
                        x = cls.getField(z.toString()).get(cls);
                     }
                     else                                      // Value of object field
                        x = y.getClass().getField(z.toString()).get(y);
                     for (i = 2; i < lst.length; ++i)
                        x = x.getClass().getField(lst[i].toString()).get(x);
                     Io.print(x);
                  }
                  else {
                     i = lst.length-2;
                     Object[] arg = new Object[i];
                     Class[] par = new Class[i];
                     while (--i >= 0) {
                        Object v = lst[i+2];
                        if (v == InOut.T || v == InOut.Nil) {
                           arg[i] = v == InOut.T;
                           par[i] = Boolean.TYPE;
                        }
                        else {
                           arg[i] = v;
                           if (v instanceof Byte)
                              par[i] = Byte.TYPE;
                           else if (v instanceof Character)
                              par[i] = Character.TYPE;
                           else if (v instanceof Short)
                              par[i] = Short.TYPE;
                           else if (v instanceof Integer)
                              par[i] = Integer.TYPE;
                           else if (v instanceof Long)
                              par[i] = Long.TYPE;
                           else if (v instanceof Float)
                              par[i] = Float.TYPE;
                           else if (v instanceof Double)
                              par[i] = Double.TYPE;
                           else
                              par[i] = v.getClass();
                        }
                     }
                     if (z == InOut.T)                         // New object
                        x = javaConstructor(Class.forName(y.toString()), par).newInstance(arg);
                     else {
                        Method m;
                        if (y instanceof String) {             // Call method in class
                           m = javaMethod(Class.forName((String)y), z.toString(), par);
                           x = m.invoke(null, arg);
                        }
                        else {                                 // Send message to object
                           m = javaMethod(y.getClass(), z.toString(), par);
                           x = m.invoke(y, arg);
                        }
                        if (m.getReturnType() == Void.TYPE)
                           x = null;
                     }
                     Io.print(x);
                  }
               }
               catch (Throwable e) {
                  String s = e.toString();
                  while ((e = e.getCause()) != null)
                     s += " / " + e.toString();
                  Io.Out.write(InOut.BEG);
                  Io.prSym("err");
                  Io.Out.write(InOut.DOT);
                  Io.print(s);
               }
               Io.flush();
            }
            while (Io.In.available() > 0)
               Io.In.read();
            Io.close();
            while (Rpc.In.available() > 0)
               Rpc.In.read();
            Rpc.close();
         }
         catch (IOException e) {}
      }
   }

   final static Constructor javaConstructor(Class cls, Class[] par) throws NoSuchMethodException {
   looking:
      for (Constructor m : cls.getConstructors()) {
         Class<?>[] types = m.getParameterTypes();
         if (types.length == par.length) {
            for (int i = 0; i < types.length; ++i)
               if (!(types[i].isAssignableFrom(par[i])))
                  continue looking;
            return m;
         }
      }
      throw new NoSuchMethodException();
   }

   final static Method javaMethod(Class cls, String nm, Class[] par)  throws NoSuchMethodException {
   looking:
      for (Method m : cls.getMethods()) {
         if (m.getName().equals(nm)) {
            Class<?>[] types = m.getParameterTypes();
            if (types.length == par.length) {
               for (int i = 0; i < types.length; ++i)
                  if (!(types[i].isAssignableFrom(par[i])))
                     continue looking;
               return m;
            }
         }
      }
      throw new NoSuchMethodException(nm + "(" + par + ")");
   }
}
