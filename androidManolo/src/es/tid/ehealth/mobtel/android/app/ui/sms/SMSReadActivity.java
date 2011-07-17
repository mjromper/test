package es.tid.ehealth.mobtel.android.app.ui.sms;

import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.widget.TextView;
import es.tid.ehealth.mobtel.android.common.components.AppActivity;

public class SMSReadActivity extends AppActivity {

  @Override
  public void onCreate(Bundle savedInstanceState) {
      super.onCreate(savedInstanceState);
      TextView view = new TextView(this);
      Uri uriSMSURI = Uri.parse("content://sms/inbox");
      Cursor cur = getContentResolver().query(uriSMSURI, null, null, null,null);
      String sms = "";
      while (cur.moveToNext()) {
          sms += "From :" + cur.getString(2) + " : " + cur.getString(11)+"\n";         
      }
      view.setText(sms);
      setContentView(view);
  }
}

