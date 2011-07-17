package es.tid.ehealth.mobtel.android.app.listeners;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.telephony.TelephonyManager;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.app.ui.EntryPoint;
import es.tid.ehealth.mobtel.android.app.ui.call.CallPrompt;
import es.tid.ehealth.mobtel.android.app.ui.call.CallingContact;
import es.tid.ehealth.mobtel.android.app.ui.dialog.MissedCallAlertDialog;

public class PhoneCallReceiver extends BroadcastReceiver {

	private static final Logger logger = LoggerFactory.getLogger(PhoneCallReceiver.class);
	private static String outGoingNumber = null;
	
	private static String previousState = null;
	private static String incomingNumber;
	
	
	@Override
	public void onReceive(Context context, Intent intent) {
		
		// grab an instance of telephony manager
		//tm = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
		//connectToTelephonyService();
		
		String state = intent.getStringExtra(TelephonyManager.EXTRA_STATE);				
		
		logger.debug("Call STATE = " + state);
		logger.debug("Call Previous STATE = " + previousState);
		
		//Ringing. A new call arrived and is ringing or waiting. In the latter case, another call is already active. 
		if (state.equals(TelephonyManager.EXTRA_STATE_RINGING) ) 
		{	
			incomingNumber = intent.getStringExtra(TelephonyManager.EXTRA_INCOMING_NUMBER);
			logger.debug("Incoming Number: " + incomingNumber);
			CallPrompt.launch(context, incomingNumber);
			
		}
		//Off-hook. At least one call exists that is dialing, active, or on hold, and no calls are ringing or waiting. 
		else if(state.equals(TelephonyManager.EXTRA_STATE_OFFHOOK))
		{			
			if (outGoingNumber != null){
				logger.debug("Call phones number: " + outGoingNumber);
			}
			CallingContact.launch(context, "", outGoingNumber);
		}
		//No activity. 
		else if(state.equals(TelephonyManager.EXTRA_STATE_IDLE))
		{		
			EntryPoint.launch(context);
			if (previousState.equals(TelephonyManager.EXTRA_STATE_RINGING)){
				MissedCallAlertDialog.showAlertDialog(context, "Missed Call", incomingNumber);
			}
		
		}
		
		previousState = state;
		
	}	

	public static void setOutGoingNumber(String number) {
		outGoingNumber = number;		
	} 
		

}

