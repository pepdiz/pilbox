// 02sep16abu
// (c) Software Lab. Alexander Burger

package de.software_lab.pilbox;

import android.content.Intent;

public interface ResultProxy {
   void intent(Intent data);
   void good(int requestCode, Intent data);
   void bad(int requestCode, int resultCode);
}
