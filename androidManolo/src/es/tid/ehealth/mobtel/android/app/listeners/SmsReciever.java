package es.tid.ehealth.mobtel.android.app.listeners;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.telephony.SmsMessage;

import com.google.code.microlog4android.Logger;
import com.google.code.microlog4android.LoggerFactory;

import es.tid.ehealth.mobtel.android.R;
import es.tid.ehealth.mobtel.android.app.services.SynchronizationService;
import es.tid.ehealth.mobtel.android.app.ui.dialog.SmsAlertDialog;

public class SmsReciever extends BroadcastReceiver {

	private static final Logger logger = LoggerFactory.getLogger(SmsReciever.class);
	static final String ACTION = "android.provider.Telephony.SMS_RECEIVED";
	private static String messageOrigin = "";


	@Override
	public void onReceive(Context context, Intent intent) {
		if (intent.getAction().equals(ACTION)) {
			
			Bundle bundle = intent.getExtras();
			if (bundle != null) {
			    Object[] pdus = (Object[])bundle.get("pdus");
                final SmsMessage[] messages = new SmsMessage[pdus.length];
				for (int i = 0; i < pdus.length; i++) {	
				    StringBuilder buf = new StringBuilder();
				    messages[i] = SmsMessage.createFromPdu((byte[])pdus[i]);
					buf.append("Received SMS !! from  ");			
					buf.append(messages[i].getDisplayOriginatingAddress());			
					buf.append(" - ");			
					buf.append(messages[i].getDisplayMessageBody());
					messageOrigin  = messages[i].getDisplayOriginatingAddress();
					logger.debug(buf);
					
					if (messages[i].getDisplayMessageBody().startsWith(context.getString(R.string.message_config_sync))){
					    Intent intentSync = new Intent(context, SynchronizationService.class);
					    context.startService(intentSync);
					}
				}
			}
			
			
			/*
			 * To made an status bar Notification
			NotificationManager nm = (NotificationManager) context.getSystemService(Context.NOTIFICATION_SERVICE);
			Notification nt = new Notification(R.drawable.icon,"Notify", System.currentTimeMillis());
			nt.setLatestEventInfo(context,"Telecare","Description of the notification",
		    PendingIntent.getActivity(context, 0, intent,
			PendingIntent.FLAG_CANCEL_CURRENT));
			
			nm.notify(SMS_ID, nt);
			*/
			
			SmsAlertDialog.showAlertDialog(context, "SMS Received",messageOrigin);
		}
	}
}
