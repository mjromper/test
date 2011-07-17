package es.tid.ehealth.mobtel.android.app.listeners;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.util.Log;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

public class HomeButtonListener extends BroadcastReceiver{
	
	private static final Logger logger = LoggerFactory.getLogger(HomeButtonListener.class);
	
	/* the intent source*/
    static final String ACTION = "android.intent.action.MAIN";

	@Override
	public void onReceive(Context context, Intent intent) {
		if (Intent.ACTION_MAIN.equals(intent.getAction()) && (intent.hasCategory(Intent.CATEGORY_HOME))){
			
			logger.debug("HOME BUTTON PRESSED");
			Log.v("MANOLOOO","HOME BUTTON PRESSED");
		}
		
	}

}
