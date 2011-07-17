package es.tid.ehealth.mobtel.android.app.listeners;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ResolveInfo;
import android.util.Log;
import android.widget.Toast;
import es.tid.ehealth.mobtel.android.app.ui.EntryPoint;

public class AutoLaunchListener extends BroadcastReceiver {
	
	/* the intent source*/
    static final String ACTION = "android.intent.action.BOOT_COMPLETED";

	@Override
	public void onReceive(Context context, Intent intent) {
		// make sure you receive "BOOT_COMPLETED"
	    if ((intent.getAction() != null) && (intent.getAction().equals(ACTION)))
	    {
	    	ResolveInfo res = context.getPackageManager().resolveActivity(intent, 0);
	        // Got to be a better way to determine if there is no default...
	        if (res.activityInfo.packageName.equals("android")) {
	        	Log.v("AutoLunchApp","No default selected!!!");
	        } else if (res.activityInfo.packageName.equals(context.getPackageName())) {
	        	Log.v("AutoLunchApp","We are default!!!");
	        } else {
	        	Log.v("AutoLunchApp","Someone else is default!!!");
	            
	        }
	    	Toast.makeText(context, "Telecare begining to start!", Toast.LENGTH_LONG).show();
	    	Log.v("AutoLunchApp","START TELECARE NAVIGATOR!!!");
	    	Intent i = new Intent(context,EntryPoint.class);
	    	i.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
	    	context.startActivity(i);
	    }
		
	}

}
