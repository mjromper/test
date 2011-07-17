package es.tid.ehealth.mobtel.android.app.listeners;

import android.telephony.PhoneStateListener;
import android.telephony.TelephonyManager;


public class CallStateListener extends PhoneStateListener {

	
	//private static final Logger logger = LoggerFactory.getLogger(CallStateListener.class);
	
	public void onCallStateChanged(int state, String incomingNumber) {
		super.onCallStateChanged(state, incomingNumber); 
		
		switch(state) { 
		case TelephonyManager.CALL_STATE_IDLE: 			
			break; 
		case TelephonyManager.CALL_STATE_OFFHOOK:			
			break; 
		case TelephonyManager.CALL_STATE_RINGING:
			break;
		default:
			//logger.debug("mystate = " + state);
		} 
	} 
} 