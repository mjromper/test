package es.tid.ehealth.mobtel.android.app.listeners;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

public class PhoneCallOutgoingReceiver extends BroadcastReceiver {

	private static final Logger logger = LoggerFactory.getLogger(PhoneCallOutgoingReceiver.class);
	/* the intent source*/
    static final String ACTION = "android.intent.action.NEW_OUTGOING_CALL";

	
	@Override
	public void onReceive(Context context, Intent intent) {
		//if (Intent.ACTION_NEW_OUTGOING_CALL.equals(ACTION)) {
			String number = intent.getStringExtra(Intent.EXTRA_PHONE_NUMBER);			
			logger.debug("Call phones number OUTGOING: " + number);
			PhoneCallReceiver.setOutGoingNumber(number);
			
		//}
		
		
	}
	
}

