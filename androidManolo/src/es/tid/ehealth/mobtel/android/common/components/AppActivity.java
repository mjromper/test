package es.tid.ehealth.mobtel.android.common.components;

import android.app.Activity;
import android.os.Bundle;
import android.view.KeyEvent;
import android.view.WindowManager;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

public class AppActivity extends Activity{
	
	@Override
	public void onBackPressed() {
		// TODO Auto-generated method stub
		super.onBackPressed();
	}

	private static final Logger logger = LoggerFactory.getLogger(AppActivity.class);	
	

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
			logger.debug("Key FOCUS pressed");
			return true;
		case KeyEvent.KEYCODE_CAMERA:
			logger.debug("Key CAMERA pressed");
			return true;
		//case KeyEvent.KEYCODE_BACK:
		//	return true;
		case KeyEvent.KEYCODE_HOME:
			logger.debug("Key HOME pressed");
			return true;
		case KeyEvent.KEYCODE_DPAD_CENTER:
			logger.debug("Key DPAD_CENTER pressed");
			return true;
		case KeyEvent.KEYCODE_CALL:
			return true;
		case KeyEvent.KEYCODE_ENDCALL:
			logger.debug("Key END_CALL pressed");
			return true;	
		default:
			return super.onKeyDown(keyCode, event);
		}		
	}
	
	
	

}
