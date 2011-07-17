package es.tid.ehealth.mobtel.android.common.components;

import android.app.ListActivity;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.WindowManager;

public class AppListActivity extends ListActivity{
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        this.getWindow().setFlags(WindowManager.LayoutParams.FLAG_FULLSCREEN,
        		WindowManager.LayoutParams.FLAG_FULLSCREEN);
    }	
	
	@Override
	public boolean onKeyDown(int keyCode, KeyEvent event) {
		switch (keyCode) {
		case KeyEvent.KEYCODE_FOCUS:
			return true;
		case KeyEvent.KEYCODE_CAMERA:
			return true;
		case KeyEvent.KEYCODE_BACK:
			return true;
		case KeyEvent.KEYCODE_HOME:
			return true;
		case KeyEvent.KEYCODE_DPAD_CENTER:
			return true;
		case KeyEvent.KEYCODE_CALL:
			return true;
		case KeyEvent.KEYCODE_ENDCALL:
			return true;	
		default:
			return super.onKeyDown(keyCode, event);
		}		
	}

}
